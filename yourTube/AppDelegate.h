//
//  AppDelegate.h
//  yourTube
//
//  Created by Kevin Bradley on 12/21/15.
//  Copyright © 2015 nito. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>


@property (nonatomic, assign) IBOutlet NSTextField *youtubeLink;
@property (nonatomic, assign) IBOutlet NSTextView *resultsField;

- (IBAction)getResults:(id)sender;

@end

