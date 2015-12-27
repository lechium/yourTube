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
        [progressBar setDoubleValue:0];
        [progressBar setHidden:TRUE];
        return;
    }
    
    NSDictionary *selectedObject = self.streamController.selectedObjects.lastObject;
    NSString *downloadURL = selectedObject[@"url"];
    NSURL *url = [NSURL URLWithString:downloadURL];
    
    NSString *outputFile = [[self downloadFolder] stringByAppendingPathComponent:selectedObject[@"outputFilename"]];
    
    downloadFile = [ripURL new];
    self.downloading = true;
    self.downloadButton.title = @"Cancel";
    
    [downloadFile downloadVideoWithURL:url toLocation:outputFile progress:^(double percentComplete) {
        
        [self setDownloadProgress:percentComplete];
        
    } completed:^(NSString *downloadedFile) {
        
        [progressBar setDoubleValue:0];
        [progressBar setHidden:TRUE];
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
        
        //[[NSWorkspace sharedWorkspace] openFile:downloadedFile];
     
        self.downloadButton.title = @"Download";
        self.downloading = false;
    }];

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
