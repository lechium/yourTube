//
//  ripURL.m
//  Seas0nPass
//
//  Created by Kevin Bradley on 3/9/07.
//  Copyright 2007 nito, LLC. All rights reserved.
//

/*
 
 class adapted from hawkeye's ripURL class for downloading youtube files, largely pruned to remove irrelevant sections + updated to cancel the xfer.
 
 */

#import "ripURL.h"


@implementation ripURL

@synthesize downloadLocation;

#pragma mark -
#pragma mark •• URL code

- (void)dealloc
{
	downloadLocation = nil;
}

- (void)cancel
{
	
	[self download:urlDownload didFailWithError:nil];
	[urlDownload cancel];
}


- (long long)updateFrequency
{
	return updateFrequency;
}

- (void)setUpdateFrequency:(long long)newUpdateFrequency
{
	updateFrequency = newUpdateFrequency;
}

- (id)init
{
	if(self = [super init]) {
	[self setUpdateFrequency:1];
	}
	
	return self;
}

- (void)downloadVideoWithURL:(NSURL *)url
                toLocation:(NSString *)dlLocation
                  progress:(DownloadProgressBlock)progressBlock
                 completed:(DownloadCompletedBlock)completedBlock
{
    self.CompletedBlock = completedBlock;
    self.ProgressBlock = progressBlock;
    self.downloadLocation = dlLocation;
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    urlDownload = [[NSURLDownload alloc] initWithRequest:theRequest delegate:self];
    [urlDownload setDestination:downloadLocation allowOverwrite:YES];
 
}


- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error

{
	NSLog(@"error: %@", error);
	//[handler downloadFailed:downloadLocation];
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
   if(download == urlDownload) {

       
       if (self.CompletedBlock != nil)
       {
           self.CompletedBlock(downloadLocation);
       }
       
       
       
	}

}

- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response

{
    bytesReceived=0;
    [self setDownloadResponse:response];
}

- (void)setDownloadResponse:(NSURLResponse *)response
{
	myResponse = response;
}

- (NSURLResponse *)downloadResponse
{
    return myResponse;
}

- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(NSUInteger)length

{
    long long expectedLength = [[self downloadResponse] expectedContentLength];
    bytesReceived=bytesReceived+length;
    
    if (expectedLength != NSURLResponseUnknownLength) {
        
        double percentComplete=(bytesReceived/(float)expectedLength)*100.0;
       // NSLog(@"Percent complete - %f",percentComplete);
		
		if((freq%updateFrequency) == 0){
	        
            if (self.ProgressBlock != nil)
            {
                self.ProgressBlock(percentComplete);
            }
				
		}
		freq++;
		
       
        
    } else {
        
       // [downloadpBar setIndeterminate:YES];
        NSLog(@"Bytes received - %f",bytesReceived);
        
    }
	

    
}
@end
