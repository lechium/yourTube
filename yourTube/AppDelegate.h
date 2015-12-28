//
//  AppDelegate.h
//  yourTube
//
//  Created by Kevin Bradley on 12/21/15.
//  Copyright © 2015 nito. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "ripURL.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate>


@property (nonatomic, assign) IBOutlet NSTextField *youtubeLink;
@property (nonatomic, assign) IBOutlet NSTextField *titleField;
@property (nonatomic, assign) IBOutlet NSTextField *userField;
@property (nonatomic, assign) IBOutlet NSTextField *lengthField;
@property (nonatomic, assign) IBOutlet NSTextField *viewsField;
@property (nonatomic, assign) IBOutlet NSImageView *imageView;
@property (nonatomic, assign) IBOutlet NSButton *downloadButton;
@property (nonatomic, assign) IBOutlet NSArrayController *streamController;
@property (nonatomic, strong) NSArray *streamArray;
@property (readwrite, assign) BOOL itemSelected;
@property (nonatomic, assign) IBOutlet NSTextField *progressLabel;
@property (nonatomic, assign) IBOutlet NSProgressIndicator *progressBar;

@property (nonatomic, assign) IBOutlet NSTextField *sliderLabel;
@property (nonatomic, assign) IBOutlet NSSlider *slider;

@property (nonatomic, strong) ripURL *downloadFile;
@property (readwrite, assign) BOOL downloading;
@property (readwrite, assign) BOOL extractAudio;

@property (nonatomic, assign) IBOutlet NSWindow *playerWindow;
@property (nonatomic, assign) IBOutlet AVPlayerView *playerView;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NSWindow *prefWindow;

- (IBAction)getResults:(id)sender;
- (IBAction)downloadFile:(id)sender;
- (IBAction)playFile:(id)sender;

- (IBAction)setDownloadLocation:(id)sender;

@end

