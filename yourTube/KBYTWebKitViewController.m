//
//  KBYTWebKitViewController.m
//  yourTube
//
//  Created by Kevin Bradley on 12/27/15.
//  Copyright © 2015 nito. All rights reserved.
//

#import "KBYTWebKitViewController.h"

@implementation KBYTWebKitViewController

@synthesize ourWebView;

- (id)init
{
    NSLog(@"init");
    self = [super init];
   
    return self;
}

- (IBAction)showWebWindow:(id)sender
{
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"https://www.youtube.com"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    
    [[ourWebView mainFrame] loadRequest:request];
    [[self webWindow] makeKeyAndOrderFront:self];
}


- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    NSString *url = [[frame DOMDocument] URL];
    if ([url length] > 32){
        NSString *substring = [url substringToIndex:32];
        if ([substring isEqualToString:@"https://www.youtube.com/watch?v="])
        {
            [sender goBack:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"idReceived" object:nil userInfo:@{@"url": url}];
            //[self.webWindow close];
        }
    }
}



@end
