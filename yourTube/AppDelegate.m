//
//  AppDelegate.m
//  yourTube
//
//  Created by Kevin Bradley on 12/21/15.
//  Copyright © 2015 nito. All rights reserved.
//

#import "AppDelegate.h"
#import "KBYourTube.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
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

- (NSArray *)onoPlaylistList:(NSString *)listID
{
    // NSString *requestString = @"https://www.youtube.com/channel/UC-9-kyTW8ZkZNDHQJ6FgpwQ/videos";
    NSString *requestString = [NSString stringWithFormat:@"https://www.youtube.com/playlist?list=%@", listID];
    NSString *rawRequestResult = [self stringFromRequest:requestString];
    ONOXMLDocument *xmlDoc = [ONOXMLDocument HTMLDocumentWithString:rawRequestResult encoding:NSUTF8StringEncoding error:nil];
    ONOXMLElement *root = [xmlDoc rootElement];
    //NSLog(@"root element: %@", root);
    
    ONOXMLElement *videosElement = [root firstChildWithXPath:@"//*[contains(@class, 'pl-video-list')]"];
    id videoEnum = [videosElement XPath:@".//*[contains(@class, 'pl-video')]"];
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
            outputDict[@"results"] = finalArray;
            outputDict[@"resultCount"] = [NSNumber numberWithInteger:[finalArray count]];
            NSInteger pageCount = 1;
            outputDict[@"pageCount"] = [NSNumber numberWithInteger:pageCount];
        }
    }
    return finalArray;
}

- (NSArray *)onoVideoChannelsList:(NSString *)channelID
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
            outputDict[@"results"] = finalArray;
            outputDict[@"resultCount"] = [NSNumber numberWithInteger:[finalArray count]];
            NSInteger pageCount = 1;
            outputDict[@"pageCount"] = [NSNumber numberWithInteger:pageCount];
        }
    }
    return finalArray;
}

- (NSArray *)onoSearchQuery:(NSString *)searchQuery pageNumber:(NSInteger)page
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
    ONOXMLDocument *xmlDoc = [ONOXMLDocument HTMLDocumentWithString:rawRequestResult encoding:NSUTF8StringEncoding error:nil];
    ONOXMLElement *root = [xmlDoc rootElement];
    //NSLog(@"root element: %@", root);
    NSString *XPath = @"//ol[contains(@class, 'section-list')]";
    ONOXMLElement *sectionListElement = [root firstChildWithXPath:XPath];
    ONOXMLElement *numListElement = [sectionListElement firstChildWithXPath:@"//p[contains(@class,'num-results')]"];
    NSInteger results = 0;
    if (numListElement !=nil)
    {
        NSString *resultText = [numListElement stringValue];
        results = [[[[[resultText componentsSeparatedByString:@"About"] lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@"," withString:@""] integerValue];
    }
    ONOXMLElement *videosElement = [sectionListElement firstChildWithXPath:@"//ol[contains(@class, 'item-section')]"];
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
        if ([finalArray count] > 0)
        {
            outputDict[@"results"] = finalArray;
            NSInteger pageCount = results/[finalArray count];
            outputDict[@"pageCount"] = [NSNumber numberWithInteger:pageCount];
        }
    }
    return finalArray;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [AppDelegate setDefaultPrefs];
    itemSelected = false;
    [self getResults:nil];
    [[self webkitController] showWebWindow:nil];
    [self.window setDelegate:self];
 //   NSDate *myStart = [NSDate date];
    //NSArray *featuredVids = [self onoSearchQuery:nil pageNumber:1];
    //music channel = UC-9-kyTW8ZkZNDHQJ6FgpwQ
    //popular on yt = UCF0pVplsI8R5kcAqgtoRqoA
    //sports = UCEgdi0XIXXZ-qJOFPf4JSKw
    //gaming = UCOpNcN46UbXVtpKMrmU4Abg
    //news = UCYfdidRxbB8Qhf0Nx7ioOYw
    //live = UC4R8DWoMoI7CAwX8_LjQHig
    //360 = UCzuqhhs6NWbgTzMuM09WKDQ
  //  NSArray *channelVids = [self onoVideoChannelsList:@"UCiuFEQ2-YiaW97Uzu00bOZQ"];
    //NSLog(@"channelVids: %@", channelVids);
  
 
    //NSArray *playlistItems = [self onoPlaylistList:@"FLiuFEQ2-YiaW97Uzu00bOZQ"];
    
    //NSLog(@"playlist items: %@", playlistItems);
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
    
    NSArray *values = [NSArray arrayWithObjects:
                       [self downloadFolder],
                       @"https://www.youtube.com/watch?v=6pxRHBw-k8M",
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
        [[KBYourTube sharedInstance] getVideoDetailsForID:videoID completionBlock:^(KBYTMedia *videoDetails) {
            
           //  NSLog(@"got details successfully: %@", videoDetails);
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
            
        }];
    }
    
}

- (void)downloadFailed:(NSString *)theDownload
{
    
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
