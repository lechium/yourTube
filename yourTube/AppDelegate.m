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
    itemSelected = false;
    [self getResults:nil];
    
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
    NSDictionary *audioObject = nil;
    NSString *downloadText = @"Downloading media file...";
    NSDictionary *selectedObject = self.streamController.selectedObjects.lastObject;
    NSInteger itag = [[selectedObject valueForKey:@"itag"] integerValue];
    if (itag == 299 || itag == 137)
    {
        requiresMux = true;
        audioObject = [[self.streamController.arrangedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"itag == '140'"]]lastObject];
        downloadText = @"Downloading video file...";
    }
    NSString *downloadURL = selectedObject[@"url"];
    NSURL *url = [NSURL URLWithString:downloadURL];
    NSString *outputFile = [[self downloadFolder] stringByAppendingPathComponent:selectedObject[@"outputFilename"]];
    
    downloadFile = [ripURL new];
    self.downloading = true;
    self.downloadButton.title = @"Cancel";
    self.progressLabel.stringValue = downloadText;
    
    [downloadFile downloadVideoWithURL:url toLocation:outputFile progress:^(double percentComplete) {
        
        [self setDownloadProgress:percentComplete];
        
    } completed:^(NSString *downloadedFile) {
        
        [progressBar setDoubleValue:0];
        [progressBar setHidden:TRUE];
        
        if (requiresMux && audioObject != nil)
        {
           
            [progressBar setDoubleValue:0];
            [progressBar setHidden:false];
            NSString *downloadURL = audioObject[@"url"];
            NSURL *url = [NSURL URLWithString:downloadURL];
            downloadFile = [ripURL new];
            NSString *outputFile2 = [[self downloadFolder] stringByAppendingPathComponent:audioObject[@"outputFilename"]];
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
            [[NSWorkspace sharedWorkspace] openFile:downloadedFile];
            
            self.downloadButton.title = @"Download";
            self.downloading = false;
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
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
