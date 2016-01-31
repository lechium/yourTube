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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [AppDelegate setDefaultPrefs];
    itemSelected = false;
    [self getResults:nil];
    [[self webkitController] showWebWindow:nil];
    [self.window setDelegate:self];
    
    NSDate *myStart = [NSDate date];
    
    [[KBYourTube sharedInstance] youTubeSearch:@"Drake rick ross" pageNumber:1 completionBlock:^(NSDictionary *searchDetails) {
        
        NSLog(@"time taken: %@ searchDetails: %@", [myStart timeStringFromCurrentDate], searchDetails);
        
        
    } failureBlock:^(NSString *error) {
        
        //
    }];
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
    NSString *textResults = self.youtubeLink.stringValue;
    
    if ([[textResults componentsSeparatedByString:@"="] count] > 1)
    {
        textResults = [[textResults componentsSeparatedByString:@"="] lastObject];
        //   NSLog(@"text results: %@", textResults);
    }
    
    if ([textResults length] > 0)
    {
        [[KBYourTube sharedInstance] getVideoDetailsForID:textResults completionBlock:^(KBYTMedia *videoDetails) {
            
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
