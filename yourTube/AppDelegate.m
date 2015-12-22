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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    KBYourTube *tube = [[KBYourTube alloc] init];
    NSArray *streamArray = [tube getVideoStreamsForID:@"_7nYuyfkjCk"];
    NSLog(@"streamArray: %@", streamArray);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
