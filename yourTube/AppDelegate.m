//
//  AppDelegate.m
//  yourTube
//
//  Created by Kevin Bradley on 12/21/15.
//  Copyright © 2015 nito. All rights reserved.
//

#import "AppDelegate.h"
#import "KBYourTube.h"
#import "KBYTDownloadManager.h"
extern NSString * ONOXPathFromCSS(NSString *CSS);

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong) NSString *playlistFolder;
@end

@implementation AppDelegate

@synthesize itemSelected, progressBar, downloadFile, itemPlayable;

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

- (ONOXMLDocument *)onoVideoDetails:(NSString *)videoID
{
    NSString *requestString = [NSString stringWithFormat:@"https://m.youtube.com/watch?v=%@", videoID];
    NSString *rawRequestResult = [self stringFromRequest:requestString];
    return [ONOXMLDocument HTMLDocumentWithString:rawRequestResult encoding:NSUTF8StringEncoding error:nil];
    //https://www.youtube.com/watch?v=dtCxmbFgnrc
}

//https://www.youtube.com/playlist?list=FLiuFEQ2-YiaW97Uzu00bOZQ

/*
 
 <ul class="pl-header-details"><li><a href="/channel/UC4IAZ3dowcXyvVYBx4hucSQ" class="yt-uix-sessionlink g-hovercard      spf-link " data-ytid="UC4IAZ3dowcXyvVYBx4hucSQ" data-sessionlink="ei=acDQVp78LMLp-gOs06qoDg">#LilWayne</a></li><li>500 videos</li><li>179,214 views</li><li>Updated today</li></ul><div class="playlist-actions">
 
 */

- (NSDictionary *)onoPlaylistList:(NSString *)listID
{
    // NSString *requestString = @"https://www.youtube.com/channel/UC-9-kyTW8ZkZNDHQJ6FgpwQ/videos";
    NSString *requestString = [NSString stringWithFormat:@"https://www.youtube.com/playlist?list=%@", listID];
    NSString *rawRequestResult = [self stringFromRequest:requestString];
    ONOXMLDocument *xmlDoc = [ONOXMLDocument HTMLDocumentWithString:rawRequestResult encoding:NSUTF8StringEncoding error:nil];
    ONOXMLElement *root = [xmlDoc rootElement];
    //NSLog(@"root element: %@", root);
    
    ONOXMLElement *playlistDetails = [root firstChildWithXPath:@"//*[contains(@class, 'pl-header-details')]"];
    //pl-header-details
    /*
     
     <li><a href="/channel/UC4IAZ3dowcXyvVYBx4hucSQ" class="yt-uix-sessionlink g-hovercard      spf-link " data-ytid="UC4IAZ3dowcXyvVYBx4hucSQ" data-sessionlink="ei=acDQVp78LMLp-gOs06qoDg">#LilWayne</a></li><li>500 videos</li><li>179,214 views</li><li>Updated today</li>
     
     */
    NSMutableDictionary *outputDict = [NSMutableDictionary new];
    
    NSInteger i = 0;
    for (ONOXMLElement *detailChild in [playlistDetails children])
    {
        switch (i) {
            case 0:
                outputDict[@"playlistAuthor"] = [detailChild stringValue];
                break;
                
            case 1:
                outputDict[@"totalCount"] = [[[detailChild stringValue] componentsSeparatedByString:@" "] firstObject];
                break;
                
            case 2:
                outputDict[@"views"] = [detailChild stringValue];
                break;
                
            case 3:
                outputDict[@"lastUpdated"] = [detailChild stringValue];
                break;
                
            default:
                break;
        }
        i++;
    }
    
    ONOXMLElement *videosElement = [root firstChildWithXPath:@"//*[contains(@class, 'pl-video-list')]"];
    id videoEnum = [videosElement XPath:@".//*[contains(@class, 'pl-video')]"];
    ONOXMLElement *currentElement = nil;
    NSMutableArray *finalArray = [NSMutableArray new];
    
    while (currentElement = [videoEnum nextObject])
    {
        //NSMutableDictionary *scienceDict = [NSMutableDictionary new];
        KBYTSearchResult *result = [KBYTSearchResult new];
        NSString *videoID = [currentElement valueForAttribute:@"data-video-id"];
        if (videoID != nil)
        {
            result.videoId = videoID;
        }
        // NSLog(@"currentElement: %@", currentElement);
        NSString *title = [currentElement valueForAttribute:@"data-title"];
        if (title != nil)
        {
            result.title = title;
        }
        
        
        ONOXMLElement *thumbNailElement = [[[currentElement firstChildWithXPath:@".//*[contains(@class, 'yt-thumb-clip')]"] children] firstObject];
        ONOXMLElement *lengthElement = [currentElement firstChildWithXPath:@".//*[contains(@class, 'video-time')]"];
        ONOXMLElement *authorElement = [[[currentElement firstChildWithXPath:@".//*[contains(@class, 'pl-video-owner')]"] children] firstObject];
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
            result.duration = [lengthElement.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (authorElement != nil)
        {
            result.author = [authorElement stringValue];
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
    return outputDict;
}

- (NSDictionary *)onoVideoChannelsList:(NSString *)channelID
{
    // NSString *requestString = @"https://www.youtube.com/channel/UC-9-kyTW8ZkZNDHQJ6FgpwQ/videos";
    NSString *requestString = [NSString stringWithFormat:@"https://www.youtube.com/channel/%@/videos", channelID];
    NSString *rawRequestResult = [self stringFromRequest:requestString];
    ONOXMLDocument *xmlDoc = [ONOXMLDocument HTMLDocumentWithString:rawRequestResult encoding:NSUTF8StringEncoding error:nil];
    ONOXMLElement *root = [xmlDoc rootElement];
    //NSLog(@"root element: %@", root);
    
    ONOXMLElement *videosElement = [root firstChildWithXPath:@"//*[contains(@class, 'channels-browse-content-grid')]"];
    id videoEnum = [videosElement XPath:@"//div[contains(@class, 'yt-lockup-video')]"];
    ONOXMLElement *currentElement = nil;
    NSMutableArray *finalArray = [NSMutableArray new];
    NSMutableDictionary *outputDict = [NSMutableDictionary new];
    
    ONOXMLElement *channelNameElement = [root firstChildWithXPath:@"//meta[contains(@name, 'title')]"];
    ONOXMLElement *channelDescElement = [root firstChildWithXPath:@"//meta[contains(@name, 'description')]"];
    ONOXMLElement *channelKeywordsElement = [root firstChildWithXPath:@"//meta[contains(@name, 'keywords')]"];
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
    
    while (currentElement = [videoEnum nextObject])
    {
        //NSMutableDictionary *scienceDict = [NSMutableDictionary new];
        KBYTSearchResult *result = [KBYTSearchResult new];
        NSString *videoID = [currentElement valueForAttribute:@"data-context-item-id"];
        if (videoID != nil)
        {
            result.videoId = videoID;
        }
        ONOXMLElement *thumbNailElement = [[[currentElement firstChildWithXPath:@".//*[contains(@class, 'yt-thumb-simple')]"] children] firstObject];
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
            result.title = [[titleElement stringValue] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
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
    return outputDict;
}

/*
 <button class="yt-uix-button yt-uix-button-size-default yt-uix-button-default load-more-button yt-uix-load-more browse-items-load-more-button" type="button" onclick=";return false;" aria-label="Load more
 " data-uix-load-more-target-id="section-list-625288" data-uix-load-more-href="/browse_ajax?action_continuation=1&amp;continuation=4qmFsgJ5Eg9GRXdoYXRfdG9fd2F0Y2gaZENCQjZSME5wWjBGQlIxWjFRVUZHVmxWM1FVSldWazFCUVZGQ1IxSllaRzlaV0ZKbVpFYzVabVF5UmpCWk1tZEJRVkZCUVVGUlJVSkJRVUZDUlVKQldXaGtTekpuV25GWGVYZEpCAA%253D%253D&amp;target_id=section-list-625288&amp;direct_render=1" data-scrolldetect-offset="600"><span class="yt-uix-button-content">  <span class="load-more-loading hid">
 <span class="yt-spinner">
 <span class="yt-spinner-img  yt-sprite" title="Loading icon"></span>
 
 Loading...
 </span>
 
 </span>
 <span class="load-more-text">
 Load more
 
 </span>
 </span></button>*/
//load_more_widget_html

- (NSDictionary *)loadMorePlaylistDictionary:(NSString *)hrefString
{
    NSString *requestString = [@"https://m.youtube.com" stringByAppendingPathComponent:hrefString];
    NSString *rawRequestResult = [self stringFromRequest:requestString];
    NSData *JSONData = [rawRequestResult dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
    
    NSString *rawHTML = jsonDict[@"content_html"];
    NSString *loadMoreHTML = jsonDict[@"load_more_widget_html"];
    ONOXMLDocument *loadMoreDoc = [ONOXMLDocument HTMLDocumentWithString:loadMoreHTML encoding:NSUTF8StringEncoding error:nil];
    
    
    
    // ONOXMLElement *root = [xmlDoc rootElement];
    
    ONOXMLDocument *xmlDoc = [ONOXMLDocument HTMLDocumentWithString:rawHTML encoding:NSUTF8StringEncoding error:nil];
    ONOXMLElement *root = [xmlDoc rootElement];
    
    // NSLog(@"rawHTML: %@", root);
    id videoEnum = [root XPath:@".//*[contains(@class, 'pl-video')]"];
    ONOXMLElement *currentElement = nil;
    NSMutableArray *finalArray = [NSMutableArray new];
    NSMutableDictionary *outputDict = [NSMutableDictionary new];
    
    while (currentElement = [videoEnum nextObject])
    {
        //NSMutableDictionary *scienceDict = [NSMutableDictionary new];
        KBYTSearchResult *result = [KBYTSearchResult new];
        NSString *videoID = [currentElement valueForAttribute:@"data-video-id"];
        if (videoID != nil)
        {
            result.videoId = videoID;
        }
        // NSLog(@"currentElement: %@", currentElement);
        NSString *title = [currentElement valueForAttribute:@"data-title"];
        if (title != nil)
        {
            result.title = title;
        }
        
        
        ONOXMLElement *thumbNailElement = [[[currentElement firstChildWithXPath:@".//*[contains(@class, 'yt-thumb-clip')]"] children] firstObject];
        ONOXMLElement *lengthElement = [currentElement firstChildWithXPath:@".//*[contains(@class, 'video-time')]"];
        ONOXMLElement *authorElement = [[[currentElement firstChildWithXPath:@".//*[contains(@class, 'pl-video-owner')]"] children] firstObject];
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
            result.duration = [lengthElement.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (authorElement != nil)
        {
            result.author = [authorElement stringValue];
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
            ONOXMLElement *loadMoreButton = [[loadMoreDoc rootElement] firstChildWithXPath:@"//button[contains(@class, 'load-more-button')]"];
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
    return outputDict;
}

- (void)loadMoreVideosFromHREF:(NSString *)loadMoreLink
               completionBlock:(void(^)(NSDictionary *outputResults))completionBlock
                  failureBlock:(void(^)(NSString *error))failureBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        
        @autoreleasepool {
            
            NSString *requestString = [@"https://m.youtube.com" stringByAppendingPathComponent:loadMoreLink];
            NSString *rawRequestResult = [self stringFromRequest:requestString];
            NSData *JSONData = [rawRequestResult dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
            
            NSString *rawHTML = jsonDict[@"content_html"];
            NSString *loadMoreHTML = jsonDict[@"load_more_widget_html"];
            ONOXMLDocument *loadMoreDoc = [ONOXMLDocument HTMLDocumentWithString:loadMoreHTML encoding:NSUTF8StringEncoding error:nil];
            ONOXMLDocument *xmlDoc = [ONOXMLDocument HTMLDocumentWithString:rawHTML encoding:NSUTF8StringEncoding error:nil];
            ONOXMLElement *root = [xmlDoc rootElement];
            ONOXMLElement *videosElement = [root firstChildWithXPath:@"//ol[contains(@class, 'item-section')]"];
            if (videosElement == nil)
            {
                videosElement = root;
            }
            id videoEnum = [videosElement XPath:@"//div[contains(@class, 'yt-lockup-video')]"];
            ONOXMLElement *currentElement = nil;
            NSMutableArray *finalArray = [NSMutableArray new];
            NSMutableDictionary *outputDict = [NSMutableDictionary new];
            while (currentElement = [videoEnum nextObject])
            {
                KBYTSearchResult *result = [KBYTSearchResult new];
                NSString *videoID = [currentElement valueForAttribute:@"data-context-item-id"];
                if (videoID != nil)
                {
                    result.videoId = videoID;
                }
                ONOXMLElement *thumbNailElement = [[[currentElement firstChildWithXPath:@".//*[contains(@class, 'yt-thumb-simple')]"] children] firstObject];
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
                    result.title = [[titleElement stringValue] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                
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
                
            }
            if ([finalArray count] > 0)
            {
                //load-more-button
                ONOXMLElement *loadMoreButton = [[loadMoreDoc rootElement] firstChildWithXPath:@"//button[contains(@class, 'load-more-button')]"];
                NSString *loadMoreHREF = [loadMoreButton valueForAttribute:@"data-uix-load-more-href"];
                if (loadMoreHREF != nil){
                    outputDict[@"loadMoreREF"] = loadMoreHREF;
                }
                outputDict[@"results"] = finalArray;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([outputDict[@"results"] count] > 0)
                {
                    completionBlock(outputDict);
                } else {
                    failureBlock([NSString stringWithFormat:@"error loading href: %@", loadMoreLink]);
                }
                
            });
            
        }
    });
}



- (NSDictionary *)loadMoreDictionary:(NSString *)hrefString
{
    NSString *requestString = [@"https://m.youtube.com" stringByAppendingPathComponent:hrefString];
    NSString *rawRequestResult = [self stringFromRequest:requestString];
    NSData *JSONData = [rawRequestResult dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
    
    NSString *rawHTML = jsonDict[@"content_html"];
    NSString *loadMoreHTML = jsonDict[@"load_more_widget_html"];
    ONOXMLDocument *loadMoreDoc = [ONOXMLDocument HTMLDocumentWithString:loadMoreHTML encoding:NSUTF8StringEncoding error:nil];
    
    ONOXMLDocument *xmlDoc = [ONOXMLDocument HTMLDocumentWithString:rawHTML encoding:NSUTF8StringEncoding error:nil];
    ONOXMLElement *root = [xmlDoc rootElement];
    ONOXMLElement *videosElement = [root firstChildWithXPath:@"//ol[contains(@class, 'item-section')]"];
    if (videosElement == nil)
    {
        videosElement = root;
    }
    id videoEnum = [videosElement XPath:@"//div[contains(@class, 'yt-lockup-video')]"];
    ONOXMLElement *currentElement = nil;
    NSMutableArray *finalArray = [NSMutableArray new];
    NSMutableDictionary *outputDict = [NSMutableDictionary new];
    while (currentElement = [videoEnum nextObject])
    {
        KBYTSearchResult *result = [KBYTSearchResult new];
        NSString *videoID = [currentElement valueForAttribute:@"data-context-item-id"];
        if (videoID != nil)
        {
            result.videoId = videoID;
        }
        ONOXMLElement *thumbNailElement = [[[currentElement firstChildWithXPath:@".//*[contains(@class, 'yt-thumb-simple')]"] children] firstObject];
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
            result.title = [[titleElement stringValue] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
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
        
    }
    if ([finalArray count] > 0)
    {
        //load-more-button
        ONOXMLElement *loadMoreButton = [[loadMoreDoc rootElement] firstChildWithXPath:@"//button[contains(@class, 'load-more-button')]"];
        NSString *loadMoreHREF = [loadMoreButton valueForAttribute:@"data-uix-load-more-href"];
        if (loadMoreHREF != nil){
            outputDict[@"loadMoreREF"] = loadMoreHREF;
        }
        outputDict[@"results"] = finalArray;
    }
    return outputDict;
}

- (NSDictionary *)onoSearchQuery:(NSString *)searchQuery pageNumber:(NSInteger)page
{
    NSString *pageorsm = nil;
    if (page == 1)
    {
        pageorsm = @"sm=1";
    } else {
        pageorsm = [NSString stringWithFormat:@"page=%lu", page];
    }
    
    //NSString *requestString = [NSString stringWithFormat:@"https://m.youtube.com/results?%@&q=%@&%@", @"sp=EgIQAQ%253D%253D", [searchQuery stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], pageorsm];
    NSString *requestString = @"https://m.youtube.com/";
    NSString *rawRequestResult = [self stringFromRequest:requestString];
    
    
    
    
    
    //NSLog(@"jsonScience: %@", jsonScience);
    /*
     NSString *convertedString = [[input stringByReplacingOccurrencesOfString:@"\n" withString:@""] mutableCopy];
     
     CFStringRef transform = CFSTR("Any-Hex/Java");
     CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
     */
    //   NSLog(@"convertedString: %@", convertedString);
    
    ONOXMLDocument *xmlDoc = [ONOXMLDocument HTMLDocumentWithString:rawRequestResult encoding:NSUTF8StringEncoding error:nil];
    ONOXMLElement *root = [xmlDoc rootElement];
    NSString *XPath = @"//ol[contains(@class, 'section-list')]";
    ONOXMLElement *sectionListElement = [root firstChildWithXPath:XPath];
    //NSLog(@"sectionListElement: %@", sectionListElement);
    ONOXMLElement *numListElement = [sectionListElement firstChildWithXPath:@"//p[contains(@class,'num-results')]"];
    NSInteger results = 0;
    if (numListElement !=nil)
    {
        NSString *resultText = [numListElement stringValue];
        results = [[[[[resultText componentsSeparatedByString:@"About"] lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@"," withString:@""] integerValue];
    }
    ONOXMLElement *videosElement = [root firstChildWithXPath:@"//ol[contains(@class, 'item-section')]"];
    id videoEnum = [videosElement XPath:@"//div[contains(@class, 'yt-lockup-video')]"];
    ONOXMLElement *currentElement = nil;
    NSMutableArray *finalArray = [NSMutableArray new];
    NSMutableDictionary *outputDict = [NSMutableDictionary new];
    outputDict[@"resultCount"] = [NSNumber numberWithInteger:results];
    while (currentElement = [videoEnum nextObject])
    {
        //NSMutableDictionary *scienceDict = [NSMutableDictionary new];
        KBYTSearchResult *result = [KBYTSearchResult new];
        NSString *videoID = [currentElement valueForAttribute:@"data-context-item-id"];
        if (videoID != nil)
        {
            result.videoId = videoID;
        }
        ONOXMLElement *thumbNailElement = [[[currentElement firstChildWithXPath:@".//*[contains(@class, 'yt-thumb-simple')]"] children] firstObject];
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
            result.title = [[titleElement stringValue] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
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
        
    }
    if ([finalArray count] > 0)
    {
        //load-more-button
        ONOXMLElement *loadMoreButton = [root firstChildWithXPath:@"//button[contains(@class, 'load-more-button')]"];
        NSString *loadMoreHREF = [loadMoreButton valueForAttribute:@"data-uix-load-more-href"];
        if (loadMoreHREF != nil){
            outputDict[@"loadMoreREF"] = loadMoreHREF;
        }
        outputDict[@"results"] = finalArray;
        NSInteger pageCount = results/[finalArray count];
        outputDict[@"pageCount"] = [NSNumber numberWithInteger:pageCount];
    }
    return outputDict;
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


- (void)getUserDetailsDictionaryWithCompletionBlock:(void(^)(NSDictionary *outputResults))completionBlock
                                       failureBlock:(void(^)(NSString *error))failureBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        @autoreleasepool {
            
            BOOL signedIn = [self isSignedIn];
            NSString *errorString = @"Unknown error occurred";
            NSDictionary *returnDict = nil;
            if (signedIn == true) {
                
                NSDictionary *channelDict = [self channelIDAndWatchLaterCount];
                NSLog(@"channelDict: %@", channelDict);
                NSString *channelID = channelDict[@"channelID"];
                NSDictionary *userDetails = [self userDetailsFromChannelURL:channelID];
                NSLog(@"userDetails: %@", userDetails);
                NSString *userName = userDetails[@"username"];
                NSArray *playlists = [self playlistArrayFromUserName:userName];
                NSInteger channelVideoCount = [self videoCountForUserName:userName];
                NSLog(@"videoCount: %lu", channelVideoCount);
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

/*
 
 <div id="gh-banner">
 <style>
 #c4-header-bg-container {
 background-image: url(//yt3.ggpht.com/78x8gQ52gxviEFgD4eupfHKx7iZX3GtjD56naUSjDzcj83LnyD3VeyTJyschuLSAQW7sLuQ-_u5-PmnUtg=w1060-fcrop64=1,00005a57ffffa5a8-nd);
 }
 
 
 @media screen and (-webkit-min-device-pixel-ratio: 1.5),
 screen and (min-resolution: 1.5dppx) {
 #c4-header-bg-container {
 background-image: url(//yt3.ggpht.com/78x8gQ52gxviEFgD4eupfHKx7iZX3GtjD56naUSjDzcj83LnyD3VeyTJyschuLSAQW7sLuQ-_u5-PmnUtg=w2120-fcrop64=1,00005a57ffffa5a8-nd);
 }
 }
 
 #c4-header-bg-container .hd-banner-image {
 background-image: url(//yt3.ggpht.com/78x8gQ52gxviEFgD4eupfHKx7iZX3GtjD56naUSjDzcj83LnyD3VeyTJyschuLSAQW7sLuQ-_u5-PmnUtg=w2120-fcrop64=1,00005a57ffffa5a8-nd);
 }
 
 </style>
 */

- (void)testScience
{
    ONOXMLDocument *xmlDoc = [self documentFromURL:@"https://www.youtube.com/channel/UCF0pVplsI8R5kcAqgtoRqoA"];
    ONOXMLElement *root = [xmlDoc rootElement];
    ONOXMLElement *headerSection = [root firstChildWithXPath:@"//div[contains(@id, 'gh-banner')]"];
    NSString *headerString = [[[headerSection children] firstObject] stringValue];
    //NSLog(@"header section: %@", stringValue);
    NSScanner *bannerScanner = [NSScanner scannerWithString:headerString];
    NSString *desiredValue = nil;
    [bannerScanner scanUpToString:@");" intoString:&desiredValue];
    NSString *headerBanner = [[desiredValue componentsSeparatedByString:@"//"] lastObject];
    NSLog(@"https://%@", headerBanner);
    
    /*
     NSString *header = ONOXPathFromCSS(@"#c4-header-bg-container");
     NSLog(@"header: %@", header);
     NSArray *headerObjects = [(NSEnumerator *)[root XPath:header] allObjects];
     NSLog(@"headerObjects: %@", headerObjects);
     */
}

- (NSDictionary *)channelIDAndWatchLaterCount
{
    ONOXMLDocument *xmlDoc = [self documentFromURL:@"https://m.youtube.com"];
    ONOXMLElement *root = [xmlDoc rootElement];
    //#c4-header-bg-container
    NSArray *itemCounts = [(NSEnumerator *)[root XPath:@".//span[contains(@class, 'yt-valign-container guide-count-value')]"] allObjects];
    NSString *watchLaterCount = [[itemCounts objectAtIndex:1] stringValue];
    NSLog(@"watchLaterCount: %@", watchLaterCount);
    ONOXMLElement *guideSection = [root firstChildWithXPath:@"//li[contains(@class, 'guide-section')]"];
    NSArray *allObjects = [(NSEnumerator *)[guideSection XPath:@".//a[contains(@class, 'guide-item')]"] allObjects];
    if ([allObjects count] > 1)
    {
        ONOXMLElement *channelElement = [allObjects objectAtIndex:1];
        return @{@"channelID": [[channelElement valueForAttribute:@"href"] lastPathComponent], @"wlCount": watchLaterCount};
    }
    
    //<span class="yt-valign-container guide-count-value">4</span>
    return nil;
}

- (NSInteger)videoCountForUserName:(NSString *)channelID
{
    //channels-browse-content-grid
    //channels-content-item
    ONOXMLDocument *xmlDoct = [self documentFromURL:[NSString stringWithFormat:@"https://m.youtube.com/user/%@/videos", channelID]];
    ONOXMLElement *root = [xmlDoct rootElement];
    ONOXMLElement *canon = [root firstChildWithXPath:@"//ul[contains(@id, 'channels-browse-content-grid')]"];
    NSArray *objects = [(NSEnumerator *)[canon XPath:@".//li[contains(@class, 'channels-content-item')]"] allObjects];
    return [objects count];
}

- (NSDictionary *)userDetailsFromChannelURL:(NSString *)channelURL
{
    ONOXMLDocument *xmlDoct = [self documentFromURL:[NSString stringWithFormat:@"https://m.youtube.com/channel/%@", channelURL]];
    ONOXMLElement *root = [xmlDoct rootElement];
    ONOXMLElement *canon = [root firstChildWithXPath:@"//link[contains(@rel, 'canonical')]"];
    //<img class="channel-header-profile-image" src="//i.ytimg.com/i/iuFEQ2-YiaW97Uzu00bOZQ/mq1.jpg?v=564b8e92" title="nito" alt="nito">
    NSString *profileImage = [[root firstChildWithXPath:@"//img[contains(@class, 'channel-header-profile-image')]"] valueForAttribute:@"src"];
    
    
    return @{@"username": [[canon valueForAttribute:@"href"] lastPathComponent], @"profileImage": [NSString stringWithFormat:@"http:%@", profileImage] } ;
}

- (NSArray *)playlistArrayFromUserName:(NSString *)userName
{
    ONOXMLDocument *xmlDoct = [self documentFromURL:[NSString stringWithFormat:@"https://m.youtube.com/%@/playlists", userName]];
    ONOXMLElement *root = [xmlDoct rootElement];
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

- (void)addProgressObserver {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotProgressNotification:) name:@"updateProgressNote" object:nil];
    
}

- (void)testSearch {
    __block NSMutableArray *results = [NSMutableArray new];
    [[KBYourTube sharedInstance] apiSearch:@"drake" type:KBYTSearchTypeAll continuation:nil completionBlock:^(KBYTSearchResults *result) {
        [results addObject:result];
        [[KBYourTube sharedInstance] apiSearch:@"drake" type:KBYTSearchTypeAll continuation:result.continuationToken completionBlock:^(KBYTSearchResults *result) {
            [results addObject:result];
            //NSLog(@"results: %@", results);
        } failureBlock:^(NSString *error) {
            
        }];
    } failureBlock:^(NSString *error) {
        
    }];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [AppDelegate setDefaultPrefs];
    itemSelected = false;
    [self getResults:nil];
    //[[self webkitController] showWebWindow:nil];
    [self.window setDelegate:self];
    [self addProgressObserver];
    
    [self testSearch];
    //NSData *rawRequestResult = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/science2.html"]];
    
    //NSString *jsonValue = [[NSJSONSerialization JSONObjectWithData:rawRequestResult options:NSJSONReadingAllowFragments error:nil] valueForKey:@"load_more_widget_html"];
    /*
     NSDate *myStart = [NSDate date];
     NSDictionary *featuredVids = [self onoSearchQuery:nil pageNumber:1];
     
     NSLog(@"\n\nfeaturedVids: %@\n\n", featuredVids);
     
     NSString *featuredVidHREF = featuredVids[@"loadMoreREF"];
     NSDictionary *moreResults = [self loadMoreDictionary:featuredVidHREF];
     NSLog(@"\n\nmore results: %@\n\n", moreResults);
     
     featuredVidHREF = moreResults[@"loadMoreREF"];
     moreResults = [self loadMoreDictionary:featuredVidHREF];
     NSLog(@"\n\nmore results2: %@\n\n", moreResults);
     */
    //music channel = UC-9-kyTW8ZkZNDHQJ6FgpwQ
    //popular on yt = UCF0pVplsI8R5kcAqgtoRqoA
    //sports = UCEgdi0XIXXZ-qJOFPf4JSKw
    //gaming = UCOpNcN46UbXVtpKMrmU4Abg
    //news = UCYfdidRxbB8Qhf0Nx7ioOYw
    //live = UC4R8DWoMoI7CAwX8_LjQHig
    //360 = UCzuqhhs6NWbgTzMuM09WKDQ
    
    
    //  NSDictionary *loadMoreVids = [self loadMoreDictionary:channelVids[@"loadMoreREF"]];
    // NSLog(@"\n\nloadMoreVids: %@\n\n", loadMoreVids);
    /*
     NSDictionary *playlistItems = [self onoPlaylistList:@"PLasA1IRBDbhykoudJwfdI4eWNOfyz_JZJ"];
     
     NSLog(@"\nplaylist items: %@\n", playlistItems);
     
     NSDictionary *morePlaylistItems = [self loadMorePlaylistDictionary:playlistItems[@"loadMoreREF"]];
     NSLog(@"\n more Playlist Items: %@\n", morePlaylistItems);
     */
    /*
     NSInteger page = 1;
     NSString *pageorsm = nil;
     if (page == 1)
     {
     pageorsm = @"sm=1";
     } else {
     pageorsm = [NSString stringWithFormat:@"page=%lu", page];
     }
     
     NSString *requestString = [NSString stringWithFormat:@"https://m.youtube.com/results?q=%@&%@", [@"lil wayne" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], pageorsm];
     NSString *rawRequestResult = [self stringFromRequest:requestString];
     ONOXMLDocument *xmlDoc = [ONOXMLDocument HTMLDocumentWithString:rawRequestResult encoding:NSUTF8StringEncoding error:nil];
     ONOXMLElement *root = [xmlDoc rootElement];
     NSLog(@"root: %@", root);
     
     
     
     [[KBYourTube sharedInstance] getChannelVideos:@"UCEOhcOACopL42xyOBIv1ekg" completionBlock:^(NSDictionary *searchDetails) {
     
     NSLog(@"searchDetails: %@", searchDetails);
     
     } failureBlock:^(NSString *error) {
     //
     }];
     */
    /*
     [[KBYourTube sharedInstance]getSearchResults:@"Drake rick ross" pageNumber:1 completionBlock:^(NSDictionary *searchDetails) {
     
     
     NSLog(@"time taken: %@ searchDetails: %@", [myStart timeStringFromCurrentDate], searchDetails);
     
     
     } failureBlock:^(NSString *error) {
     
     //
     }];
     */
}

//called from webkit window when a link is clicked
- (void)showVideoAtURL:(NSString *)url
{
    self.youtubeLink.stringValue = url;
    [self getResults:nil];
    [[NSUserDefaults standardUserDefaults] setObject:url forKey:@"lastDownloadLink"];
    
}

//update Window menu to make sure we can bring the main window back.
- (void)windowWillClose:(NSNotification *)notification
{
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
    NSMenuItem *showMainWindowItem = [[NSMenuItem alloc] initWithTitle:@"Show Video Details" action:@selector(showMainWindow:) keyEquivalent:@"1"];
    [showMainWindowItem setTarget:self];
    [showMainWindowItem setTag:150];
    [[menuItem submenu] insertItem:showMainWindowItem atIndex:5];
}

//show Video Details window

- (IBAction)showMainWindow:(id)sender
{
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
    NSMenuItem *ourItem = [[menuItem submenu] itemWithTag:150];
    [[menuItem submenu] removeItem:ourItem];
    [[self window] makeKeyAndOrderFront:self];
}

//register default preferences
+ (void)setDefaultPrefs
{
    NSArray *keys = [NSArray arrayWithObjects:
                     @"downloadLocation",
                     @"lastDownloadLink",
                     @"autoPlay",
                     @"showFiles",
                     nil];
    //xpVfcZ0ZcFM
    //6pxRHBw-k8M
    NSArray *values = [NSArray arrayWithObjects:
                       [self downloadFolder],
                       @"https://www.youtube.com/watch?v=xpVfcZ0ZcFM",
                       [NSNumber numberWithBool:true],
                       [NSNumber numberWithBool:true],
                       nil];
    NSDictionary *appDefaults = [NSDictionary
                                 dictionaryWithObjects:values forKeys:keys ];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

//get video details
- (IBAction)getResults:(id)sender
{
    NSString *videoID = [[NSURL URLWithString:self.youtubeLink.stringValue] parameterDictionary][@"v"];
    NSLog(@"videoID: %@", videoID);
    
    if ([videoID length] > 0)
    {
        self.playlistFolder = nil;
        [[KBYourTube sharedInstance] getVideoDetailsForID:videoID completionBlock:^(KBYTMedia *videoDetails) {
            
            //NSLog(@"got details successfully: %@", videoDetails);
            
            self.titleField.stringValue = videoDetails.title;
            self.userField.stringValue = videoDetails.author;
            self.lengthField.stringValue = videoDetails.duration;
            self.viewsField.stringValue = videoDetails.views;
            
            self.imageView.image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:videoDetails.images[@"high"]]];
            
            self.currentMedia = videoDetails;
            self.streamArray = videoDetails.streams;
            self.streamController.selectsInsertedObjects = true;
            
            [[self window] orderFrontRegardless];
            
        } failureBlock:^(NSString *error) {
            
            NSLog(@"fail!: %@", error);
            
            NSAlert *alert = [NSAlert alertWithMessageText:@"An error occured" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:error];
            [alert runModal];
            
            
        }];
    } else {
        
        NSString *plID = [[NSURL URLWithString:self.youtubeLink.stringValue] parameterDictionary][@"list"];
        NSLog(@"plID: %@", plID);
        
        if (plID.length > 0){
            
            NSMutableArray *fullIDs = [NSMutableArray new];
            
            [[KBYourTube sharedInstance] getPlaylistVideos:plID completionBlock:^(NSDictionary *playlistDictionary) {
                DLog(@"pld: %@", playlistDictionary);
                self.userField.stringValue = playlistDictionary[@"playlistAuthor"];
                self.playlistFolder = playlistDictionary[@"title"];
                self.titleField.stringValue = self.playlistFolder;
                NSArray <KBYTMedia *> *results = playlistDictionary[@"results"];
                [results enumerateObjectsUsingBlock:^(KBYTMedia  *obj, NSUInteger idx, BOOL *  stop) {
                    
                    [fullIDs addObject:obj.videoId];
                    
                    //[[KBYourTube sharedInstance] getVi]
                    
                    
                }];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setDownloadProgress:0];
                    self.progressLabel.stringValue = @"Downloading playlist...";
                });
                
                
                
                [[KBYourTube sharedInstance] getVideoDetailsForIDs:fullIDs completionBlock:^(NSArray *videoArray) {
                    //NSLog(@"video array: %@", videoArray);
                    
                    [videoArray enumerateObjectsUsingBlock:^(KBYTMedia *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        [self downloadMedia:obj];
                        
                    }];
                    
                } failureBlock:^(NSString *error) {
                    DLog(@"error: %@", error);
                }];
                
                
            } failureBlock:^(NSString *error) {
                
                DLog(@"error: %@", error);
                
            }];
            
        }
        
        
        /*
         
         https://www.youtube.com/playlist?list=PLLAZ4kZ9dFpOPV5C5Ay0pHaa0RJFhcmcB
         
         */
        
    }
    
}

- (void)downloadFailed:(NSString *)theDownload
{
    
}

- (void)downloadStream:(KBYTStream *)stream
{
    NSMutableDictionary *streamDict = [[stream dictionaryValue] mutableCopy];
    /*
     streamDict[@"duration"] = self.ytMedia.duration;
     streamDict[@"author"] = self.ytMedia.author;
     streamDict[@"images"] = self.ytMedia.images;
     streamDict[@"inProgress"] = [NSNumber numberWithBool:true];
     streamDict[@"videoId"] = self.ytMedia.videoId;
     streamDict[@"views"]= self.ytMedia.views;
     */
    if (self.playlistFolder.length > 0) {
        
        streamDict[@"downloadFolder"] = self.playlistFolder;
        
    }
    NSString *stringURL = [[stream url] absoluteString];
    streamDict[@"url"] = stringURL;
    // [self updateDownloadsDictionary:streamDict];
    [[KBYTDownloadManager sharedInstance] addDownloadToQueue:streamDict];
}

- (void)gotProgressNotification:(NSNotification *)n {
    
    [self updateProgress:n.userInfo];
    
}

- (void)updateProgress:(NSDictionary *)progress {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        double percentComplete = [progress[@"percentComplete"] doubleValue];
        NSString *status = progress[@"status"];
        if (percentComplete == -1){
            [self hideProgress];
        } else {
            [self setDownloadProgress:0];
        }
        
        
        NSString *progressString = [NSString stringWithFormat:@"Downloading %@...", status];
        
        if (![self.progressLabel.stringValue isEqualToString:progressString])
        {
            self.progressLabel.stringValue = progressString;
        }
    });
    
}

- (void)downloadMedia:(KBYTMedia *)media {
    
    downloadFile = [KBYTDownloadStream new];
    self.downloadButton.title = @"Cancel";
    self.downloading = true;
    
    //get the stream we want to download
    KBYTStream *selectedObject = media.streams[0];
    [self downloadStream:selectedObject];
    return;
    
    [downloadFile downloadStream:selectedObject progress:^(double percentComplete, NSString *status) {
        
        [self setDownloadProgress:percentComplete];
        if (![self.progressLabel.stringValue isEqualToString:status])
        {
            self.progressLabel.stringValue = status;
        }
    } completed:^(NSString *downloadedFile) {
        
        if ([[downloadedFile pathExtension]isEqualToString:@"m4a"]) //so it opens in itunes or default player
        {
            [[NSWorkspace sharedWorkspace] openFile:downloadedFile];
            [self hideProgress];
            self.downloadButton.title = @"Download";
            self.downloading = false;
            return;
        }
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        
        if ([def boolForKey:@"showFiles"] == true)
        {
            [[NSWorkspace sharedWorkspace] selectFile:downloadedFile inFileViewerRootedAtPath:[downloadedFile stringByDeletingLastPathComponent]];
        }
        // NSLog(@"autoPlay: %i showFiles: %i", [def boolForKey:@"autoPlay"], [def boolForKey:@"showFiles"]);
        
        if ([selectedObject playable] == true && [def boolForKey:@"autoPlay"] == true)
        {
            [self playLocalFile:downloadedFile];
        }
        
        
        [self hideProgress];
        self.downloadButton.title = @"Download";
        self.downloading = false;
        
    }];
    
}


- (IBAction)downloadFile:(id)sender
{
    //we're already downloading, cancel
    //TODO: make downloading NSOperation/NSOperationQueue based
    if (self.downloading == true)
    {
        [downloadFile cancel];
        self.downloading = false;
        self.downloadButton.title = @"Download";
        self.progressLabel.stringValue = @"";
        [progressBar setDoubleValue:0];
        [progressBar setHidden:TRUE];
        return;
    }
    //create instance of downloader class
    downloadFile = [KBYTDownloadStream new];
    self.downloadButton.title = @"Cancel";
    self.downloading = true;
    
    //get the stream we want to download
    KBYTStream *selectedObject = self.streamController.selectedObjects.lastObject;
    [downloadFile downloadStream:selectedObject progress:^(double percentComplete, NSString *status) {
        
        [self setDownloadProgress:percentComplete];
        if (![self.progressLabel.stringValue isEqualToString:status])
        {
            self.progressLabel.stringValue = status;
        }
    } completed:^(NSString *downloadedFile) {
        
        if ([[downloadedFile pathExtension]isEqualToString:@"m4a"]) //so it opens in itunes or default player
        {
            [[NSWorkspace sharedWorkspace] openFile:downloadedFile];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideProgress];
                self.downloadButton.title = @"Download";
                self.downloading = false;
            });
            return;
        }
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        
        if ([def boolForKey:@"showFiles"] == true)
        {
            [[NSWorkspace sharedWorkspace] selectFile:downloadedFile inFileViewerRootedAtPath:[downloadedFile stringByDeletingLastPathComponent]];
        }
        // NSLog(@"autoPlay: %i showFiles: %i", [def boolForKey:@"autoPlay"], [def boolForKey:@"showFiles"]);
        
        if ([selectedObject playable] == true && [def boolForKey:@"autoPlay"] == true)
        {
            [self playLocalFile:downloadedFile];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgress];
            self.downloadButton.title = @"Download";
            self.downloading = false;
        });
        
    }];
    
}

- (void)hideProgress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressLabel.stringValue = @"";
        [[self progressBar] stopAnimation:nil];
        [[self progressBar] setDoubleValue:0];
        [[self progressBar] setHidden:true];
    });
    
}

- (void)setDownloadProgress:(double)theProgress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (theProgress == 0)
        {
            [progressBar setIndeterminate:TRUE];
            [progressBar setHidden:FALSE];
            [progressBar setNeedsDisplay:YES];
            [progressBar setUsesThreadedAnimation:YES];
            [progressBar startAnimation:self];
            return;
        }
        [progressBar setIndeterminate:FALSE];
        [progressBar startAnimation:self];
        [progressBar setHidden:FALSE];
        [progressBar setNeedsDisplay:YES];
        [progressBar setDoubleValue:theProgress];
    });
    
}

- (void)playLocalFile:(NSString *)localFile
{
    NSURL *theFile = [NSURL fileURLWithPath:localFile];
    self.player = [[AVPlayer alloc] initWithURL:theFile];
    [self.playerView setPlayer:self.player];
    [self.playerWindow makeKeyAndOrderFront:nil];
    [self.player play];
    [self.playerWindow makeKeyAndOrderFront:nil];
}

- (IBAction)playFile:(id)sender
{
    KBYTStream *selectedObject = self.streamController.selectedObjects.lastObject;
    NSURL *playURL = [selectedObject url];
    NSLog(@"play url: %@", playURL);
    self.player = [[AVPlayer alloc] initWithURL:playURL];
    [self.playerView setPlayer:self.player];
    [self.player play];
    
    [self.playerWindow makeKeyAndOrderFront:nil];
    
    // [[NSWorkspace sharedWorkspace]openURL:playURL];
}

//set download location in preferences
- (IBAction)setDownloadLocation:(id)sender{
    
    NSOpenPanel *op = [NSOpenPanel new];
    [op setCanChooseDirectories:true];
    [op setCanChooseFiles:false];
    [op setTitle:@"Choose a download location."];
    NSInteger modalResult = [op runModal];
    
    if (modalResult == NSModalResponseOK)
    {
        NSString *fn = [[op URL] path];
        [[NSUserDefaults standardUserDefaults] setValue:fn forKey:@"downloadLocation"];
    }
    
}

//when table view selection changes update whether download / play & audio adjustment slider are available.
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tv = notification.object;
    long sr = (long)tv.selectedRow;
    if (sr == -1)
    {
        self.itemSelected = false;
        return;
    }
    self.itemSelected = true;
    
    KBYTStream *stream = [[self streamArray] objectAtIndex:sr];
    self.itemPlayable = [stream playable];
    
    [self.streamController setSelectionIndex:sr];
    [self updateSlider];
    
}

//update the slider, if its an audio track the slider is visible and editable.

- (void)updateSlider
{
    KBYTStream *selectedObject = self.streamController.selectedObjects.lastObject;
    
    NSInteger itag = [selectedObject itag];
    if (itag == 140 || itag == 141)
    {
        self.slider.hidden = false;
        self.sliderLabel.hidden = false;
    } else {
        self.slider.hidden = true;
        self.sliderLabel.hidden = true;
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
