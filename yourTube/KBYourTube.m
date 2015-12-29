//
//  KBYourTube.m
//  yourTube
//
//  Created by Kevin Bradley on 12/21/15.
//  Copyright © 2015 nito. All rights reserved.
//

#import "KBYourTube.h"

/*
 
 extension = mp4;
 "fallback_host" = "tc.v20.cache6.googlevideo.com";
 format = "720p MP4";
 height = 720;
 itag = 22;
 outputFilename = "Lil Wayne - She Will ft. Drake [720p].mp4";
 quality = hd720;
 s = "0EB5EB288649655913278F5D38AB2CD79D45456B9CD.995862014F39B5A58912719A4712344E8DB84AB8AB8";
 title = "Lil Wayne - She Will ft. Drake";
 type = "video/mp4; codecs=avc1.64001F, mp4a.40.2";
 url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?lmt=1417236324599143&sver=3&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&ipbits=0&expire=1451201206&id=o-AL0YS27EZsY-lvWQVAq_YYK9z7cGVTbHdXu0f59O2_KJ&requiressl=yes&dur=323.895&mm=31&mn=sn-bvvbax-2iml&pl=16&ratebypass=yes&source=youtube&ip=xx&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&ms=au&mt=1451179550&mv=m&itag=22&upn=1IQJzTpYaQc&mime=video%2Fmp4&key=yt6&nh=EAI&signature=BEB288649605913278F5D38AB2CD79D4545659CD.995862014F39B5A58912719A4712344E8DB848BA";
 
 */



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

/**
 
 take the input dictionary and update our values according to it.
 
 */


- (BOOL)processSource:(NSDictionary *)inputSource
{
    //NSLog(@"inputSource: %@", inputSource);
    if ([[inputSource allKeys] containsObject:@"url"])
    {
        NSString *signature = nil;
        self.itag = [[inputSource objectForKey:@"itag"] integerValue];
        
        //if you want to limit to mp4 only, comment this if back in
        //  if (fmt == 22 || fmt == 18 || fmt == 37 || fmt == 38)
        //    {
        NSString *url = [[inputSource objectForKey:@"url"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
            return false;
        }
        
        if ([[inputSource valueForKey:@"quality"] length] == 0)
        {
            self.quality = tags[@"quality"];
        } else {
            self.quality = inputSource[@"quality"];
        }
        
        self.url = [NSURL URLWithString:url];
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
        self.outputFilename = [NSString stringWithFormat:@"%@ [%@p].%@", self.title, self.height,self.extension];
        return true;
        // }
    }
    
    
    return false;
}

- (NSDictionary *)dictionaryValue
{
    return @{@"title": self.title, @"type": self.type, @"format": self.format, @"height": self.height, @"itag": [NSNumber numberWithInteger:self.itag], @"extension": self.extension, @"url": self.url};
}

- (NSString *)description
{
    return [[self dictionaryValue] description];
}


@end

/*
 
 author = fullaswag;
 duration = 324;
 images =     {
 high = "https://i.ytimg.com/vi/_7nYuyfkjCk/hqdefault.jpg";
 medium = "https://i.ytimg.com/vi/_7nYuyfkjCk/mqdefault.jpg";
 standard = "https://i.ytimg.com/vi/_7nYuyfkjCk/sddefault.jpg";
 };
 keywords
 title = "Lil Wayne - She Will ft. Drake";
 videoID = "_7nYuyfkjCk";
 views = 22888597;
 
 */




@implementation KBYTMedia

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


- (BOOL)processDictionary:(NSDictionary *)vars
{
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
            //if we actually have a video detail dictionary add it to final array
            [videoArray addObject:processed];
        }
    }
    
    NSArray *adaptiveMaps = [[adaptiveMap stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] componentsSeparatedByString:@","];
    for (NSString *amap in adaptiveMaps )
    {
        //same thing, take these raw feeds and make them into an NSDictionary with usable info
        NSMutableDictionary *videoDict = [self parseFlashVars:amap];
        //  NSLog(@"videoDict: %@", videoDict[@"itag"]);
        //add the title from the previous dictionary created
        [videoDict setValue:[title stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"title"];
        //process the raw dictionary into something that can be used with download links and format details
        KBYTStream *processed = [[KBYTStream alloc] initWithDictionary:videoDict];
        if (processed.title != nil)
        {
            //if we actually have a video detail dictionary add it to final array
            [videoArray addObject:processed];
        }
    }
    
    
    self.streams = videoArray;
    [self matchAudioStreams];
    
    return TRUE;
    
}


- (NSString *)description
{
   return [NSString stringWithFormat:@"%@\n\ttitle: %@\n\tauthor: %@\n\tkeywords: %@\n\tvideoID: %@\n\tviews: %@\n\tduration: %@\n\timages: %@\n\tstreams: %@\n",[super description], self.title, self.author, self.keywords, self.videoId, self.views, self.duration, self.images, self.streams];
}

@end



@implementation NSObject (convenience)

#pragma mark Parsing & Regex magic

//change a wall of "body" text into a dictionary like &key=value

- (NSMutableDictionary *)parseFlashVars:(NSString *)vars
{
    return [self dictionaryFromString:vars withRegex:@"([^&=]*)=([^&]*)"];
}

//give us the actual matches from a regex, rather then NSTextCheckingResult full of ranges

- (NSArray *)matchesForString:(NSString *)string withRegex:(NSString *)pattern
{
    NSMutableArray *array = [NSMutableArray new];
    NSError *error = NULL;
    NSRange range = NSMakeRange(0, string.length);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines error:&error];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportProgress range:range];
    for (NSTextCheckingResult *entry in matches)
    {
        NSString *text = [string substringWithRange:entry.range];
        [array addObject:text];
    }
    
    return array;
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



//split a string into an NSArray of characters

@implementation NSString (SplitString)

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

/**
 
 Native objective-c implementation of several different functions pulled from clicktoplugin safari browser extension
 
 */

@implementation KBYourTube

@synthesize ytkey, yttimestamp;

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

//take a url and get its raw body, then return in string format

- (NSString *)stringFromRequest:(NSString *)url
{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:10];
    
    NSURLResponse *response = nil;
    
    [request setHTTPMethod:@"GET"];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
}




#pragma mark video details

/*
 
 the only function you should ever have to call to get video streams
 take the video ID from a youtube link and feed it in to this function
 
 ie _7nYuyfkjCk from the link below include blocks for failure and success.
 
 
 https://www.youtube.com/watch?v=_7nYuyfkjCk
 
 
 */


- (void)getVideoDetailsForID:(NSString*)videoID
             completionBlock:(void(^)(KBYTMedia* videoDetails))completionBlock
                failureBlock:(void(^)(NSString* error))failureBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        @autoreleasepool {
            KBYTMedia *rootInfo = nil;
            //NSMutableDictionary *rootInfo = [NSMutableDictionary new];
            NSString *errorString = nil;
            
            //if we already have the timestamp and key theres no reason to fetch them again, should make additional calls quicker.
            if (self.yttimestamp.length == 0 && self.ytkey.length == 0)
            {
                //get the time stamp and cipher key in case we need to decode the signature.
                [self getTimeStampAndKey:videoID];
            }
            
            //a fallback just in case the jsbody is changed and we cant automatically grab current signatures
            //old ciphers generally continue to work at least temporarily.
            
            if (self.yttimestamp.length == 0 || self.ytkey.length == 0)
            {
                errorString = @"Failed to decode signature cipher javascript.";
                self.yttimestamp = @"16777";
                self.ytkey = @"13,0,-3,2,0,-3,36";
                
            }
            
            NSString *url = [NSString stringWithFormat:@"https://www.youtube.com/get_video_info?&video_id=%@&%@&sts=%@", videoID, @"eurl=http%3A%2F%2Fwww%2Eyoutube%2Ecom%2F", self.yttimestamp];
            
            //get the post body from the url above, gets the initial raw info we work with
            NSString *body = [self stringFromRequest:url];
            
            //turn all of these variables into an nsdictionary by separating elements by =
            NSDictionary *vars = [self parseFlashVars:body];
            
            //  NSLog(@"vars: %@", vars);
            
            if ([[vars allKeys] containsObject:@"status"])
            {
                if ([[vars objectForKey:@"status"] isEqualToString:@"ok"])
                {
                    rootInfo = [[KBYTMedia alloc] initWithDictionary:vars];
                }
            } else {
                
                errorString = @"get_video_info failed.";
                
            }
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

- (void)fixAudio:(NSString *)theFile volume:(NSInteger)volume completionBlock:(void(^)(NSString *newFile))completionBlock
{
    NSLog(@"fix audio: %@", theFile);
    NSString *outputFile = [[theFile stringByDeletingPathExtension] stringByAppendingPathExtension:@"m4a"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        @autoreleasepool {
            NSTask *afcTask = [NSTask new];
            [afcTask setLaunchPath:[[NSBundle mainBundle] pathForResource:@"mux" ofType:@""]];
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
            /*
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
             */
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


- (void)muxFiles:(NSArray *)theFiles completionBlock:(void(^)(NSString *newFile))completionBlock
{
    NSString *videoFile = [theFiles firstObject];
    NSString *audioFile = [theFiles lastObject];
    NSString *outputFile = [[videoFile stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp4"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        @autoreleasepool {
            NSTask *afcTask = [NSTask new];
            [afcTask setLaunchPath:[[NSBundle mainBundle] pathForResource:@"mux" ofType:@""]];
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
            // NSLog(@"mux %@", [args componentsJoinedByString:@" "]);
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
    
    //the timestamp that is needed for signature deciphering
    
    self.yttimestamp = [[[[self matchesForString:body withRegex:@"\"sts\":(\\d*)"] lastObject] componentsSeparatedByString:@":"] lastObject];
    
    //isolate the base.js file that we need to extract the signature from
    
    NSString *baseJS = [NSString stringWithFormat:@"https:%@", [[[[[self matchesForString:body withRegex:@"\"js\":\"([^\"]*)\""] lastObject] componentsSeparatedByString:@":"] lastObject] stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"]];
    
    //get the raw js source of the decoder file that we need to get the signature cipher from
    
    NSString *jsBody = [self stringFromRequest:[baseJS stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
    
    //crazy convoluted regex to get a signature section similiar to this
    //cr.Ww(a,13);cr.W9(a,69);cr.Gz(a,3);cr.Ww(a,2);cr.W9(a,79);cr.Gz(a,3);cr.Ww(a,36);return a.join(
    
    //#### IGNORE THE WARNING, if the extra escape is added as expected the regex doesnt work!
    
    NSString *keyMatch = [[self matchesForString:jsBody withRegex:@"function[ $_A-Za-z0-9]*\\(a\\)\\{a=a(?:\.split|\\[[$_A-Za-z0-9]+\\])\\(\"\"\\);\\s*([^\"]*)"] lastObject];
    
    //the jsbody is trimmed down to a smaller section to optimize the search to deobfuscate the signature function names
    
    NSString *fnNameMatch = [NSString stringWithFormat:@";var %@={", [[self matchesForString:keyMatch withRegex:@"^[$_A-Za-z0-9]+"] lastObject]];
    
    //the index to start the new string range from for said optimization above
    
    NSUInteger index = [jsBody rangeOfString:fnNameMatch].location;
    
    //smaller string for searching for reverse / splice function names
    NSString *x = [jsBody substringFromIndex:index];
    NSString *a, *tmp, *r, *s = nil;
    
    //next baffling regex used to cycle through which functions names from the match above are linked to reversing and splicing
    NSArray *matches = [self matchesForString:x withRegex:@"([$_A-Za-z0-9]+):|reverse|splice"];
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
            r = tmp;
        } else if ([a isEqualToString:@"splice"])
        {
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
