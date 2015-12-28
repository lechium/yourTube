//
//  KBYTWebKitViewController.h
//  yourTube
//
//  Created by Kevin Bradley on 12/27/15.
//  Copyright © 2015 nito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface KBYTWebKitViewController : NSObject <WebFrameLoadDelegate, WebResourceLoadDelegate, NSWindowDelegate, WKNavigationDelegate, WKUIDelegate, WebUIDelegate>

@property (nonatomic, strong) IBOutlet WebView *ourWebView;
@property (nonatomic, assign) IBOutlet NSWindow *webWindow;

- (IBAction)showWebWindow:(id)sender;
@end
