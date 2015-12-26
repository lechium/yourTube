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

@synthesize itemSelected;

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
            
          //  NSLog(@"got details successfully: %@", videoDetails);
            self.resultsField.string = [videoDetails description];
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

- (IBAction)downloadFile:(id)sender {

    NSDictionary *selectedObject = self.streamController.selectedObjects.lastObject;
    NSURL *downloadURL = [NSURL URLWithString:selectedObject[@"downloadURL"]];
    NSLog(@"selectedObject: %@", selectedObject);
    [[NSWorkspace sharedWorkspace]openURL:downloadURL];
}

- (IBAction)playFile:(id)sender
{
    NSDictionary *selectedObject = self.streamController.selectedObjects.lastObject;
    NSURL *playURL = [NSURL URLWithString:selectedObject[@"url"]];
    [[NSWorkspace sharedWorkspace]openURL:playURL];
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
