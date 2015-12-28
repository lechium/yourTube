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

@synthesize itemSelected, progressBar, downloadFile;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [AppDelegate setDefaultPrefs];
    itemSelected = false;
    [self getResults:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(idReceived:) name:@"idReceived" object:nil];
    [[self webkitController] showWebWindow:nil];
    //NSLog(@"window delegate: %@", [[self window] delegate]);
    [self.window setDelegate:self];
    
}

- (void)idReceived:(NSNotification *)n
{
    NSString *url = n.userInfo[@"url"];
    self.youtubeLink.stringValue = url;
    [self getResults:nil];
    [[NSUserDefaults standardUserDefaults] setObject:url forKey:@"lastDownloadLink"];
    
}


- (void)windowWillClose:(NSNotification *)notification
{
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
    NSMenuItem *showMainWindowItem = [[NSMenuItem alloc] initWithTitle:@"Show Video Details" action:@selector(showMainWindow:) keyEquivalent:@"1"];
    [showMainWindowItem setTarget:self];
    [showMainWindowItem setTag:150];
    [[menuItem submenu] insertItem:showMainWindowItem atIndex:5];
}

- (IBAction)showMainWindow:(id)sender
{
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
    NSMenuItem *ourItem = [[menuItem submenu] itemWithTag:150];
    [[menuItem submenu] removeItem:ourItem];
    [[self window] makeKeyAndOrderFront:self];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    LOG_SELF;
    if ([menuItem tag] == 150)
    {
        if ([[self window] isVisible] == true) {
            return FALSE;
        }
    }
    return TRUE;
}

+ (void)setDefaultPrefs
{
    LOG_SELF;
    NSString *dlLoc = [[NSUserDefaults standardUserDefaults] valueForKey:@"downloadLocation"];
    if ([dlLoc length] == 0)
    {
        [[NSUserDefaults standardUserDefaults] setValue:[self downloadFolder] forKey:@"downloadLocation"];
    }
    
    NSString *dlLink = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastDownloadLink"];
    if ([dlLink length] == 0)
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"https://www.youtube.com/watch?v=6pxRHBw-k8M" forKey:@"lastDownloadLink"];
        //
    }
}



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
        [[KBYourTube sharedInstance] getVideoDetailsForID:textResults completionBlock:^(NSDictionary *videoDetails) {
            
            //NSLog(@"got details successfully: %@", videoDetails);
            self.titleField.stringValue = videoDetails[@"title"];
            self.userField.stringValue = videoDetails[@"author"];
            self.lengthField.stringValue = videoDetails[@"duration"];
            self.viewsField.stringValue = videoDetails[@"views"];
            self.imageView.image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:videoDetails[@"images"][@"high"]]];
            
            self.streamArray = videoDetails[@"streams"];
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


- (IBAction)downloadFile:(id)sender {

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
    
    BOOL requiresMux = false;
    BOOL fixAudio = false;
    NSDictionary *audioObject = nil;
    NSString *downloadText = @"Downloading media file...";
    NSDictionary *selectedObject = self.streamController.selectedObjects.lastObject;
    NSInteger itag = [[selectedObject valueForKey:@"itag"] integerValue];
    if (itag == 299 || itag == 137 || itag == 138 || itag == 264 || itag == 266)
    {
        requiresMux = true;
        audioObject = [[self.streamController.arrangedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"itag == '140'"]]lastObject];
        downloadText = @"Downloading video file...";
    }
    if (itag == 140 || itag == 141)
    {
        fixAudio = true;
    }
    NSString *downloadURL = selectedObject[@"url"];
    NSURL *url = [NSURL URLWithString:downloadURL];
    NSString *outputDest = [[NSUserDefaults standardUserDefaults] valueForKey:@"downloadLocation"];
    if ([outputDest length] == 0)
    {
        outputDest = [self downloadFolder];
    }
    NSString *outputFile = [outputDest stringByAppendingPathComponent:selectedObject[@"outputFilename"]];
    
    downloadFile = [ripURL new];
    self.downloading = true;
    self.downloadButton.title = @"Cancel";
    self.progressLabel.stringValue = downloadText;
    
    [downloadFile downloadVideoWithURL:url toLocation:outputFile progress:^(double percentComplete) {
        
        [self setDownloadProgress:percentComplete];
        
    } completed:^(NSString *downloadedFile) {
        
        [progressBar setDoubleValue:0];
        [progressBar setHidden:TRUE];
        self.progressLabel.stringValue = @"";
        if (requiresMux == true && audioObject != nil)
        {
           
            [progressBar setDoubleValue:0];
            [progressBar setHidden:false];
            NSString *downloadURL = audioObject[@"url"];
            NSURL *url = [NSURL URLWithString:downloadURL];
            downloadFile = [ripURL new];
            NSString *outputFile2 = [outputDest stringByAppendingPathComponent:audioObject[@"outputFilename"]];
             NSLog(@"requires muxing, downloading audio now: %@", outputFile2);
             self.progressLabel.stringValue = @"Downloading audio file...";
            [downloadFile downloadVideoWithURL:url toLocation:outputFile2 progress:^(double percentComplete) {
                
                [self setDownloadProgress:percentComplete];
                
                
            } completed:^(NSString *downloadedFile) {
                
                self.downloadButton.enabled = false;
                self.progressLabel.stringValue = @"Multiplexing files...";
                [progressBar setDoubleValue:1];
                [progressBar setIndeterminate:true];
                [progressBar startAnimation:self];
                [progressBar setHidden:false];
                [self muxFiles:@[outputFile, outputFile2] completionBlock:^(NSString *newFile) {
                   
                    NSFileManager *man = [NSFileManager defaultManager];
                    [man removeItemAtPath:outputFile error:nil];
                    [man removeItemAtPath:outputFile2 error:nil];
                    [[NSWorkspace sharedWorkspace] openFile:newFile];
                    self.downloadButton.enabled = true;
                    [progressBar stopAnimation:self];
                    [progressBar setHidden:true];
                    self.progressLabel.stringValue = @"";
                }];
                //
                //[[NSWorkspace sharedWorkspace] openFile:downloadedFile];
                
                self.downloadButton.title = @"Download";
                self.downloading = false;
                
            }];
            
        } else {
            
            NSLog(@"else!");
            
            if (fixAudio == true)
            {
                NSInteger volumeInt = [[NSUserDefaults standardUserDefaults] integerForKey:@"volume"];
                NSLog(@"fix audio with volume: %lu", (long)volumeInt);
                [[KBYourTube sharedInstance] fixAudio:downloadedFile volume:volumeInt completionBlock:^(NSString *newFile) {
                    
                    [[NSWorkspace sharedWorkspace] openFile:newFile];
                    
                    self.downloadButton.title = @"Download";
                    self.downloading = false;
                }];
                
            } else {
                [[NSWorkspace sharedWorkspace] openFile:downloadedFile];
                
                self.progressLabel.stringValue = @"";
                [self.progressBar stopAnimation:self];
                self.progressBar.hidden = true;
                [self.progressBar setDoubleValue:0];
                
                [self.progressBar setHidden:true];
                self.downloadButton.title = @"Download";
                self.downloading = false;
            }
            
            
        }
        
       /*
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"extractAudio"] == true)
        {
            [progressBar setDoubleValue:1];
            [progressBar setIndeterminate:true];
            [progressBar startAnimation:self];
            [progressBar setHidden:false];
            [[KBYourTube sharedInstance] extractAudio:downloadedFile completionBlock:^(NSString *newFile) {
                
                NSLog(@"new audio file: %@", newFile);
                [progressBar setDoubleValue:0];
                [progressBar setHidden:true];
             
                [[NSWorkspace sharedWorkspace] openFile:newFile];
            }];
        }
        */
        
        
    }];

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

- (IBAction)playFile:(id)sender
{
    NSDictionary *selectedObject = self.streamController.selectedObjects.lastObject;
    NSURL *playURL = [NSURL URLWithString:selectedObject[@"url"]];
    self.player = [[AVPlayer alloc] initWithURL:playURL];
    [self.playerView setPlayer:self.player];
    [self.player play];
    
    [self.playerWindow makeKeyAndOrderFront:nil];
    
    // [[NSWorkspace sharedWorkspace]openURL:playURL];
}

- (IBAction)setDownloadLocation:(id)sender{
    
    NSOpenPanel *op = [NSOpenPanel new];
    [op setCanChooseDirectories:true];
    [op setCanChooseFiles:false];
    [op setTitle:@"Choose a download location please"];
    NSInteger modalResult = [op runModal];
    
    if (modalResult == NSModalResponseOK)
    {
        NSString *fn = [op filename];
        NSLog(@"fn: %@", fn);
        [[NSUserDefaults standardUserDefaults] setValue:fn forKey:@"downloadLocation"];
    }
    
    
    
    
}

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
    [self.streamController setSelectionIndex:sr];
    [self updateSlider];
}

- (void)updateSlider
{
    NSDictionary *selectedObject = self.streamController.selectedObjects.lastObject;
    NSInteger itag = [[selectedObject valueForKey:@"itag"] integerValue];
    if (itag == 140)
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
