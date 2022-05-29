//
//  KBYourTube.m
//  yourTube
//
//  Created by Kevin Bradley on 12/21/15.
//  Copyright © 2015 nito. All rights reserved.
//

#import "KBYourTube.h"
#import "APDocument/APXML.h"
#import "ONOXMLDocument.h"
#import "AppDelegate.h"

static NSString * const hardcodedTimestamp = @"16864";
static NSString * const hardcodedCipher = @"42,0,14,-3,0,-1,0,-2";

/**
 
 out of pure laziness I put the implementation KBYTStream and KBYTMedia classes in this file and their interfaces
 in the header file. However, it does provide easier portability since I have yet to make this into a library/framework/pod
 
 
 KBYTStream identifies an actual playback stream
 
 extension = mp4;
 format = 720p MP4;
 height = 720;
 itag = 22;
 title = "Lil Wayne - No Worries %28Explicit%29 ft. Detail\";
 type = "video/mp4; codecs=avc1.64001F, mp4a.40.2";
 url = "https://r9---sn-bvvbax-2ime.googlevideo.com/videoplayback?dur=229.529&sver=3&expire=1451432986&pl=19&ratebypass=yes&nh=EAE&mime=video%2Fmp4&itag=22&ipbits=0&source=youtube&ms=au&mt=1451411225&mv=m&mm=31&mn=sn-bvvbax-2ime&requiressl=yes&key=yt6&lmt=1429504739223021&id=o-ANaYZmZnobN9YUPpUED-68dQ4O8sFyxHtMaQww4kxgTT&upn=PSfKek6hLJg&gcr=us&sparams=dur%2Cgcr%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&fexp=9406813%2C9407016%2C9415422%2C9416126%2C9418404%2C9420452%2C9422596%2C9423662%2C9424205%2C9425382%2C9425742%2C9425965&ip=xx&signature=E0F8B6F26BF082B1EB97509DF597AB175DC04D4D.9408359B27A278F16AEF13EA16DE83AA7A600177\";
 
 the signature deciphering (if necessary) is already taken care of in the url
 
 */

@implementation KBYTChannel

- (NSString *)description {
    NSString *desc = [super description];
    return [NSString stringWithFormat:@"%@ title: %@ ID: %@ subtitle: %@ videos: %@ playlists: %@", desc,_title, _channelID, _subtitle, _videos, _playlists];
}

- (void)mergeChannelVideos:(KBYTChannel *)channel {
    NSMutableArray *newVideos = [self.videos mutableCopy];
    NSLog(@"[tuyu] new channel: %@", channel.videos);
    NSLog(@"[tuyu] current videos: %@", self.videos);
    [newVideos addObjectsFromArray:channel.videos];
    self.continuationToken = channel.continuationToken;
    self.videos = newVideos;
}

@end

@implementation KBYTPlaylist

- (NSString *)description {
    NSString *desc = [super description];
    return [NSString stringWithFormat:@"%@ videos: %@ title: %@ ID: %@", desc, _videos, _title, _playlistID];
}


@end

@implementation KBYTSearchResults

- (NSString *)description {
    NSString *desc = [super description];
    return [NSString stringWithFormat:@"%@ videos: %@ playlists: %@ channels: %@ cc: %@ results count: %lu", desc, _videos, _playlists, _channels, _continuationToken, _estimatedResults];
}

- (void)processJSON:(NSDictionary *)jsonDict {
    __block NSMutableArray *searchResults = [NSMutableArray new];
    __block NSMutableArray *playlistResults = [NSMutableArray new];
    __block NSMutableArray *channelResults = [NSMutableArray new];
    NSMutableArray *ourVideos = [NSMutableArray new];
    [jsonDict recursiveInspectObjectLikeKey:@"videoRenderer" saving:ourVideos];
    [ourVideos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KBYTSearchResult *searchItem = [[KBYourTube sharedInstance] searchResultFromVideoRenderer:obj];
        [searchResults addObject:searchItem];
    }];
    NSArray *playlists = [jsonDict recursiveObjectsForKey:@"playlistRenderer"];
    NSArray *channels = [jsonDict recursiveObjectsForKey:@"channelRenderer"];
    NSInteger estimatedResults = [[jsonDict recursiveObjectForKey:@"estimatedResults"] integerValue];
    //NSLog(@"playlists: %@", playlists);
    //NSLog(@"channels: %@", channels);
    NSLog(@"estimated results: %lu", estimatedResults);
    id cc = [jsonDict recursiveObjectForKey:@"continuationCommand"];
    self.continuationToken = cc[@"token"];
    //NSLog(@"cc: %@", cc);
    
    self.videos = searchResults;
    [playlists enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *current = obj[@"playlistRenderer"];
        NSDictionary *title = [current recursiveObjectForKey:@"title"];
        NSString *pis = current[@"playlistId"];
        NSArray *thumbnails = current[@"thumbnail"][@"thumbnails"];
        NSDictionary *longBylineText = current[@"longBylineText"];
        KBYTSearchResult *searchItem = [KBYTSearchResult new];
        searchItem.author = [longBylineText recursiveObjectForKey:@"text"];
        searchItem.title = title[@"simpleText"];
        searchItem.videoId = pis;
        searchItem.imagePath = thumbnails.lastObject[@"url"];
        searchItem.resultType = kYTSearchResultTypePlaylist;
        searchItem.details = [current recursiveObjectForKey:@"navigationEndpoint"][@"browseEndpoint"][@"browseId"];
        [playlistResults addObject:searchItem];
    }];
    self.playlists = playlistResults;
    [channels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *current = obj[@"channelRenderer"];
        if (current) {
            NSDictionary *title = [current recursiveObjectForKey:@"title"];
            NSString *cis = current[@"channelId"];
            NSArray *thumbnails = current[@"thumbnail"][@"thumbnails"];
            NSDictionary *longBylineText = current[@"longBylineText"];
            KBYTSearchResult *searchItem = [KBYTSearchResult new];
            searchItem.author = [longBylineText recursiveObjectForKey:@"text"];
            searchItem.title = title[@"simpleText"];
            searchItem.videoId = cis;
            searchItem.imagePath = thumbnails.lastObject[@"url"];
            searchItem.resultType = kYTSearchResultTypeChannel;
            searchItem.details = [current recursiveObjectForKey:@"navigationEndpoint"][@"browseEndpoint"][@"canonicalBaseUrl"];
            [channelResults addObject:searchItem];
        }
    }];
    self.channels = channelResults;
    self.estimatedResults = estimatedResults;
}

@end

@implementation KBYTSearchResult

@synthesize title, author, details, imagePath, videoId, duration, age, views, resultType;

- (id)initWithDictionary:(NSDictionary *)resultDict
{
    self = [super init];
    title = resultDict[@"title"];
    author = resultDict[@"author"];
    details = resultDict[@"description"];
    imagePath = resultDict[@"imagePath"];
    videoId = resultDict[@"videoId"];
    duration = resultDict[@"duration"];
    views = resultDict[@"views"];
    age = resultDict[@"age"];
    return self;
}

- (NSString *)readableSearchType
{
    switch (self.resultType) {
        case kYTSearchResultTypeUnknown: return @"Unknown";
        case kYTSearchResultTypeVideo: return @"Video";
        case kYTSearchResultTypePlaylist: return @"Playlist";
        case kYTSearchResultTypeChannel: return @"Channel";
        default:
            return @"Unknown";
    }
}

- (NSDictionary *)dictionaryValue
{
    if (self.title == nil)self.title = @"Unavailable";
    if (self.details == nil)self.details = @"Unavailable";
    if (self.views == nil)self.views = @"Unavailable";
    if (self.age == nil)self.age = @"Unavailable";
    if (self.author == nil)self.author = @"Unavailable";
    if (self.imagePath == nil)self.imagePath = @"Unavailable";
    if (self.duration == nil)self.duration = @"Unavailable";
    if (self.videoId == nil)self.videoId = @"Unavailable";
    
    return @{@"title": self.title, @"author": self.author, @"details": self.details, @"imagePath": self.imagePath, @"videoId": self.videoId, @"duration": self.duration, @"age": self.age, @"views": self.views, @"resultType": [self readableSearchType]};
}

- (NSString *)description
{
    return [[self dictionaryValue] description];
}


@end

@implementation KBYTStream

- (id)initWithDictionary:(NSDictionary *)streamDict
{
    self = [super init];
    
    if ([self processSource:streamDict] == true)
    {
        return self;
    }
    return nil;
}

- (BOOL)isExpired
{
    if ([NSDate passedEpochDateInterval:self.expireTime])
    {
        return true;
    }
    return false;
}


/**
 
 take the input dictionary and update our values according to it.
 
 */


- (BOOL)processSource:(NSDictionary *)inputSource
{
    //NSLog(@"inputSource: %@", inputSource);
    if ([[inputSource allKeys] containsObject:@"url"]|| [[inputSource allKeys] containsObject:@"signatureCipher"] )
    {
        NSString *signature = nil;
        self.itag = [[inputSource objectForKey:@"itag"] integerValue];
        
        //if you want to limit to mp4 only, comment this if back in
        //  if (fmt == 22 || fmt == 18 || fmt == 37 || fmt == 38)
        //    {
        NSString *url = [[inputSource objectForKey:@"url"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if ([[inputSource allKeys] containsObject:@"signatureCipher"]){
            
            NSDictionary *sigCipher = [self parseFlashVars:inputSource[@"signatureCipher"]];
            url = sigCipher[@"url"];
            NSLog(@"sigCipher: %@", sigCipher);
            /*
             s=8A8AOq0QJAwRAIgKSdpFxJyyyoEYfkEh5RkOQmtEM7Hh8YGQtCvlL1VT_sCIF8e0s44KmvvtzWwsG5eD22lw2_Yz7GwdTmVqQ8Kuryzyz&sp=sig&url=https://rr3---sn-a5msen7z.googlevideo.com/videoplayback%3Fexpire%3D1652595005%26ei%3D3USAYrrkINWxkgbU6404%26ip%3D2600%253A8800%253A1588%253A9f00%253A8c89%253A1660%253Acdbf%253Ac18e%26id%3Do-AGQBqqF2-LgoaqBVkcmRlkpvU9WtRB5S32NMhEfH2jkN%26itag%3D18%26source%3Dyoutube%26requiressl%3Dyes%26mh%3D_Q%26mm%3D31%252C29%26mn%3Dsn-a5msen7z%252Csn-a5mekn6s%26ms%3Dau%252Crdu%26mv%3Dm%26mvi%3D3%26pl%3D39%26gcr%3Dus%26initcwndbps%3D1766250%26spc%3D4ocVCxyJsB4VkTqIT3xnFSkZMdvN%26vprv%3D1%26mime%3Dvideo%252Fmp4%26ns%3DEBmX5nmYQ6nGhLxV-2TjWuUG%26gir%3Dyes%26clen%3D26129098%26ratebypass%3Dyes%26dur%3D356.906%26lmt%3D1651347053004693%26mt%3D1652573092%26fvip%3D4%26fexp%3D24001373%252C24007246%26c%3DWEB%26txp%3D4530434%26n%3DxzUdRoyXVMRN_uab%26sparams%3Dexpire%252Cei%252Cip%252Cid%252Citag%252Csource%252Crequiressl%252Cgcr%252Cspc%252Cvprv%252Cmime%252Cns%252Cgir%252Cclen%252Cratebypass%252Cdur%252Clmt%26lsparams%3Dmh%252Cmm%252Cmn%252Cms%252Cmv%252Cmvi%252Cpl%252Cinitcwndbps%26lsig%3DAG3C_xAwRAIgD-9V8s9iM0XUVRuXq7QNKFbCJEQWM1Xzu2q_1_PYFyQCIHEPOU69K4EiJtC_zMPDZs0RuGoYP_t3YoI2rSIcpzY0
             */
            self.s = sigCipher[@"s"];
            signature = self.s;
            signature = [[KBYourTube sharedInstance] decodeSignature:signature];
            url = [url stringByAppendingFormat:@"&signature=%@", signature];
        }
        if ([[inputSource allKeys] containsObject:@"sig"])
        {
            self.s = [inputSource objectForKey:@"sig"];
            signature = [inputSource objectForKey:@"sig"];
            url = [url stringByAppendingFormat:@"&signature=%@", signature];
        } else if ([[inputSource allKeys] containsObject:@"s"]) //requires cipher to update the signature
        {
            self.s = [inputSource objectForKey:@"s"];
            signature = [inputSource objectForKey:@"s"];
            signature = [[KBYourTube sharedInstance] decodeSignature:signature];
            url = [url stringByAppendingFormat:@"&signature=%@", signature];
        }
        
        NSDictionary *tags = [KBYourTube formatFromTag:self.itag];
        
        
        if (tags == nil) // unsupported format, return nil
        {
            DLog(@"tag not found: %lu", self.itag);
            return false;
        }
        
        if ([[inputSource valueForKey:@"quality"] length] == 0)
        {
            self.quality = tags[@"quality"];
        } else {
            self.quality = inputSource[@"quality"];
        }
        
        self.url = [NSURL URLWithString:url];
        self.expireTime = [[self.url parameterDictionary][@"expire"] integerValue];
        self.format = tags[@"format"]; //@{@"format": @"4K MP4", @"height": @2304, @"extension": @"mp4"}
        self.height = tags[@"height"];
        self.extension = tags[@"extension"];
        
        if (([self.extension isEqualToString:@"mp4"] || [self.extension isEqualToString:@"3gp"] ))
        {
            self.playable = true;
        } else {
            self.playable = false;
        }
        
        if (([self.extension isEqualToString:@"m4v"] || [self.extension isEqualToString:@"aac"] ))
        {
            self.multiplexed = false;
        } else {
            self.multiplexed = true;
        }
        
        self.type = [[[[inputSource valueForKey:@"type"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        self.title = [inputSource[@"title"] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        if (self.height.integerValue > 0){
            self.outputFilename = [[NSString stringWithFormat:@"%@ [%@p].%@", self.title, self.height,self.extension] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        } else {
            self.outputFilename = [[NSString stringWithFormat:@"%@.%@", self.title ,self.extension] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        return true;
        // }
    }
    
    
    return false;
}
/*
 - (NSDictionary *)dictionaryValue
 {
 return @{@"title": self.title, @"type": self.type, @"format": self.format, @"height": self.height, @"itag": [NSNumber numberWithInteger:self.itag], @"extension": self.extension, @"url": self.url};
 }
 */

- (NSDictionary *)dictionaryValue
{
    if (self.title == nil)self.title = @"Unavailable";
    if (self.type == nil)self.type = @"Unavailable";
    if (self.format == nil)self.format = @"Unavailable";
    if (self.height == nil)self.height = 0;
    if (self.extension == nil)self.extension = @"Unavailable";
    if (self.outputFilename == nil)self.outputFilename = @"Unavailable";
    
    return @{@"title": self.title, @"type": self.type, @"format": self.format, @"height": self.height, @"itag": [NSNumber numberWithInteger:self.itag], @"extension": self.extension, @"url": self.url, @"outputFilename": self.outputFilename};
}


- (NSString *)description
{
    return [[self dictionaryValue] description];
}


@end

/**
 
 KBYTMedia contains the root reference object to the youtube video queried including the following values
 
 author = LilWayneVEVO;
 duration = 230;
 images =     {
 high = "https://i.ytimg.com/vi/5z25pGEGBM4/hqdefault.jpg";
 medium = "https://i.ytimg.com/vi/5z25pGEGBM4/mqdefault.jpg";
 standard = "https://i.ytimg.com/vi/5z25pGEGBM4/sddefault.jpg";
 };
 keywords = "Lil,Wayne,Detail,Cash,Money,Fear,and,Loathing,in,Las,Vegas,New,Video,explicit,Young,Official";
 streams {} //example of stream listed above
 title = "Lil Wayne - No Worries (Explicit) ft. Detail";
 videoID = 5z25pGEGBM4;
 views = 47109256;
 
 */

@implementation KBYTMedia

- (BOOL)isExpired
{
    if ([NSDate passedEpochDateInterval:self.expireTime])
    {
        return true;
    }
    return false;
}

- (NSString *)expiredString
{
    if ([self isExpired]) return @"YES";
    return @"NO";
}

//make sure if its an adaptive stream that we match the video streams with the proper audio stream.

- (void)matchAudioStreams
{
    KBYTStream *audioStream = [[self.streams filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"itag == 140"]]lastObject];
    for (KBYTStream *theStream in self.streams)
    {
        if ([theStream multiplexed] == false && theStream != audioStream)
        {
            NSLog(@"adding audio stream to stream with itag: %lu", (long)theStream.itag);
            [theStream setAudioStream:audioStream];
        }
    }
}

- (id)initWithDictionary:(NSDictionary *)inputDict
{
    self = [super init];
    if ([self processDictionary:inputDict] == true) {
        return self;
    }
    return nil;
}

- (id)initWithJSON:(NSDictionary *)jsonDict {
    self = [super init];
    if ([self processJSON:jsonDict] == true) {
        return self;
    }
    return nil;
}

- (BOOL)processJSON:(NSDictionary *)jsonDict {
    
    NSDictionary *streamingData = jsonDict[@"streamingData"];
    NSDictionary *videoDetails = jsonDict[@"videoDetails"];
    NSLog(@"videoDetails: %@", jsonDict.allKeys);
    self.author = videoDetails[@"author"];
    self.title = videoDetails[@"title"];
    self.videoId = videoDetails[@"videoId"];
    self.views = videoDetails[@"viewCount"];
    self.duration = videoDetails[@"lengthSeconds"];
    self.details = videoDetails[@"shortDescription"];
    NSArray *imageArray = videoDetails[@"thumbnail"][@"thumbnails"];
    self.keywords = [videoDetails[@"keywords"] componentsJoinedByString:@","];
    NSMutableDictionary *images = [NSMutableDictionary new];
    NSInteger imageCount = imageArray.count; //TODO make sure there are actually that many images
    images[@"high"] = imageArray.lastObject[@"url"];
    images[@"medium"] = imageArray[imageCount-2][@"url"];
    images[@"standard"] = imageArray[imageCount-3][@"url"];
    self.images = images;
    NSMutableArray *videoArray = [NSMutableArray new];
    NSArray *formats = streamingData[@"formats"];
    //NSLog(@"adaptiveFormats: %@", adaptiveFormats);
    //NSLog(@"formats: %@", formats);
    NSArray *adaptiveFormats = streamingData[@"adaptiveFormats"];
    [adaptiveFormats enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *videoDict = [obj mutableCopy];
        //add the title from the previous dictionary created
        [videoDict setValue:self.title forKey:@"title"];
        //NSLog(@"videoDict: %@", videoDict);
        //process the raw dictionary into something that can be used with download links and format details
        KBYTStream *processed = [[KBYTStream alloc] initWithDictionary:videoDict];
        //NSDictionary *processed = [self processSource:videoDict];
        if (processed.title != nil)
        {
            self.expireTime = [processed expireTime];
            //if we actually have a video detail dictionary add it to final array
            [videoArray addObject:processed];
        }
    }];
    [formats enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *videoDict = [obj mutableCopy];
        //add the title from the previous dictionary created
        [videoDict setValue:self.title forKey:@"title"];
        //NSLog(@"videoDict: %@", videoDict);
        //process the raw dictionary into something that can be used with download links and format details
        KBYTStream *processed = [[KBYTStream alloc] initWithDictionary:videoDict];
        //NSDictionary *processed = [self processSource:videoDict];
        if (processed.title != nil)
        {
            self.expireTime = [processed expireTime];
            //if we actually have a video detail dictionary add it to final array
            [videoArray addObject:processed];
        }
    }];
    //NSLog(@"videoArray: %@", videoArray);
    self.streams = videoArray;
    [self matchAudioStreams];
    return true;
}

//take the raw video detail dictionary, update our object and find/update stream details

- (BOOL)processDictionary:(NSDictionary *)vars
{
    //DLog(@"ad_tag: %@", [vars[@"ad_tag"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    //DLog(@"%@", vars);
    //grab the raw streams string that is available for the video
    NSString *streamMap = [vars objectForKey:@"url_encoded_fmt_stream_map"];
    NSString *adaptiveMap = [vars objectForKey:@"adaptive_fmts"];
    //grab a few extra variables from the vars
    
    NSString *title = [vars[@"title"] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    NSString *author = [[vars[@"author"] stringByReplacingOccurrencesOfString:@"+" withString:@" "]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    NSString *iurlhq = [vars[@"iurlhq"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *iurlmq = [vars[@"iurlmq"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *iurlsd = [vars[@"iurlsd"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *keywords = [vars[@"keywords"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *duration = vars[@"length_seconds"];
    NSString *videoID = vars[@"video_id"];
    NSString *view_count = vars[@"view_count"];
    /*
     NSString *desc = [[KBYourTube sharedInstance] videoDescription:videoID];
     if (desc != nil)
     {
     self.details = desc;
     }
     */
    self.title = [title stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.author = author;
    NSMutableDictionary *images = [NSMutableDictionary new];
    images[@"high"] = iurlhq;
    images[@"medium"] = iurlmq;
    images[@"standard"] = iurlsd;
    self.images = images;
    self.keywords = keywords;
    self.duration = duration;
    self.videoId = videoID;
    self.views = view_count;
    if (self.keywords == nil){
        self.keywords = @"";
    }
    if (self.views == nil){
        self.views = @"";
    }
    //separate the streams into their initial array
    
    // NSLog(@"StreamMap: %@", streamMap);
    
    NSArray *maps = [[streamMap stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] componentsSeparatedByString:@","];
    NSMutableArray *videoArray = [NSMutableArray new];
    for (NSString *map in maps )
    {
        //same thing, take these raw feeds and make them into an NSDictionary with usable info
        NSMutableDictionary *videoDict = [self parseFlashVars:map];
        //add the title from the previous dictionary created
        [videoDict setValue:title forKey:@"title"];
        //process the raw dictionary into something that can be used with download links and format details
        KBYTStream *processed = [[KBYTStream alloc] initWithDictionary:videoDict];
        //NSDictionary *processed = [self processSource:videoDict];
        if (processed.title != nil)
        {
            self.expireTime = [processed expireTime];
            //if we actually have a video detail dictionary add it to final array
            [videoArray addObject:processed];
        }
    }
    
    //adaptive streams, the higher res stuff (1080p, 1440p, 4K) all generally reside here.
    
    NSArray *adaptiveMaps = [[adaptiveMap stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] componentsSeparatedByString:@","];
    for (NSString *amap in adaptiveMaps )
    {
        //same thing, take these raw feeds and make them into an NSDictionary with usable info
        NSMutableDictionary *videoDict = [self parseFlashVars:amap];
        //NSLog(@"videoDict: %@", videoDict);
        //add the title from the previous dictionary created
        [videoDict setValue:[title stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"title"];
        //process the raw dictionary into something that can be used with download links and format details
        KBYTStream *processed = [[KBYTStream alloc] initWithDictionary:videoDict];
        //if (processed.title != nil)
        // {
        //if we actually have a video detail dictionary add it to final array
        NSLog(@"processed: %@", processed);
        [videoArray addObject:processed];
        //}
    }
    
    
    self.streams = videoArray;
    
    //adaptive streams aren't multiplexed, so we need to match the audio with the video
    
    [self matchAudioStreams];
    
    return TRUE;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    if (self.details == nil)self.details = @"Unavailable";
    if (self.keywords == nil)self.keywords = @"Unavailable";
    if (self.images == nil)self.images = @{};
    if (self.streams == nil)self.streams = @[];
    return @{@"title": self.title, @"author": self.author, @"keywords": self.keywords, @"videoID": self.videoId, @"views": self.views, @"duration": self.duration, @"images": self.images, @"streams": self.streams, @"details": self.details, @"expireTime": [NSNumber numberWithInteger:self.expireTime], @"isExpired": [self expiredString]};
}

- (NSString *)description
{
    return [[self dictionaryRepresentation] description];
    //return [NSString stringWithFormat:@"%@\n\ttitle: %@\n\tauthor: %@\n\tkeywords: %@\n\tvideoID: %@\n\tviews: %@\n\tduration: %@\n\timages: %@\n\tstreams: %@\n",[super description], self.title, self.author, self.keywords, self.videoId, self.views, self.duration, self.images, self.streams];
}

@end

/**
 
 Is it bad form to add categories to NSObject for frequently used convenience methods? probably. does it make
 calling these methods from anywhere incredibly easy? yes. so... DONT CARE :-P
 
 */


@implementation NSObject (convenience)

- (id)recursiveObjectsForKey:(NSString *)desiredKey parent:(id)parent {
    if ([self isKindOfClass:NSDictionary.class]) {
        NSDictionary *dictSelf = (NSDictionary *)self;
        //NSLog(@"dict: %@", dictSelf.allKeys);
        for (NSString *key in dictSelf.allKeys) {
            if ([desiredKey isEqualToString:key]){
                //NSLog(@"got im!: %@", parent);
                return parent ? parent : dictSelf[key];
            } else {
                NSDictionary *dict = dictSelf[key];
                
                if ([dict isKindOfClass:NSDictionary.class] || [dict isKindOfClass:NSArray.class]){
                    //NSLog(@"checking key: %@", key);
                    id obj = [dict recursiveObjectsForKey:desiredKey parent:key];
                    if (obj) {
                        //NSLog(@"found key: %@ in parent: %@", dict, key);
                        //return dict;
                        return obj;
                    }
                }
            }
        }
    } else if ([self isKindOfClass:NSArray.class]){
        NSArray *arraySelf = (NSArray *)self;
        for (NSDictionary *item in arraySelf) {
            if ([item isKindOfClass:NSDictionary.class]){
                id obj = [item recursiveObjectsForKey:desiredKey parent:arraySelf];
                if (obj) {
                    return obj;
                }
                //return [item recursiveObjectForKey:desiredKey];
            }
        }
    } else {
        NSLog(@"%@ is not an NSDictionary or an NSArray, bail!", self);
    }
    
    return nil;
}

- (id)recursiveObjectLikeKey:(NSString *)desiredKey {
    return [self recursiveObjectLikeKey:desiredKey parent:nil];
}

- (id)recursiveObjectLikeKey:(NSString *)desiredKey parent:(id)parent {
    if ([self isKindOfClass:NSDictionary.class]) {
        NSDictionary *dictSelf = (NSDictionary *)self;
        NSPredicate *likePred = [NSPredicate predicateWithFormat:@"self like[c] %@ || self contains[c] %@", desiredKey, desiredKey];
        //NSLog(@"dict: %@", dictSelf.allKeys);
        for (NSString *key in dictSelf.allKeys) {
            if ([likePred evaluateWithObject:key]){
                //DLog(@"got im!: %@", key);
                return dictSelf[key];
            } else {
                NSDictionary *dict = dictSelf[key];
                
                if ([dict isKindOfClass:NSDictionary.class] || [dict isKindOfClass:NSArray.class]){
                    //NSLog(@"checking key: %@", key);
                    id obj = [dict recursiveObjectLikeKey:desiredKey parent:key];
                    if (obj) {
                        //NSLog(@"found key: %@ in parent: %@", [obj valueForKey:@"title"], key);
                        //return dict;
                        return obj;
                    }
                }
            }
        }
    } else if ([self isKindOfClass:NSArray.class]){
        NSArray *arraySelf = (NSArray *)self;
        for (NSDictionary *item in arraySelf) {
            if ([item isKindOfClass:NSDictionary.class]){
                id obj = [item recursiveObjectLikeKey:desiredKey parent:arraySelf];
                if (obj) {
                    return obj;
                }
                //return [item recursiveObjectForKey:desiredKey];
            }
        }
    } else {
        NSLog(@"%@ %@ is not an NSDictionary or an NSArray, bail!", NSStringFromSelector(_cmd), self);
    }
    
    return nil;
}

- (id)recursiveObjectsLikeKey:(NSString *)desiredKey {
    return [self recursiveObjectsLikeKey:desiredKey parent:nil];
}

- (id)recursiveObjectsLikeKey:(NSString *)desiredKey parent:(id)parent {
    if ([self isKindOfClass:NSDictionary.class]) {
        NSDictionary *dictSelf = (NSDictionary *)self;
        NSPredicate *likePred = [NSPredicate predicateWithFormat:@"self like[c] %@ || self contains[c] %@", desiredKey, desiredKey];
        //NSLog(@"dict: %@", dictSelf.allKeys);
        for (NSString *key in dictSelf.allKeys) {
            if ([likePred evaluateWithObject:key]){
                //DLog(@"got im!: %@", key);
                return parent ? parent : dictSelf[key];//return dictSelf[key];
            } else {
                NSDictionary *dict = dictSelf[key];
                
                if ([dict isKindOfClass:NSDictionary.class] || [dict isKindOfClass:NSArray.class]){
                    //NSLog(@"checking key: %@", key);
                    id obj = [dict recursiveObjectsLikeKey:desiredKey parent:key];
                    if (obj) {
                        //NSLog(@"found key: %@ in parent: %@", [obj valueForKey:@"title"], key);
                        //return dict;
                        return obj;
                    }
                }
            }
        }
    } else if ([self isKindOfClass:NSArray.class]){
        NSArray *arraySelf = (NSArray *)self;
        for (NSDictionary *item in arraySelf) {
            if ([item isKindOfClass:NSDictionary.class]){
                id obj = [item recursiveObjectsLikeKey:desiredKey parent:arraySelf];
                if (obj) {
                    return obj;
                }
                //return [item recursiveObjectForKey:desiredKey];
            }
        }
    } else {
        NSLog(@"%@ %@ is not an NSDictionary or an NSArray, bail!", NSStringFromSelector(_cmd), self);
    }
    
    return nil;
}

- (id)recursiveObjectForKey:(NSString *)desiredKey parent:(id)parent {
    if ([self isKindOfClass:NSDictionary.class]) {
        NSDictionary *dictSelf = (NSDictionary *)self;
        //NSLog(@"dict: %@", dictSelf.allKeys);
        for (NSString *key in dictSelf.allKeys) {
            if ([desiredKey isEqualToString:key]){
                //NSLog(@"got im!: %@", parent);
                return dictSelf[key];
            } else {
                NSDictionary *dict = dictSelf[key];
                
                if ([dict isKindOfClass:NSDictionary.class] || [dict isKindOfClass:NSArray.class]){
                    //NSLog(@"checking key: %@", key);
                    id obj = [dict recursiveObjectForKey:desiredKey parent:key];
                    if (obj) {
                        //NSLog(@"found key: %@ in parent: %@", [obj valueForKey:@"title"], key);
                        //return dict;
                        return obj;
                    }
                }
            }
        }
    } else if ([self isKindOfClass:NSArray.class]){
        NSArray *arraySelf = (NSArray *)self;
        for (NSDictionary *item in arraySelf) {
            if ([item isKindOfClass:NSDictionary.class]){
                id obj = [item recursiveObjectForKey:desiredKey parent:arraySelf];
                if (obj) {
                    return obj;
                }
                //return [item recursiveObjectForKey:desiredKey];
            }
        }
    } else {
        NSLog(@"%@ is not an NSDictionary or an NSArray, bail!", self);
    }
    
    return nil;
}

- (void)recursiveInspectObjectLikeKey:(NSString *)desiredKey saving:(NSMutableArray *)array {
    NSPredicate *likePred = [NSPredicate predicateWithFormat:@"self like[c] %@ || self contains[c] %@", desiredKey, desiredKey];
    if ([self isKindOfClass:NSDictionary.class]) {
        NSDictionary *dictSelf = (NSDictionary *)self;
        //NSLog(@"dict: %@", dictSelf.allKeys);
        for (NSString *key in dictSelf.allKeys) {
            if ([likePred evaluateWithObject:key]){
                [array addObject:dictSelf[key]];
                //return dictSelf[key];
            } else {
                NSDictionary *dict = dictSelf[key];
                
                if ([dict isKindOfClass:NSDictionary.class]) {
                    //NSLog(@"checking key: %@", key);
                    id obj = dict[desiredKey];
                    if (obj) {
                        //NSLog(@"found key: %@ in parent: %@", obj, key);
                        //return dict;
                        [array addObject:obj];
                        //return obj;
                    } else {
                        //DLog(@"inspecting: %@", dict);
                        [dict recursiveInspectObjectLikeKey:desiredKey saving:array];
                    }
                } else {
                    if ([dict isKindOfClass:[NSArray class]]){
                        [dict recursiveInspectObjectLikeKey:desiredKey saving:array];
                    }
                }
            }
        }
    } else if ([self isKindOfClass:NSArray.class]){
        NSArray *arraySelf = (NSArray *)self;
        for (NSDictionary *item in arraySelf) {
            if ([item isKindOfClass:NSDictionary.class]){
                [item recursiveInspectObjectLikeKey:desiredKey saving:array];
            }
        }
    } else {
        NSLog(@"%@ is not an NSDictionary or an NSArray, bail!", self);
    }

}

- (void)recursiveInspectObjectForKey:(NSString *)desiredKey saving:(NSMutableArray *)array {
    if ([self isKindOfClass:NSDictionary.class]) {
        NSDictionary *dictSelf = (NSDictionary *)self;
        //NSLog(@"dict: %@", dictSelf.allKeys);
        for (NSString *key in dictSelf.allKeys) {
            if ([desiredKey isEqualToString:key]){
                [array addObject:dictSelf[key]];
                //return dictSelf[key];
            } else {
                NSDictionary *dict = dictSelf[key];
                
                if ([dict isKindOfClass:NSDictionary.class]) {
                    //NSLog(@"checking key: %@", key);
                    id obj = dict[desiredKey];
                    if (obj) {
                        //NSLog(@"found key: %@ in parent: %@", obj, key);
                        //return dict;
                        [array addObject:obj];
                        //return obj;
                    } else {
                        //DLog(@"inspecting: %@", dict);
                        [dict recursiveInspectObjectForKey:desiredKey saving:array];
                    }
                } else {
                    if ([dict isKindOfClass:[NSArray class]]){
                        [dict recursiveInspectObjectForKey:desiredKey saving:array];
                    }
                }
            }
        }
    } else if ([self isKindOfClass:NSArray.class]){
        NSArray *arraySelf = (NSArray *)self;
        for (NSDictionary *item in arraySelf) {
            if ([item isKindOfClass:NSDictionary.class]){
                //NSLog(@"checking item: %@", item);
                id obj = item[desiredKey];
                if (obj) {
                    //NSLog(@"found key: %@", obj);
                    [array addObject:obj];
                    //return obj;
                } else {
                    [item recursiveInspectObjectForKey:desiredKey saving:array];
                }
                //return [item recursiveObjectForKey:desiredKey];
            }
        }
    } else {
        NSLog(@"%@ is not an NSDictionary or an NSArray, bail!", self);
    }

}

- (id)recursiveObjectForKey:(NSString *)desiredKey {
    return [self recursiveObjectForKey:desiredKey parent:nil];
}

- (id)recursiveObjectsForKey:(NSString *)desiredKey {
    return [self recursiveObjectsForKey:desiredKey parent:nil];
}



- (NSString *)downloadFile
{
    return [[self applicationSupportFolder] stringByAppendingPathComponent:@"Downloads.plist"];
}

#pragma mark Parsing & Regex magic

//change a wall of "body" text into a dictionary like &key=value

- (NSMutableDictionary *)parseFlashVars:(NSString *)vars
{
    return [self dictionaryFromString:vars withRegex:@"([^&=]*)=([^&]*)"];
}

- (NSArray *)matchesForString:(NSString *)string withRegex:(NSString *)pattern allRanges:(BOOL)includeAllRanges {
    NSMutableArray *array = [NSMutableArray new];
    NSError *error = NULL;
    NSRange range = NSMakeRange(0, string.length);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines error:&error];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportProgress range:range];
    for (NSTextCheckingResult *entry in matches)
    {
        if (includeAllRanges) {
            for (NSInteger i = 0; i < entry.numberOfRanges; i++) {
                NSRange range = [entry rangeAtIndex:i];
                if (range.location != NSNotFound){
                    NSString *text = [string substringWithRange:range];
                    [array addObject:text];
                }
            }
        } else {
            NSString *text = [string substringWithRange:entry.range];
            [array addObject:text];
        }
    }
    
    return array;
}

//give us the actual matches from a regex, rather then NSTextCheckingResult full of ranges

- (NSArray *)matchesForString:(NSString *)string withRegex:(NSString *)pattern {
    return [self matchesForString:string withRegex:pattern allRanges:false];
}


//the actual function that does the &key=value dictionary creation mentioned above

- (NSMutableDictionary *)dictionaryFromString:(NSString *)string withRegex:(NSString *)pattern
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSArray *matches = [self matchesForString:string withRegex:pattern];
    
    for (NSString *text in matches)
    {
        NSArray *components = [text componentsSeparatedByString:@"="];
        [dict setObject:[components objectAtIndex:1] forKey:[components objectAtIndex:0]];
    }
    
    return dict;
}

//currently unused.
- (NSString *)applicationSupportFolder {
    
    NSFileManager *man = [NSFileManager defaultManager];
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                        NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:
                                                0] : NSTemporaryDirectory();
    if (![man fileExistsAtPath:basePath])
        [man createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    return basePath;
}

- (NSString *)downloadFolder {
    NSString *basePath = [[NSUserDefaults standardUserDefaults] valueForKey:@"downloadLocation"];
    if ([basePath length] > 0)
    {
        return basePath;
    }
    NSFileManager *man = [NSFileManager defaultManager];
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory,
                                        NSUserDomainMask, YES);
    basePath = ([paths count] > 0) ? [paths objectAtIndex:
                                      0] : NSTemporaryDirectory();
    if (![man fileExistsAtPath:basePath])
        [man createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    
    basePath = [basePath stringByAppendingPathComponent:@"yourTubeDownloads"];
    
    if (![man fileExistsAtPath:basePath])
        [man createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    return basePath;
}


@end

@implementation NSDate (convenience)

+ (BOOL)passedEpochDateInterval:(NSTimeInterval)interval
{
    //return true; //force to test to see if it works
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSComparisonResult result = [date compare:[NSDate date]];
    if (result == NSOrderedAscending)
    {
        return true;
    }
    return false;
}


- (NSString *)timeStringFromCurrentDate
{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInt = [currentDate timeIntervalSinceDate:self];
    // NSLog(@"timeInt: %f", timeInt);
    NSInteger minutes = floor(timeInt/60);
    NSInteger seconds = round(timeInt - minutes * 60);
    return [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
    
}

@end

//split a string into an NSArray of characters

@implementation NSString (SplitString)

+ (NSString *)stringFromTimeInterval:(NSTimeInterval)timeInterval
{
    NSInteger interval = timeInterval;
    long seconds = interval % 60;
    long minutes = (interval / 60) % 60;
    long hours = (interval / 3600);
    
    return [NSString stringWithFormat:@"%0.2ld:%0.2ld:%0.2ld", hours, minutes, seconds];
}

- (NSArray *)splitString
{
    NSUInteger index = 0;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.length];
    
    while (index < self.length) {
        NSRange range = [self rangeOfComposedCharacterSequenceAtIndex:index];
        NSString *substring = [self substringWithRange:range];
        [array addObject:substring];
        index = range.location + range.length;
    }
    
    return array;
}

@end

@implementation NSURL (QSParameters)
- (NSArray *)parameterArray {
    
    if (![self query]) return nil;
    NSScanner *scanner = [NSScanner scannerWithString:[self query]];
    if (!scanner) return nil;
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSString *key;
    NSString *val;
    while (![scanner isAtEnd]) {
        if (![scanner scanUpToString:@"=" intoString:&key]) key = nil;
        [scanner scanString:@"=" intoString:nil];
        if (![scanner scanUpToString:@"&" intoString:&val]) val = nil;
        [scanner scanString:@"&" intoString:nil];
        
        key = [key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        val = [val stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if (key) [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                   key, @"key", val, @"value", nil]];
    }
    return array;
}

- (NSDictionary *)parameterDictionary {
    if (![self query]) return nil;
    NSArray *parameterArray = [self parameterArray];
    
    NSArray *keys = [parameterArray valueForKey:@"key"];
    NSArray *values = [parameterArray valueForKey:@"value"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    return dictionary;
}

@end

/**
 
 Meat and potatoes of yourTube, get video details / signature deciphering and helper functions to mux / fix/extract/adjust audio
 
 most things are done through the singleton method.
 
 */



@implementation KBYourTube

@synthesize ytkey, yttimestamp;

- (void) obtainKeyPaths:(id)val intoArray:(NSMutableArray*)arr withString:(NSString*)s {
    if ([val isKindOfClass:[NSDictionary class]]) {
        for (id aKey in [val allKeys]) {
            NSString* path =
                (!s ? aKey : [NSString stringWithFormat:@"%@.%@", s, aKey]);
            [arr addObject: path];
            [self obtainKeyPaths: [val objectForKey:aKey]
                       intoArray: arr
                      withString: path];
        }
    } else {
        
        if ([[val description] containsString:@"shortBylineText"]){
            DLog(@"keypath: %@ is not a dictionary:", s);
            
            NSArray *valArray = (NSArray *)val;
            NSString *fileName = [s stringByAppendingPathExtension:@"plist"];
            DLog(@"fileName: %@", fileName);
            [valArray writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:fileName] atomically:true];
        }
    }
}

- (KBYTWebKitViewController *)webViewController {
    AppDelegate *del = (AppDelegate *)[NSApp delegate];
    return del.webkitController;
}

#pragma mark convenience methods

+ (id)sharedInstance {
    
    static dispatch_once_t onceToken;
    static KBYourTube *shared;
    if (!shared){
        dispatch_once(&onceToken, ^{
            shared = [KBYourTube new];
        });
    }
    
    return shared;
    
}

- (void)enumerateJSONToFindKeys:(id)object forKeyNamed:(NSString *)keyName
{
    if ([object isKindOfClass:[NSDictionary class]])
    {
        // If it's a dictionary, enumerate it and pass in each key value to check
        [object enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
            [self enumerateJSONToFindKeys:value forKeyNamed:key];
        }];
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        // If it's an array, pass in the objects of the array to check
        [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self enumerateJSONToFindKeys:obj forKeyNamed:nil];
        }];
    }
    else
    {
        // If we got here (i.e. it's not a dictionary or array) so its a key/value that we needed
        NSLog(@"We found key %@ with value %@", keyName, object);
    }
}

- (ONOXMLDocument *)documentFromURL:(NSString *)theURL
{
    //<li><div class="display-message"
    NSString *rawRequestResult = [self stringFromRequest:theURL];
    return [ONOXMLDocument HTMLDocumentWithString:rawRequestResult encoding:NSUTF8StringEncoding error:nil];
}


- (BOOL)isSignedIn
{
    ONOXMLDocument *xmlDoc = [self documentFromURL:@"https://www.youtube.com/feed/history"];
    ONOXMLElement *root = [xmlDoc rootElement];
    ONOXMLElement * displayMessage = [root firstChildWithXPath:@"//div[contains(@class, 'display-message')]"];
    NSString *displayMessageString = [displayMessage stringValue];
    NSString *checkString = @"Watch History isn't viewable when signed out.";
    if ([displayMessageString rangeOfString:checkString].location != NSNotFound)
    {
        return true;
    }
    return false;
}


- (NSString *)stringFromPostRequest:(NSString *)url withParams:(NSDictionary *)params {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:10];
    
    NSURLResponse *response = nil;
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSData *json = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingFragmentsAllowed error:nil];
    [request setHTTPBody:json];
    //[request setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 8_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12B410 Safari/600.1.4" forHTTPHeaderField:@"User-Agent"];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
}

- (void) stringFromRequest:(NSString *)urlString completionBlock:(void (^)(NSString *string)) completionBlock {
    NSURL *url = [NSURL URLWithString: urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completionBlock(nil);
        } else {
            completionBlock([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }
    }];
    
    [task resume];
}


//take a url and get its raw body, then return in string format

- (NSString *)stringFromRequest:(NSString *)url
{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:10];
    
    NSURLResponse *response = nil;
    
    [request setHTTPMethod:@"GET"];
    //[request setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 8_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12B410 Safari/600.1.4" forHTTPHeaderField:@"User-Agent"];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
}

- (NSInteger)resultNumber:(NSString *)html
{
    NSScanner *theScanner;
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString:html];
    while ([theScanner isAtEnd] == NO) {
        
        // find start of tag
        [theScanner scanUpToString:@"first-focus\">About " intoString:NULL] ;
        
        // find end of tag
        [theScanner scanUpToString:@"results" intoString:&text] ;
    }
    
    
    return [[[[[text componentsSeparatedByString:@"About"] lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@"," withString:@""] integerValue];
}

- (NSArray *)ytSearchBasics:(NSString *)html {
    
    NSScanner *theScanner;
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString:html];
    NSMutableArray *theArray = [NSMutableArray new];
    while ([theScanner isAtEnd] == NO) {
        
        // find start of tag
        [theScanner scanUpToString:@"/watch?v=" intoString:NULL] ;
        
        // find end of tag
        [theScanner scanUpToString:@"\"" intoString:&text] ;
        
        NSString *newString = [[text componentsSeparatedByString:@"="] lastObject];
        
        if (![theArray containsObject:newString])
        {
            [theArray addObject:newString];
        }
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        //html = [html stringByReplacingOccurrencesOfString:[ NSString stringWithFormat:@"%@>", text] withString:@" "];
        
    } // while //
    
    return theArray;
    
}

/*
 
 everything before <ol id="item-section" is mostly useless, and everything after the end </ol> is also
 useless. this trims down to just the pertinent info and feeds back the raw string for processing.
 
 */

- (NSString *)rawYTFromHTML:(NSString *)html {
    
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString:html];
    [theScanner scanUpToString:@"<ol id=\"item-section" intoString:NULL];
    [theScanner scanUpToString:@"</ol>" intoString:&text] ;
    return [text stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
}

- (void)getUserDetailsDictionaryWithCompletionBlock:(void(^)(NSDictionary *outputResults))completionBlock
                                       failureBlock:(void(^)(NSString *error))failureBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        @autoreleasepool {
            
            BOOL signedIn = [self isSignedIn];
            NSString *errorString = @"Unknown error occurred";
            NSDictionary *returnDict = nil;
            if (signedIn == true) {
                
                NSString *channelID = [self channelID];
                NSString *userName = [self userNameFromChannelURL:channelID];
                NSArray *playlists = [self playlistArrayFromUserName:userName];
                returnDict = @{@"channelID": channelID, @"userName": userName, @"playlists": playlists};
            } else {
                errorString = @"Not signed in";
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (returnDict != nil)
                {
                    completionBlock(returnDict);
                } else {
                    failureBlock(errorString);
                }
                
                
            });
            
        }
        
    });
}

- (NSString *)channelID
{
    ONOXMLDocument *xmlDoc = [self documentFromURL:@"https://m.youtube.com"];
    ONOXMLElement *root = [xmlDoc rootElement];
    ONOXMLElement *guideSection = [root firstChildWithXPath:@"//li[contains(@class, 'guide-section')]"];
    NSArray *allObjects = [(NSEnumerator *)[guideSection XPath:@".//a[contains(@class, 'guide-item')]"] allObjects];
    if ([allObjects count] > 1)
    {
        ONOXMLElement *channelElement = [allObjects objectAtIndex:1];
        return [[channelElement valueForAttribute:@"href"] lastPathComponent];
    }
    return nil;
}

- (NSString *)userNameFromChannelURL:(NSString *)channelURL
{
    ONOXMLDocument *xmlDoct = [self documentFromURL:[NSString stringWithFormat:@"https://m.youtube.com/channel/%@", channelURL]];
    ONOXMLElement *root = [xmlDoct rootElement];
    ONOXMLElement *canon = [root firstChildWithXPath:@"//link[contains(@rel, 'canonical')]"];
    return [[canon valueForAttribute:@"href"] lastPathComponent];
}

- (NSArray *)channelArrayFromUserName:(NSString *)userName
{
    ONOXMLDocument *xmlDoct = [self documentFromURL:[NSString stringWithFormat:@"https://m.youtube.com/%@/channels?view=56&shelf_id=0", userName]];
    ONOXMLElement *root = [xmlDoct rootElement];
    // NSLog(@"root: %@", root);
    ONOXMLElement *playlistGroup = [root firstChildWithXPath:@"//ul[contains(@id, 'channels-browse-content-grid')]"];
    id playlistEnum = [playlistGroup XPath:@".//li[contains(@class, 'channels-content-item')]"];
    ONOXMLElement *playlistElement = nil;
    NSMutableArray *finalArray = [NSMutableArray new];
    while (playlistElement = [playlistEnum  nextObject])
    {
        ONOXMLElement *thumbElement = [[[playlistElement firstChildWithXPath:@".//span[contains(@class, 'yt-thumb-clip')]"] children ] firstObject];
        ONOXMLElement *playlistTitleElement = [[[playlistElement firstChildWithXPath:@".//*[contains(@class, 'yt-lockup-title')]"]children ] firstObject] ;
        NSString *thumbPath = [thumbElement valueForAttribute:@"src"];
        NSString *playlistTitle = [playlistTitleElement valueForAttribute:@"title"];
        NSString *playlistURL = [playlistTitleElement valueForAttribute:@"href"];
        NSDictionary *playlistItem = @{@"thumbURL": thumbPath, @"title": playlistTitle, @"URL": playlistURL};
        [finalArray addObject:playlistItem];
        
    }
    return finalArray;
}


- (NSArray *)playlistArrayFromUserName:(NSString *)userName
{
    ONOXMLDocument *xmlDoct = [self documentFromURL:[NSString stringWithFormat:@"https://m.youtube.com/%@/playlists?sort=da&flow=grid&view=1", userName]];
    ONOXMLElement *root = [xmlDoct rootElement];
    // NSLog(@"root: %@", root);
    ONOXMLElement *playlistGroup = [root firstChildWithXPath:@"//ul[contains(@id, 'channels-browse-content-grid')]"];
    id playlistEnum = [playlistGroup XPath:@".//li[contains(@class, 'channels-content-item')]"];
    ONOXMLElement *playlistElement = nil;
    NSMutableArray *finalArray = [NSMutableArray new];
    while (playlistElement = [playlistEnum  nextObject])
    {
        ONOXMLElement *thumbElement = [[[playlistElement firstChildWithXPath:@".//span[contains(@class, 'yt-thumb-clip')]"] children ] firstObject];
        ONOXMLElement *playlistTitleElement = [[[playlistElement firstChildWithXPath:@".//*[contains(@class, 'yt-lockup-title')]"]children ] firstObject] ;
        NSString *thumbPath = [thumbElement valueForAttribute:@"src"];
        NSString *playlistTitle = [playlistTitleElement valueForAttribute:@"title"];
        NSString *playlistURL = [playlistTitleElement valueForAttribute:@"href"];
        NSDictionary *playlistItem = @{@"thumbURL": thumbPath, @"title": playlistTitle, @"URL": playlistURL};
        [finalArray addObject:playlistItem];
        
    }
    return finalArray;
}


- (KBYTSearchResult *)searchResultFromVideoRenderer:(NSDictionary *)current {
    NSString *lengthText = current[@"lengthText"][@"simpleText"];
    if (!lengthText){
        lengthText = [[current recursiveObjectForKey:@"thumbnailOverlayTimeStatusRenderer"] recursiveObjectForKey:@"simpleText"];
        if ([lengthText isEqualToString:@"UPCOMING"]){
            //DLog(@"%@", current);
        }
    }
    NSDictionary *title = current[@"title"];
    NSString *fullTitle = [title recursiveObjectForKey:@"text"];
    if (!fullTitle) {
        fullTitle = [title recursiveObjectForKey:@"simpleText"];
    }
    NSString *vid = current[@"videoId"];
    NSString *viewCountText = current[@"viewCountText"][@"simpleText"];
    NSArray *thumbnails = current[@"thumbnail"][@"thumbnails"];
    NSDictionary *longBylineText = current[@"longBylineText"];
    if (!longBylineText) {
        longBylineText = [current recursiveObjectForKey:@"shortBylineText"];
    }
    NSDictionary *ownerText = current[@"ownerText"];
    if (!ownerText) {
        ownerText = longBylineText;
    }
    //current[@"publishedTimeText"][@"simpleText"];
    KBYTSearchResult *searchItem = [KBYTSearchResult new];
    searchItem.details = [longBylineText recursiveObjectForKey:@"text"];
    searchItem.author = [ownerText recursiveObjectForKey:@"text"];
    searchItem.title = fullTitle;
    searchItem.duration = lengthText;
    searchItem.videoId = vid;
    searchItem.views = viewCountText;
    searchItem.age = current[@"publishedTimeText"][@"simpleText"];
    searchItem.imagePath = thumbnails.lastObject[@"url"];
    searchItem.resultType = kYTSearchResultTypeVideo;
    return searchItem;
}

- (void)getChannelVideosAlt:(NSString *)channelID
          completionBlock:(void(^)(KBYTChannel *channel))completionBlock
             failureBlock:(void(^)(NSString *error))failureBlock
{
    [self getChannelVideosAlt:channelID continuation:nil completionBlock:completionBlock failureBlock:failureBlock];
}

- (void)getChannelVideosAlt:(NSString *)channelID
               continuation:(NSString *)continuationToken
          completionBlock:(void(^)(KBYTChannel *channel))completionBlock
             failureBlock:(void(^)(NSString *error))failureBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        @autoreleasepool {
            NSString *url = [self browseURL];
            //get the post body from the url above, gets the initial raw info we work with
            NSDictionary *params = [self paramsForChannelID:channelID continuation:continuationToken];
            NSString *body = [self stringFromPostRequest:url withParams:params];
            NSData *jsonData = [body dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments|NSJSONReadingMutableLeaves error:nil];
            //NSLog(@"[tuyu] params: %@", params);
            //NSLog(@"body: %@ for: %@ %@", jsonDict, url, params);
            //NSMutableArray* arr = [NSMutableArray array];
            //[self obtainKeyPaths:jsonDict intoArray:arr withString:nil];
            //NSLog(@"[tuyu] file: %@", [NSHomeDirectory() stringByAppendingPathComponent:@"channelAlt.plist"]);
            
            //[jsonDict writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"channelAlt.plist"] atomically:true];
            
            id cc = [jsonDict recursiveObjectForKey:@"continuationCommand"];
            __block NSMutableArray *items = [NSMutableArray new];
            __block NSMutableArray *playlists = [NSMutableArray new];
            
            NSDictionary *details = [jsonDict recursiveObjectForKey:@"topicChannelDetailsRenderer"];
            if (!details) {
                details = [jsonDict recursiveObjectForKey:@"channelMetadataRenderer"];
                //DLog(@"details: %@", details);
            }
            NSDictionary *title = [details recursiveObjectForKey:@"title"];
            NSDictionary *subtitle = [details recursiveObjectForKey:@"subtitle"];
            NSArray *thumbnails = [details recursiveObjectForKey:@"thumbnails"];
            KBYTChannel *channel = [KBYTChannel new];
            if ([title isKindOfClass:[NSDictionary class]]){
                channel.title = title[@"simpleText"];
            } else {
                channel.title = (NSString *)title;
            }
            if (!subtitle){
                channel.subtitle = details[@"description"];
            } else {
                channel.subtitle = subtitle[@"simpleText"];
            }
            channel.image = thumbnails.lastObject[@"url"];
            channel.url = [details recursiveObjectForKey:@"navigationEndpoint"][@"browseEndpoint"][@"canonicalBaseUrl"];
            channel.continuationToken = cc[@"token"];
            //DLog(@"details: %@", details);
            //title,subtitle,thumbnails
            
            NSMutableArray *vrArray = [NSMutableArray new];
            [jsonDict recursiveInspectObjectLikeKey:@"videoRenderer" saving:vrArray];
            NSMutableArray *plArray = [NSMutableArray new];
            [jsonDict recursiveInspectObjectLikeKey:@"stationRenderer" saving:plArray];
            if ([vrArray count] > 0){
                [vrArray enumerateObjectsUsingBlock:^(id  _Nonnull video, NSUInteger idx, BOOL * _Nonnull stop) {
                    KBYTSearchResult *result = [self searchResultFromVideoRenderer:video];
                    //DLog(@"shelf item %lu subindex %lu is a video object", idx, idx2);
                    [items addObject:result];
                    //DLog(@"result: %@", result);
                    
                }];
            }
            
            if ([plArray count] > 0){
                [plArray enumerateObjectsUsingBlock:^(id  _Nonnull playlist, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSDictionary *title = [playlist recursiveObjectForKey:@"title"];
                    NSString *cis = [playlist recursiveObjectForKey:@"playlistId"];
                    NSArray *thumbnails = playlist[@"thumbnail"][@"thumbnails"];
                    NSDictionary *desc = playlist[@"description"];
                    KBYTSearchResult *searchItem = [KBYTSearchResult new];
                    searchItem.title = title[@"simpleText"];
                    searchItem.videoId = cis;
                    searchItem.imagePath = thumbnails.lastObject[@"url"];
                    searchItem.resultType = kYTSearchResultTypePlaylist;
                    searchItem.details = [desc recursiveObjectForKey:@"simpleText"];
                    [playlists addObject:searchItem];
                    //DLog(@"result: %@", searchItem);
                    
                }];
            }
            channel.channelID = channelID;
            channel.videos = items;
            channel.playlists = playlists;
            //get the post body from the url above, gets the initial raw info we work with
            if (completionBlock) {
                completionBlock(channel);
            }
        }
    });
    
}


- (void)getPlaylistVideos:(NSString *)listID
             continuation:(NSString *)continuationToken
          completionBlock:(void(^)(KBYTPlaylist *playlist))completionBlock
             failureBlock:(void(^)(NSString *error))failureBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        @autoreleasepool {
            NSString *errorString = nil;
            NSString *url = [self nextURL];
            //NSLog(@"url: %@", url);
            //get the post body from the url above, gets the initial raw info we work with
            NSDictionary *params = [self paramsForPlaylist:listID continuation:continuationToken];
            NSString *body = [self stringFromPostRequest:url withParams:params];
            NSData *jsonData = [body dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments|NSJSONReadingMutableLeaves error:nil];
            //NSLog(@"body: %@ for: %@ %@", jsonDict, url, params);
            NSMutableArray *vrArray = [NSMutableArray new];
            [jsonDict recursiveInspectObjectLikeKey:@"videoRenderer" saving:vrArray];
            //        DLog(@"array: %lu", vrArray.count);
            __block NSMutableArray *videos = [NSMutableArray new];
            KBYTPlaylist *playlist = [KBYTPlaylist new];
            id cc = [jsonDict recursiveObjectForKey:@"continuationCommand"];
            playlist.playlistID = listID;
            //NSLog(@"[tuyu] cc: %@", cc);
            playlist.continuationToken = cc[@"token"];
            NSDictionary *plRoot = [jsonDict recursiveObjectForKey:@"playlist"][@"playlist"];
            if (plRoot) {
                NSString *owner = [plRoot recursiveObjectForKey:@"ownerName"][@"simpleText"];
                NSString *title = plRoot[@"title"];
                //NSLog(@"owner: %@ title: %@", owner, title);
                playlist.owner = owner;
                playlist.title = title;
            }
            if ([vrArray count] > 0){
                [vrArray enumerateObjectsUsingBlock:^(id  _Nonnull video, NSUInteger idx, BOOL * _Nonnull stop) {
                    KBYTSearchResult *result = [self searchResultFromVideoRenderer:video];
                    //DLog(@"shelf item %lu subindex %lu is a video object", idx, idx2);
                    [videos addObject:result];
                    //DLog(@"result: %@", result);
                    
                }];
            }
            playlist.videos = videos;
            
            //NSLog(@"videos: %@", videos);
            //NSLog(@"root info: %@", rootInfo);
            dispatch_async(dispatch_get_main_queue(), ^{
                if(jsonDict != nil) {
                    completionBlock(playlist);
                } else {
                    failureBlock(errorString);
                }
            });
        }
    });
    
}
- (void)getPlaylistVideos:(NSString *)listID
          completionBlock:(void(^)(KBYTPlaylist *playlist))completionBlock
             failureBlock:(void(^)(NSString *error))failureBlock
{
    [self getPlaylistVideos:listID continuation:nil completionBlock:completionBlock failureBlock:failureBlock];
}


- (NSString *)attemptConvertImagePathToHiRes:(NSString *)imagePath
{
    if ([imagePath rangeOfString:@"custom=true"].location == NSNotFound)
    {
        return imagePath;
    }
    NSURLComponents *comp = [[NSURLComponents alloc] initWithString:imagePath];
    
    NSMutableArray <NSURLQueryItem*> *newQuery = [[comp queryItems] mutableCopy];
    [[comp queryItems] enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *key = [obj name];
        if ([key isEqualToString:@"w"])
        {
            NSURLQueryItem *new = [NSURLQueryItem queryItemWithName:key value:@"640"];
            [newQuery replaceObjectAtIndex:idx withObject:new];
        } else if ([key isEqualToString:@"h"])
        {
            NSURLQueryItem *new = [NSURLQueryItem queryItemWithName:key value:@"480"];
            [newQuery replaceObjectAtIndex:idx withObject:new];
        }
        
    }];
    comp.queryItems = newQuery;
    return comp.URL.absoluteString;
}


//playlists?view=1&sort=dd

- (void)getChannelPlaylists:(NSString *)channelID
            completionBlock:(void(^)(NSDictionary *searchDetails))completionBlock
               failureBlock:(void(^)(NSString *error))failureBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        @autoreleasepool {
            NSString *requestString = [NSString stringWithFormat:@"https://www.youtube.com/channel/%@/playlists?view=1&sort=dd", channelID];
            NSString *rawRequestResult = [self stringFromRequest:requestString];
            ONOXMLDocument *xmlDoc = [ONOXMLDocument HTMLDocumentWithString:rawRequestResult encoding:NSUTF8StringEncoding error:nil];
            ONOXMLElement *root = [xmlDoc rootElement];
            // NSLog(@"root element: %@", root);
            ONOXMLElement *headerSection = [root firstChildWithXPath:@"//div[contains(@id, 'gh-banner')]"];
            NSString *headerString = [[[headerSection children] firstObject] stringValue];
            NSScanner *bannerScanner = [NSScanner scannerWithString:headerString];
            NSString *headerBanner = nil;
            [bannerScanner scanUpToString:@");" intoString:&headerBanner];
            headerBanner = [[headerBanner componentsSeparatedByString:@"//"] lastObject];
            headerBanner = [@"https://" stringByAppendingString:headerBanner];
            ONOXMLElement *videosElement = [root firstChildWithXPath:@"//*[contains(@class, 'channels-browse-content-grid')]"];
            id videoEnum = [videosElement XPath:@"//div[contains(@class, 'yt-lockup-video')]"];
            ONOXMLElement *currentElement = nil;
            NSMutableArray *finalArray = [NSMutableArray new];
            NSMutableDictionary *outputDict = [NSMutableDictionary new];
            ONOXMLElement *channelNameElement = [root firstChildWithXPath:@"//meta[contains(@name, 'title')]"];
            ONOXMLElement *channelDescElement = [root firstChildWithXPath:@"//meta[contains(@name, 'description')]"];
            ONOXMLElement *channelKeywordsElement = [root firstChildWithXPath:@"//meta[contains(@name, 'keywords')]"];
            ONOXMLElement *channelSubscribersElement = [root firstChildWithXPath:@"//span[contains(@class, 'yt-subscription-button-subscriber-count-branded-horizontal')]"];
            if (channelSubscribersElement != nil)
            {
                outputDict[@"subscribers"] = [channelSubscribersElement valueForAttribute:@"aria-label"];
            }
            if (channelNameElement != nil)
            {
                outputDict[@"name"] = [channelNameElement valueForAttribute:@"content"];
            }
            if (channelDescElement != nil)
            {
                outputDict[@"description"] = [channelDescElement valueForAttribute:@"content"];
            }
            if (channelKeywordsElement != nil)
            {
                outputDict[@"keywords"] = [channelKeywordsElement valueForAttribute:@"content"];
            }
            if (headerBanner != nil)
            {
                outputDict[@"banner"] = headerBanner;
            }
            while (currentElement = [videoEnum nextObject])
            {
                //NSMutableDictionary *scienceDict = [NSMutableDictionary new];
                KBYTSearchResult *result = [KBYTSearchResult new];
                result.resultType = kYTSearchResultTypeVideo;
                NSString *videoID = [currentElement valueForAttribute:@"data-context-item-id"];
                if (videoID != nil)
                {
                    result.videoId = videoID;
                }
                ONOXMLElement *thumbNailElement = [[[currentElement firstChildWithXPath:@".//*[contains(@class, 'yt-thumb-clip')]"] children] firstObject];
                ONOXMLElement *lengthElement = [currentElement firstChildWithXPath:@".//*[contains(@class, 'video-time')]"];
                ONOXMLElement *titleElement = [currentElement firstChildWithXPath:@".//*[contains(@class, 'yt-lockup-title')]"];
                ;
                ONOXMLElement *descElement = [currentElement firstChildWithXPath:@".//*[contains(@class, 'yt-lockup-description')]"];
                ONOXMLElement *authorElement = [[[currentElement firstChildWithXPath:@".//*[contains(@class, 'yt-lockup-byline')]"] children] firstObject];
                ONOXMLElement *ageAndViewsElement = [currentElement firstChildWithXPath:@".//*[contains(@class, 'yt-lockup-meta-info')]"];//yt-lockup-meta-info
                NSString *imagePath = [thumbNailElement valueForAttribute:@"data-thumb"];
                if (imagePath == nil)
                {
                    imagePath = [thumbNailElement valueForAttribute:@"src"];
                }
                if (imagePath != nil)
                {
                    result.imagePath = [@"https:" stringByAppendingString:imagePath];
                }
                if (lengthElement != nil)
                    result.duration = lengthElement.stringValue;
                
                if (titleElement != nil)
                {
                    NSString *title = [[titleElement stringValue] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    result.title = [[title componentsSeparatedByString:@"-"] firstObject];
                    
                }
                
                NSString *vdesc = [[descElement stringValue] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                if (vdesc != nil)
                {
                    result.details = [vdesc stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                }
                
                if (authorElement != nil)
                {
                    result.author = [authorElement stringValue];
                }
                for (ONOXMLElement *currentElement in [ageAndViewsElement children])
                {
                    NSString *currentValue = [currentElement stringValue];
                    if ([currentValue containsString:@"ago"]) //age
                    {
                        result.age = currentValue;
                    } else if ([currentValue containsString:@"views"])
                    {
                        result.views = [[currentValue componentsSeparatedByString:@" "] firstObject];
                    }
                }
                
                if (result.videoId.length > 0 && ![[[result author] lowercaseString] isEqualToString:@"ad"])
                {
                    //NSLog(@"result: %@", result);
                    [finalArray addObject:result];
                } else {
                    result = nil;
                }
                if ([finalArray count] > 0)
                {
                    ONOXMLElement *loadMoreButton = [root firstChildWithXPath:@"//button[contains(@class, 'load-more-button')]"];
                    NSString *loadMoreHREF = [loadMoreButton valueForAttribute:@"data-uix-load-more-href"];
                    if (loadMoreHREF != nil){
                        outputDict[@"loadMoreREF"] = loadMoreHREF;
                    }
                    outputDict[@"results"] = finalArray;
                    outputDict[@"resultCount"] = [NSNumber numberWithInteger:[finalArray count]];
                    NSInteger pageCount = 1;
                    outputDict[@"pageCount"] = [NSNumber numberWithInteger:pageCount];
                }
            }
            NSString *errorString = @"failed to get featured details";
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if([finalArray count] > 0)
                {
                    completionBlock(outputDict);
                } else {
                    failureBlock(errorString);
                }
            });
        }
    });
}



- (void)getChannelVideos:(NSString *)channelID
            continuation:(NSString *)continuationToken
         completionBlock:(void (^)(KBYTChannel *))completionBlock
            failureBlock:(void (^)(NSString *))failureBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        @autoreleasepool {
            NSString *newChannelID = [NSString stringWithFormat:@"UU%@", [channelID substringFromIndex:2]];
            NSLog(@"oldChannelID: %@ new: %@", channelID, newChannelID);
            NSString *requestString = [NSString stringWithFormat:@"https://www.youtube.com/channel/%@/videos", channelID];
            NSString *rawRequestResult = [self stringFromRequest:requestString];
            ONOXMLDocument *xmlDoc = [ONOXMLDocument HTMLDocumentWithString:rawRequestResult encoding:NSUTF8StringEncoding error:nil];
            ONOXMLElement *root = [xmlDoc rootElement];
            // NSLog(@"root element: %@", root);//"meta[property=\"og:url\"]"
            ONOXMLElement *url = [root firstChildWithXPath:@"//meta[contains(@property, 'og:url')]"];
            ONOXMLElement *title = [root firstChildWithXPath:@"//meta[contains(@property, 'og:title')]"];
            ONOXMLElement *image = [root firstChildWithXPath:@"//meta[contains(@property, 'og:image')]"];
            NSString *finalURL = [url valueForAttribute:@"content"];
            NSString *finalTitle = [title valueForAttribute:@"content"];
            NSString *finalImage = [image valueForAttribute:@"content"];
            NSLog(@"url: %@ title: %@ image: %@", finalURL, finalTitle, finalImage);
            KBYTChannel *channel = [KBYTChannel new];
            channel.title = finalTitle;
            channel.url = finalURL;
            channel.image = finalImage;
            channel.channelID = channelID;
            /*
            id ogEnum = [root XPath:@"//meta[contains(@property, 'og:')]"];
            ONOXMLElement *currentElement = nil;
            while (currentElement = [ogEnum nextObject]) {
                NSLog(@"og: %@", currentElement);
            }*/
            
            //get the post body from the url above, gets the initial raw info we work with
            [self getPlaylistVideos:newChannelID continuation:continuationToken completionBlock:^(KBYTPlaylist *playlist) {
                NSLog(@"[tuyu] got playlist: %@", playlist);
                channel.videos = playlist.videos;
                channel.continuationToken = playlist.continuationToken;
                completionBlock(channel);
            } failureBlock:^(NSString *error) {
                failureBlock(nil);
            }];
        }
    });
    
}

- (void)getChannelVideos:(NSString *)channelID
          completionBlock:(void(^)(KBYTChannel *channel))completionBlock
            failureBlock:(void(^)(NSString *error))failureBlock {
    [self getChannelVideos:channelID continuation:nil completionBlock:completionBlock failureBlock:failureBlock];
}


#pragma mark video details

- (void)getVideoDetailsForIDs:(NSArray*)videoIDs
              completionBlock:(void(^)(NSArray* videoArray))completionBlock
                 failureBlock:(void(^)(NSString* error))failureBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        @autoreleasepool {
            NSMutableArray *finalArray = [NSMutableArray new];
            //NSMutableDictionary *rootInfo = [NSMutableDictionary new];
            NSString *errorString = nil;
            
            for (NSString *videoID in videoIDs) {
                
                NSString *url = [self playerURL];
                //NSLog(@"url: %@", url);
                //get the post body from the url above, gets the initial raw info we work with
                NSDictionary *params = [self paramsForVideo:videoID];
                NSString *body = [self stringFromPostRequest:url withParams:params];
                NSData *jsonData = [body dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments|NSJSONReadingMutableLeaves error:nil];
                KBYTMedia *currentMedia = [[KBYTMedia alloc] initWithJSON:jsonDict];
                [finalArray addObject:currentMedia];
             
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if([finalArray count] > 0)
                {
                    completionBlock(finalArray);
                } else {
                    failureBlock(errorString);
                }
            });
        }
    });
    
}


- (NSString *)nextURL {
    return @"https://www.youtube.com/youtubei/v1/next?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8";
}


- (NSString *)searchURL {
    return @"https://www.youtube.com/youtubei/v1/search?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8";
}

- (NSString *)playerURL {
    return @"https://www.youtube.com/youtubei/v1/player?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8";
}

- (NSString *)browseURL {
    return @"https://www.youtube.com/youtubei/v1/browse?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8";
}


// '{ videoId = xpVfcZ0ZcFM, contentCheckOk = True, racyCheckOk = True, context = { client = { clientName = ANDROID, clientScreen = , clientVersion = 16.46.37, hl = en, gl = US, utcOffsetMinutes = 0 }, thirdParty = { embedUrl = https://www.youtube.com } } }'

- (NSDictionary *)paramsForVideo:(NSString *)videoID {
    return @{ @"videoId": videoID,
              @"contentCheckOk": @"true",
              @"racyCheckOk": @"true",
              @"context":  @{ @"client":
                                  @{ @"clientName": @"ANDROID",
                                     @"clientVersion": @"16.46.37",
                                     @"hl": @"en",
                                     @"gl": @"US",
                                     @"utcOffsetMinutes": @0 },
                              @"thirdParty": @{ @"embedUrl": @"https://www.youtube.com" } } };
}

- (NSDictionary *)paramsForSearch:(NSString *)query {
    return [self paramsForSearch:query forType:KBYTSearchTypeAll continuation:nil];
}

- (NSString *)paramForType:(KBYTSearchType)type {
    switch (type) {
        case KBYTSearchTypeAll: return @"";
        case KBYTSearchTypeVideos: return @"EgIQAQ%3D%3D";
        case KBYTSearchTypePlaylists: return @"EgIQAw%3D%3D";
        case KBYTSearchTypeChannels: return @"EgIQAg%3D%3D";
        default:
            break;
    }
    return nil;
}

/*
 var payload = new
       {
           playlistId = playlistId.Value,
           videoId = videoId?.Value,
           playlistIndex = index,
           context = new
           {
               client = new
               {
                   clientName = "WEB",
                   clientVersion = "2.20210408.08.00",
                   hl = "en",
                   gl = "US",
                   utcOffsetMinutes = 0,
                   visitorData
               }
           }
       };
 */

- (NSDictionary *)paramsForChannelID:(NSString *)channelID continuation:(NSString *)continuationToken {
    if (continuationToken == nil) {
     return @{ @"browseId": channelID,
               @"continuation": @"",
               @"context":  @{ @"client":
                                   @{ @"clientName": @"WEB",
                                      @"clientVersion": @"2.20210408.08.00",
                                      @"hl": @"en",
                                      @"gl": @"US",
                                      @"utcOffsetMinutes": @0 } } };
    }
    return @{ @"browseId": channelID,
              @"continuation": continuationToken,
              @"context":  @{ @"client":
                                  @{ @"clientName": @"WEB",
                                     @"clientVersion": @"2.20210408.08.00",
                                     @"hl": @"en",
                                     @"gl": @"US",
                                     @"utcOffsetMinutes": @0 } } };
}

- (NSDictionary *)paramsForChannelID:(NSString *)channelID {
    return [self paramsForChannelID:channelID continuation:nil];
}

- (NSDictionary *)paramsForPlaylist:(NSString *)playlistID continuation:(NSString *)continuationToken {
    if (continuationToken == nil) continuationToken = @"";
    return @{ @"playlistId": playlistID,
              @"continuation": continuationToken,
              @"context":  @{ @"client":
                                  @{ @"clientName": @"WEB",
                                     @"clientVersion": @"2.20210408.08.00",
                                     @"hl": @"en",
                                     @"gl": @"US",
                                     @"utcOffsetMinutes": @0 } } };
}

- (NSDictionary *)paramsForPlaylist:(NSString *)playlistID {
    return [self paramsForPlaylist:playlistID continuation:nil];
}

- (NSDictionary *)paramsForSearch:(NSString *)query forType:(KBYTSearchType)type continuation:(NSString *)continuationToken {
    if (continuationToken == nil) continuationToken = @"";
    return @{ @"query": query,
              @"params": [self paramForType:type],
              @"continuation": continuationToken,
              @"context":  @{ @"client":
                                  @{ @"clientName": @"WEB",
                                     @"clientVersion": @"2.20210408.08.00",
                                     @"hl": @"en",
                                     @"gl": @"US",
                                     @"utcOffsetMinutes": @0 } } };
}

- (NSDictionary *)oldparamsForVideo:(NSString *)videoID {
    return @{@"context":@{@"client":
                              @{@"hl":@"en",
                                @"clientName": @"WEB",
                                @"clientVersion": @"2.20210721.00.00",
                                @"clientFormFactor": @"UNKNOWN_FORM_FACTOR",
                                @"clientScreen": @"EMBED",
                                @"mainAppWebInfo": @{
                                        @"graftUrl": @"/watch?v=UF8uR6Z6KLc",}
                              },
                          @"user": @{@"lockedSafetyMode": @"false"},
                          @"request": @{@"useSsl": @"true",
                                        @"internalExperimentFlags": @[],
                                        @"consistencyTokenJars": @[]  }},
             @"videoId": videoID,
             @"playbackContext": @{
                     @"contentPlaybackContext":@{@"vis": @0,
                                                 @"splay": @"false",
                                                 @"autoCaptionsDefaultOn": @"false",
                                                 @"autonavState": @"STATE_NONE",
                                                 @"html5Preference": @"HTML5_PREF_WANTS",
                                                 @"lactMilliseconds": @"-1"
                                                 
                                                 
                                                 
                     }},
             @"racyCheckOk": @"false",
             @"contentCheckOk": @"false"
    };
}

/*
 curl 'https://www.youtube.com/youtubei/v1/player?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8' -H 'Content-Type: application/json' --data '
 "request": {      "useSsl": true,      "internalExperimentFlags": [],      "consistencyTokenJars": []  }  },
 "videoId": "6pxRHBw-k8M",
 "playbackContext": {    "contentPlaybackContext": {        "vis": 0,      "splay": false,      "autoCaptionsDefaultOn": false,      "autonavState": "STATE_NONE",      "html5Preference": "HTML5_PREF_WANTS",      "lactMilliseconds": "-1"    }  },
 "racyCheckOk": false,  "contentCheckOk": false}'
 */

//ytInitialPlayerResponse\s\=\s([{$ _A-Za-z0-9\/\.\s\S]+)\}\;
//https://www.youtube.com/watch?v=%@
//            NSString *url = [NSString stringWithFormat:@"https://www.youtube.com/get_video_info?&video_id=%@&%@&sts=%@", videoID, @"eurl=http%3A%2F%2Fwww%2Eyoutube%2Ecom%2F", self.yttimestamp]

- (void)apiSearch:(NSString *)search
             type:(KBYTSearchType)type
     continuation:(NSString *)continuation
  completionBlock:(void(^)(KBYTSearchResults *result))completionBlock
     failureBlock:(void(^)(NSString* error))failureBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        @autoreleasepool {
            NSString *errorString = nil;
            NSString *url = [self searchURL];
            //NSLog(@"url: %@", url);
            //get the post body from the url above, gets the initial raw info we work with
            NSDictionary *params = [self paramsForSearch:search forType:type continuation:continuation];
            NSString *body = [self stringFromPostRequest:url withParams:params];
            NSData *jsonData = [body dataUsingEncoding:NSUTF8StringEncoding];
            id jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments|NSJSONReadingMutableLeaves error:nil];
            //NSLog(@"body: %@ for: %@ %@", jsonDict, url, params);
            
            KBYTSearchResults *results = [KBYTSearchResults new];
            [results processJSON:jsonDict];
            //[body writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"search.json"] atomically:true encoding:NSUTF8StringEncoding error:nil];
            //[jsonDict writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"search.plist"] atomically:true];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(results != nil) {
                    completionBlock(results);
                } else {
                    failureBlock(errorString);
                }
            });
        }
    });
    //
}

- (void)getVideoDetailsForID:(NSString*)videoID
             completionBlock:(void(^)(KBYTMedia* videoDetails))completionBlock
                failureBlock:(void(^)(NSString* error))failureBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        @autoreleasepool {
            KBYTMedia *rootInfo = nil;
            NSString *errorString = nil;
            NSString *url = [self playerURL];
            //NSLog(@"url: %@", url);
            //get the post body from the url above, gets the initial raw info we work with
            NSDictionary *params = [self paramsForVideo:videoID];
            NSString *body = [self stringFromPostRequest:url withParams:params];
            NSData *jsonData = [body dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments|NSJSONReadingMutableLeaves error:nil];
            //NSLog(@"body: %@ for: %@ %@", jsonDict, url, params);
            [jsonDict writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"file2.plist"] atomically:true];
            
            rootInfo = [[KBYTMedia alloc] initWithJSON:jsonDict];
            //NSLog(@"root info: %@", rootInfo);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(rootInfo != nil)
                {
                    completionBlock(rootInfo);
                } else {
                    failureBlock(errorString);
                }
            });
        }
    });
    
}


#pragma mark utility methods

//DASH audio is a weird format, take that aac file and pump out a useable m4a file, with volume adjustment if necessary

- (void)fixAudio:(NSString *)theFile volume:(NSInteger)volume completionBlock:(void(^)(NSString *newFile))completionBlock
{
    //NSLog(@"fix audio: %@", theFile);
    NSString *outputFile = [[theFile stringByDeletingPathExtension] stringByAppendingPathExtension:@"m4a"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        @autoreleasepool {
            NSTask *afcTask = [NSTask new];
            [afcTask setLaunchPath:[[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:@"" inDirectory:@"mux"]];
            //iOS change to /usr/bin/ffmpeg and make sure to depend upon com.nin9tyfour.ffmpeg
            [afcTask setStandardError:[NSFileHandle fileHandleWithNullDevice]];
            [afcTask setStandardOutput:[NSFileHandle fileHandleWithNullDevice]];
            NSMutableArray *args = [NSMutableArray new];
            [args addObject:@"-i"];
            [args addObject:theFile];
            
            if (volume == 0){
                [args addObjectsFromArray:[@"-acodec copy -y" componentsSeparatedByString:@" "]];
            } else {
                [args addObject:@"-vol"];
                [args addObject:[NSString stringWithFormat:@"%ld", (long)volume]];
                [args addObjectsFromArray:[@"-acodec libfdk_aac -ac 2 -ar 44100 -ab 320K -y" componentsSeparatedByString:@" "]];
                //for ios change to
                // -strict -2
                //[args addObjectsFromArray:[@"-acodec aac -ac 2 -ar 44100 -ab 320K -strict -2 -y" componentsSeparatedByString:@" "]]
            }
            [args addObject:outputFile];
            [afcTask setArguments:args];
            //NSLog(@"mux %@", [args componentsJoinedByString:@" "]);
            [afcTask launch];
            [afcTask waitUntilExit];
        }
        
        completionBlock(outputFile);
    });
    
    
}

//currently not used, previously would be used to "extract" audio from a media file

- (void)extractAudio:(NSString *)theFile completionBlock:(void(^)(NSString *newFile))completionBlock
{
    if ([theFile.pathExtension.lowercaseString isEqualToString:@"m4a"])
    {
        completionBlock(theFile);
        return;
    }
    NSString *outputFile = [[theFile stringByDeletingPathExtension] stringByAppendingPathExtension:@"m4a"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        @autoreleasepool {
            NSTask *afcTask = [NSTask new];
            [afcTask setLaunchPath:@"/usr/bin/afconvert"];
            NSMutableArray *args = [NSMutableArray new];
            [args addObject:theFile];
            [args addObject:@"-d"];
            [args addObject:@"aac "];
            [args addObject:@"--soundcheck-generate"];
            [args addObject:@"-b"];
            [args addObject:@"320000"];
            
            [args addObject:outputFile];
            [afcTask setArguments:args];
            [afcTask launch];
            [afcTask waitUntilExit];
        }
        
        completionBlock(outputFile);
    });
    
    
}

//useful display details based on the itag
+ (NSDictionary *)formatFromTag:(NSInteger)tag
{
    NSDictionary *dict = nil;
    switch (tag) {
            //MP4
        case 38: dict = @{@"format": @"4K MP4", @"height": @2304, @"extension": @"mp4"}; break;
        case 37: dict = @{@"format": @"1080p MP4", @"height": @1080, @"extension": @"mp4"}; break;
        case 22: dict = @{@"format": @"720p MP4", @"height": @720, @"extension": @"mp4"}; break;
        case 18: dict = @{@"format": @"360p MP4", @"height": @360, @"extension": @"mp4"}; break;
            //FLV
        case 35: dict = @{@"format": @"480p FLV", @"height": @480, @"extension": @"flv"}; break;
        case 34: dict = @{@"format": @"360p FLV", @"height": @360, @"extension": @"flv"}; break;
        case 6: dict = @{@"format": @"270p FLV", @"height": @270, @"extension": @"flv"}; break;
        case 5: dict = @{@"format": @"240p FLV", @"height": @240, @"extension": @"flv"}; break;
            //WebM
        case 46: dict = @{@"format": @"1080p WebM", @"height": @1080, @"extension": @"webm"}; break;
        case 45: dict = @{@"format": @"720p WebM", @"height": @720, @"extension": @"webm"}; break;
        case 44: dict = @{@"format": @"480p WebM", @"height": @480, @"extension": @"webm"}; break;
        case 43: dict = @{@"format": @"360p WebM", @"height": @360, @"extension": @"webm"}; break;
            //3gp
        case 36: dict = @{@"format": @"320p 3GP", @"height": @320, @"extension": @"3gp"}; break;
        case 17: dict = @{@"format": @"176p 3GP", @"height": @176, @"extension": @"3gp"}; break;
            
        case 137: dict = @{@"format": @"1080p M4V", @"height": @1080, @"extension": @"m4v", @"quality": @"adaptive"}; break;
        case 138: dict = @{@"format": @"4K M4V", @"height": @2160, @"extension": @"m4v", @"quality": @"adaptive"}; break;
        case 264: dict = @{@"format": @"1440p M4v", @"height": @1440, @"extension": @"m4v", @"quality": @"adaptive"}; break;
            
        case 266: dict = @{@"format": @"4K M4V", @"height": @2160, @"extension": @"m4v", @"quality": @"adaptive"}; break;
            
        case 299: dict = @{@"format": @"1080p HFR M4V", @"height": @1080, @"extension": @"m4v", @"quality": @"adaptive"}; break;
        case 140: dict = @{@"format": @"128K AAC M4A", @"height": @0, @"extension": @"aac", @"quality": @"adaptive"}; break;
        case 141: dict = @{@"format": @"256K AAC M4A", @"height": @0, @"extension": @"aac", @"quality": @"adaptive"}; break;
            
            //adaptive
            
        case 133: dict = @{@"format": @"240p MP4", @"height": @240, @"extension": @"mp4", @"quality": @"adaptive"}; break;
        case 134: dict = @{@"format": @"360p MP4", @"height": @360, @"extension": @"mp4", @"quality": @"adaptive"}; break;
        case 135: dict = @{@"format": @"480p MP4", @"height": @480, @"extension": @"mp4", @"quality": @"adaptive"}; break;
        case 136: dict = @{@"format": @"720p MP4", @"height": @720, @"extension": @"mp4", @"quality": @"adaptive"}; break;
        case 160: dict = @{@"format": @"144p MP4", @"height": @144, @"extension": @"mp4", @"quality": @"adaptive"}; break;
            
        case 242: dict = @{@"format": @"240p WebM", @"height": @240, @"extension": @"WebM", @"quality": @"adaptive"}; break;
        case 243: dict = @{@"format": @"360p WebM", @"height": @360, @"extension": @"WebM", @"quality": @"adaptive"}; break;
        case 244: dict = @{@"format": @"480p WebM", @"height": @480, @"extension": @"WebM", @"quality": @"adaptive"}; break;
        case 247: dict = @{@"format": @"720p WebM", @"height": @720, @"extension": @"WebM", @"quality": @"adaptive"}; break;
        case 278: dict = @{@"format": @"144p WebM", @"height": @144, @"extension": @"WebM", @"quality": @"adaptive"}; break;
            
        case 298: dict = @{@"format": @"720p HFR MP4", @"height": @720, @"extension": @"mp4", @"quality": @"adaptive"}; break;
            
            
        case 302: dict = @{@"format": @"720p HFR WebM", @"height": @720, @"extension": @"WebM", @"quality": @"adaptive"}; break;
        case 303: dict = @{@"format": @"1080p HFR WebM", @"height": @1080, @"extension": @"WebM", @"quality": @"adaptive"}; break;
            
            //audio
            
        case 171: dict = @{@"format": @"128K Vorbis WebM", @"height": @0, @"extension": @"WebMa", @"quality": @"adaptive"}; break;
        case 249: dict = @{@"format": @"48K Opus WebM", @"height": @0, @"extension": @"WebMa", @"quality": @"adaptive"}; break;
        case 250: dict = @{@"format": @"64K Opus WebM", @"height": @0, @"extension": @"WebMa", @"quality": @"adaptive"}; break;
        case 251: dict = @{@"format": @"160K Opus WebM", @"height": @0, @"extension": @"WebMa", @"quality": @"adaptive"}; break;
        case 248: return @{@"format":@"VP9/V_VP9/1920x1080/29.97fps WebM",@"height":@1080,@"extension":@"WebM",@"quality":@"adaptive"};
        case 271: return @{@"format":@"VP9/V_VP9/2560x1440/29.97fps WebM",@"height":@1440,@"extension":@"WebM",@"quality":@"adaptive"};
        case 272: return @{@"format":@"VP9/V_VP9/GREATERTHAN4K/59.88fps WebM",@"height":@2880,@"extension":@"WebM",@"quality":@"adaptive"};
        case 308: return @{@"format":@"VP9/V_VP9/2560x1440/59.88fps WebM",@"height":@1440,@"extension":@"WebM",@"quality":@"adaptive"};
        case 313: return @{@"format":@"VP9/V_VP9/3840x2160/29.97fps WebM",@"height":@2160,@"extension":@"WebM",@"quality":@"adaptive"};
        case 315: return @{@"format":@"VP9/V_VP9/3840x2160/59.94fps WebM",@"height":@2160,@"extension":@"WebM",@"quality":@"adaptive"};
        case 330: return @{@"format":@"VP9/V_VP9/256x144/59.88fps WebM",@"height":@144,@"extension":@"WebM",@"quality":@"adaptive"};
        case 331: return @{@"format":@"VP9/V_VP9/426x240/59.88fps WebM",@"height":@240,@"extension":@"WebM",@"quality":@"adaptive"};
        case 332: return @{@"format":@"VP9/V_VP9/640x360/59.88fps WebM",@"height":@360,@"extension":@"WebM",@"quality":@"adaptive"};
        case 333: return @{@"format":@"VP9/V_VP9/854x480/59.88fps WebM",@"height":@480,@"extension":@"WebM",@"quality":@"adaptive"};
        case 334: return @{@"format":@"VP9/V_VP9/1280x720/59.88fps WebM",@"height":@720,@"extension":@"WebM",@"quality":@"adaptive"};
        case 335: return @{@"format":@"VP9/V_VP9/1920x1080/59.88fps WebM",@"height":@1080,@"extension":@"WebM",@"quality":@"adaptive"};
        case 336: return @{@"format":@"VP9/V_VP9/2560x1440/59.88fps WebM",@"height":@1440,@"extension":@"WebM",@"quality":@"adaptive"};
        case 337: return @{@"format":@"VP9/V_VP9/3840x2160/59.88fps WebM",@"height":@2160,@"extension":@"WebM",@"quality":@"adaptive"};
        case 398: return @{@"format":@"720p MP4", @"height": @480, @"extension": @"m4v", @"quality": @"adaptive"};
        case 399: return @{@"format":@"1080p MP4", @"height": @720, @"extension": @"m4v", @"quality": @"adaptive"};
        case 400: return @{@"format":@"1440p MP4", @"height": @1080, @"extension": @"m4v", @"quality": @"adaptive"};
        case 401: return @{@"format":@"2160p MP4", @"height": @1440, @"extension": @"m4v", @"quality": @"adaptive"};
            /*
             136=720p MP4
             247=720p WebM
             135=480p MP4
             244=480p WebM
             134=360p MP4
             243=360p WebM
             133=240p MP4
             242=240p WebM
             160=144p MP4
             278=144p WebM
             
             140=AAC M4A 128K
             171=WebM Vorbis 128
             249=WebM Opus 48
             250=WebM Opus 64
             251=WebM Opus 160
             
             299=1080p HFR MP4
             303=1080p HFR WebM
             298=720P HFR MP4
             302=720P HFR VP9 WebM*/
            
        default:
            break;
    }
    
    return dict;
}

//takes audio and video files and multiplexes them, would like to use mp4box instead if i can figure out how..

- (void)muxFiles:(NSArray *)theFiles completionBlock:(void(^)(NSString *newFile))completionBlock
{
    NSString *videoFile = [theFiles firstObject];
    NSString *audioFile = [theFiles lastObject];
    NSString *outputFile = [[videoFile stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp4"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        @autoreleasepool {
            NSTask *afcTask = [NSTask new];
            [afcTask setLaunchPath:[[NSBundle mainBundle] pathForResource:@"ffmpeg" ofType:@"" inDirectory:@"mux"]];
            [afcTask setStandardError:[NSFileHandle fileHandleWithNullDevice]];
            [afcTask setStandardOutput:[NSFileHandle fileHandleWithNullDevice]];
            NSMutableArray *args = [NSMutableArray new];
            [args addObject:@"-i"];
            [args addObject:videoFile];
            [args addObject:@"-i"];
            [args addObject:audioFile];
            //
            [args addObjectsFromArray:[@"-vcodec copy -acodec copy -map 0:v:0 -map 1:a:0 -shortest -y" componentsSeparatedByString:@" "]];
            
            [args addObject:outputFile];
            [afcTask setArguments:args];
            NSLog(@"mux %@", [args componentsJoinedByString:@" "]);
            [afcTask launch];
            [afcTask waitUntilExit];
        }
        
        completionBlock(outputFile);
    });
    
    
}

#pragma mark Signature deciphering

/*
 **
 ***
 
 Signature cipher notes
 
 the youtube signature cipher has 3 basic steps (for now) swapping, splicing and reversing
 the notes from youtubedown put it better than i can think to
 
 # - r  = reverse the string;
 # - sN = slice from character N to the end;
 # - wN = swap 0th and Nth character.
 
 they store their key a little differently then the clicktoplugin scripts yourTube code was based on
 
 their "w13 r s3 w2 r s3 w36" is the equivalent to our "13,0,-3,2,0,-3,36"
 
 the functions below take care of all of these steps.
 
 Processing a key example:
 
 13,0,-3,2,0,-3,36 would be processed the following way
 
 13: swap 13 character with character at 0
 0: reverse
 -3: splice from 3 to the end
 2: swap 2nd character with character at 0
 0: reverse
 -3: splice from 3 to the end
 36: swap 36 character with chracter at 0
 
 old sig: B52252CF80D5C2877E88D52375768FE00F29CD28A8B.A7322D9C40F39C2E32D30699152165DA9D282501501
 
 swap 13: B with 2
 swapped: 252252CF80D5CB877E88D52375768FE00F29CD28A8B.A7322D9C40F39C2E32D30699152165DA9D282501501
 
 reversed: 105105282D9AD56125199603D23E2C93F04C9D2237A.B8A82DC92F00EF86757325D88E778BC5D08FC252252
 
 sliced at 3: 105282D9AD56125199603D23E2C93F04C9D2237A.B8A82DC92F00EF86757325D88E778BC5D08FC252252
 
 swap 2: 1 with 5
 swapped: 501282D9AD56125199603D23E2C93F04C9D2237A.B8A82DC92F00EF86757325D88E778BC5D08FC252252
 
 reversed: 252252CF80D5CB877E88D52375768FE00F29CD28A8B.A7322D9C40F39C2E32D30699152165DA9D282105
 
 sliced 3: 252CF80D5CB877E88D52375768FE00F29CD28A8B.A7322D9C40F39C2E32D30699152165DA9D282105
 
 swap 36: 2 with 8
 swapped: 852CF80D5CB877E88D52375768FE00F29CD22A8B.A7322D9C40F39C2E32D30699152165DA9D282105
 
 newsig: 852CF80D5CB877E88D52375768FE00F29CD22A8B.A7322D9C40F39C2E32D30699152165DA9D282105
 
 */

/**
 
 if use_cipher_signature is true the a timestamp and a key are necessary to decipher the signature and re-add it
 to the url for proper playback and download, this method will attempt to grab those values dynamically
 
 for more details look at https://www.jwz.org/hacks/youtubedown and search for this text
 
 24-Jun-2013: When use_cipher_signature=True
 
 didnt want to plagiarize his whole thesis, and its a good explanation of why this is necessary
 
 
 */


- (void)getTimeStampAndKey:(NSString *)videoID
{
    NSString *url = [NSString stringWithFormat:@"https://www.youtube.com/embed/%@", videoID];
    NSString *body = [self stringFromRequest:url];
    //NSLog(@"body: %@", body);
    if (!body) {
        return;
    }
    //the timestamp that is needed for signature deciphering
    
    //self.yttimestamp = [[[[self matchesForString:body withRegex:@"\"sts\":(\\d*)"] lastObject] componentsSeparatedByString:@":"] lastObject];
    //\"jsUrl\":\"([$_A-Za-z0-9\/\.]+)
    //isolate the base.js file that we need to extract the signature from
    
    NSString *baseJSRegex = @"\"jsUrl\":\"([$_A-Za-z0-9\\/\\.]+)";
    
    NSString *match = [[self matchesForString:body withRegex:baseJSRegex allRanges:true] lastObject];
    
    NSLog(@"match: %@", match);
    //return;
    
    NSString *baseJS = [NSString stringWithFormat:@"https://youtube.com%@", match];
    
    NSLog(@"baseJS: %@", baseJS);
    
    //NSString *baseJS = [NSString stringWithFormat:@"https://youtube.com%@", [[[[[self matchesForString:body withRegex:@"\"js\":\"([^\"]*)\""] lastObject] componentsSeparatedByString:@":"] lastObject] stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"]];
    
    //get the raw js source of the decoder file that we need to get the signature cipher from
    
    NSString *jsBody = [self stringFromRequest:[baseJS stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
    
    //NSLog(@"jsBody: %@", jsBody);
    //crazy convoluted regex to get a signature section similiar to this
    //cr.Ww(a,13);cr.W9(a,69);cr.Gz(a,3);cr.Ww(a,2);cr.W9(a,79);cr.Gz(a,3);cr.Ww(a,36);return a.join(
    //sx.Aw(a,65);sx.Aw(a,31);sx.g0(a,33);sx.UG(a,2);sx.g0(a,65);return a.join(
    //#### IGNORE THE WARNING, if the extra escape is added as expected the regex doesnt work!
    ///function[ $_A-Za-z0-9]*\(a\)\{a=a(?:\.split|\[[$_A-Za-z0-9]+\])\(\"\"\);\s*([^"]*)/
    NSString *keyMatch = [[self matchesForString:jsBody withRegex:@"function[ $_A-Za-z0-9]*\\(a\\)\\{a=a(?:\.split|\\[[$_A-Za-z0-9]+\\])\\(\"\"\\);\\s*([^\"]*)" allRanges:false] lastObject];
    
    NSLog(@"keyMatch: %@", keyMatch);
    
    self.yttimestamp = [[[[self matchesForString:jsBody withRegex:@"sts:(\\d*)"] firstObject] componentsSeparatedByString:@":"] lastObject];
    
    if ([keyMatch rangeOfString:@"function"].location != NSNotFound)
    {
        //find first ; and make substring from there.
        NSUInteger loc = [keyMatch rangeOfString:@";"].location;
        DLog(@"loc: %lu", loc);
        keyMatch = [keyMatch substringFromIndex:loc+1];
    }
    //the jsbody is trimmed down to a smaller section to optimize the search to deobfuscate the signature function names
    //^[$_A-Za-z0-9]+
    
    NSString *fnNameMatch = [NSString stringWithFormat:@";var %@={", [[self matchesForString:keyMatch withRegex:@"^[$_A-Za-z0-9]+"] lastObject]];
    
    //NSLog(@"fnNameMatch: %@", fnNameMatch);
    
    //the index to start the new string range from for said optimization above
    
    //  DLog(@"jsbody: %@", jsBody);
    
    NSUInteger index = [jsBody rangeOfString:fnNameMatch].location;
    //NSLog(@"index: %lu", index);
    //smaller string for searching for reverse / splice function names
    NSString *x = jsBody;
    if (index != NSNotFound)
    {
        x = [jsBody substringFromIndex:index];
        //NSLog(@"x: %@", x);
    }
    NSString *a, *tmp, *r, *s = nil;
    
    //next baffling regex used to cycle through which functions names from the match above are linked to reversing and splicing
    NSArray *matches = [self matchesForString:x withRegex:@"([$_A-Za-z0-9]+):|reverse|splice"];
    //NSLog(@"matches: %@", matches);
    
    int i = 0;
    
    /*
     adopted from the javascript version to identify the functions, probably not the most efficient way, but it works!
     Loop through the matches and if a != reverse | splice then set the value to tmp, the function names are listed
     prior to their purpose:
     
     ie: [Ww,splice,w9,reverse]
     
     splice = Ww; & reverse = W9;
     
     */
    
    for (i = 0; i < [matches count]; i++)
    {
        a = [matches objectAtIndex:i];
        if (r != nil && s != nil)
        {
            break;
        }
        if([a isEqualToString:@"reverse"])
        {
            NSLog(@"reverse = %@", tmp);
            r = tmp;
        } else if ([a isEqualToString:@"splice"])
        {
            NSLog(@"splice = %@", tmp);
            s = tmp;
        } else {
            tmp = [a stringByReplacingOccurrencesOfString:@":" withString:@""];
        }
    }
    
    /*
     
     the new signature is made into a key array for easily moving characters around as needed based on the cipher
     ie cr.Ww(a,13);cr.W9(a,69);cr.Gz(a,3);cr.Ww(a,2);cr.W9(a,79);cr.Gz(a,3);cr.Ww(a,36);return a.join(
     
     broken up into chunks like
     
     cr.Ww(a,13)
     
     this will allow us to take the keyMatch string and actually determine when to reverse, splice or swap
     
     */
    NSMutableArray *keys = [NSMutableArray new];
    
    NSArray *keyMatches = [self matchesForString:keyMatch withRegex:@"[$_A-Za-z0-9]+\\.([$_A-Za-z0-9]+)\\(a,(\\d*)\\)"];
    for (NSString *theMatch in keyMatches)
    {
        //fr.Ww(a,13) split this up into something like Ww and 13
        NSString *importantSection = [[theMatch componentsSeparatedByString:@"."] lastObject];
        NSString *numberValue = [[[importantSection componentsSeparatedByString:@","] lastObject] stringByReplacingOccurrencesOfString:@")" withString:@""]; //13
        NSString *fnName = [[importantSection componentsSeparatedByString:@"("] objectAtIndex:0]; // Ww
        NSLog(@"theMath: %@", theMatch);
        NSLog(@"importantSection: %@ number: %@ fn: %@", importantSection, numberValue, fnName);
        if ([fnName isEqualToString:r]) //reverse
        {
            [keys addObject:@"0"]; //0 in our signature key means reverse the string
        } else if ([fnName isEqualToString:s]) //if its the splice function store it as a negative value
        {
            [keys addObject:[NSString stringWithFormat:@"-%@", numberValue]];
        } else { //were not splicing or reversing, so its going to be a swap value
            [keys addObject:numberValue];
        }
    }
    
    //take the final key array and make it into something like 13,0,-3,2,0,-3,36
    
    self.ytkey = [keys componentsJoinedByString:@","];
    NSLog(@"timeStamp: %@ key: %@", self.yttimestamp, self.ytkey);
    
}


/**
 
 this function will take the key array and splice it from the starting index to the end of the string with the value 3
 would change:
 105105282D9AD56125199603D23E2C93F04C9D2237A.B8A82DC92F00EF86757325D88E778BC5D08FC252252 to
 105282D9AD56125199603D23E2C93F04C9D2237A.B8A82DC92F00EF86757325D88E778BC5D08FC252252
 
 */

- (NSMutableArray *)sliceArray:(NSArray *)theArray atIndex:(int)theIndex
{
    NSRange theRange = NSMakeRange(theIndex, theArray.count-theIndex);
    return [[theArray subarrayWithRange:theRange] mutableCopy];
}

/*
 
 take an array and reverse it, the mutable copy thing probably isnt very efficient but a necessary? evil to
 retain mutability
 
 */

- (NSMutableArray *)reversedArray:(NSArray *)theArray
{
    return [[[theArray reverseObjectEnumerator] allObjects] mutableCopy];
}

/*
 
 take the value at index 0 and swap it with theIndex
 
 */

- (NSMutableArray *)swapCharacterAtIndex:(int)theIndex inArray:(NSMutableArray *)theArray
{
    [theArray exchangeObjectAtIndex:0 withObjectAtIndex:theIndex];
    return theArray;
    
}



/*
 
 big encirido to decode the signature, takes a value like 13,0,-3,2,0,-3,36 and a signature
 and spits out usable version of it, only needed wheb use signature cipher is true
 
 */

- (NSString *)decodeSignature:(NSString *)theSig
{
    NSMutableArray *s = [[theSig splitString] mutableCopy];
    NSArray *keyArray = [self.ytkey componentsSeparatedByString:@","];
    int i = 0;
    for (i = 0; i < [keyArray count]; i++)
    {
        int n = [[keyArray objectAtIndex:i] intValue];
        if (n == 0) //reverse
        {
            s = [self reversedArray:s];
        } else if (n < 0) //slice
        {
            s = [self sliceArray:s atIndex:-n];
            
        } else {
            s = [self swapCharacterAtIndex:n inArray:s];
        }
    }
    return[s componentsJoinedByString:@""];
}


@end
