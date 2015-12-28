//
//  KBYTWebKitViewController.h
//  yourTube
//
//  Created by Kevin Bradley on 12/27/15.
//  Copyright © 2015 nito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface MyWebView: WebView

@end

@interface KBYTWebKitViewController : NSObject <WebFrameLoadDelegate, WebResourceLoadDelegate, NSWindowDelegate, WKNavigationDelegate, WKUIDelegate, WebUIDelegate, WebPolicyDelegate>
{
    NSString *previousURL; //kludge to keep track of the last URL from the last title
}
@property (nonatomic, strong) IBOutlet MyWebView *ourWebView;
@property (nonatomic, assign) IBOutlet NSWindow *webWindow;

- (IBAction)showWebWindow:(id)sender;
@end
