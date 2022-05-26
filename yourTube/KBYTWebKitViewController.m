//
//  KBYTWebKitViewController.m
//  yourTube
//
//  Created by Kevin Bradley on 12/27/15.
//  Copyright © 2015 nito. All rights reserved.
//

#import "KBYTWebKitViewController.h"
#import "AppDelegate.h" //to silence the warning.

@class WebBasePluginPackage;

@interface WebView ( MyFlashPluginHack )
- (WebBasePluginPackage *)_pluginForMIMEType:(NSString *)MIMEType;
@end



@implementation MyWebView

- (WebBasePluginPackage *)_pluginForMIMEType:(NSString *)MIMEType
{
    LOG_SELF;
    if ( [MIMEType isEqualToString:@"application/x-shockwave-flash"] )
    {
        return [super _pluginForMIMEType:@"application/my-plugin-type"];
    }
    else
    {
        return [super _pluginForMIMEType:MIMEType];
    }
}

@end

@interface KBYTWebKitViewController()

@property (nonatomic, copy) void (^loadBlock)(NSString *innerHTML);

@end

@implementation KBYTWebKitViewController

@synthesize ourWebView;

- (id)init
{
    self = [super init];
   
    return self;
}

- (void)loadPageForInnerHTML:(NSString *)thePage completion:(void(^)(NSString *innerHTML))completionBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadBlock = completionBlock;
        
        [[ourWebView mainFrame] loadHTMLString:thePage baseURL:nil];
    });
}

- (IBAction)showWebWindow:(id)sender
{
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"https://www.youtube.com"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    
    [[ourWebView mainFrame] loadRequest:request];
    [[self webWindow] makeKeyAndOrderFront:self];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler
{
    LOG_SELF;
}

- (void)webView:(WebView *)webView decidePolicyForMIMEType:(NSString *)type request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{

}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    LOG_SELF;
    if (self.loadBlock) {
        NSString *innerHTML = [sender stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML;"];
        self.loadBlock(innerHTML);
        self.loadBlock = nil;
    }
}

//only way i could find to process video links being selected

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    NSString *url = [[frame DOMDocument] URL];
    
    //previousURL is a kludge to make sure we don't go back twice.
    if ([url length] > 32 && ![previousURL isEqualToString:url]){
        NSString *substring = [url substringToIndex:32];
        NSLog(@"substring: %@", substring);
        if ([substring isEqualToString:@"https://www.youtube.com/watch?v="])
        {
            previousURL = url;
            [sender stopLoading:nil];
            [(AppDelegate*)[[NSApplication sharedApplication] delegate] showVideoAtURL:url];
            [sender goBack];
            
        }
    }
}



@end
