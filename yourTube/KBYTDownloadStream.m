//
//  KBYTDownloadStream.m
//  Seas0nPass
//
//  Created by Kevin Bradley on 3/9/07.
//  Copyright 2007 nito, LLC. All rights reserved.
//

/*
 
 class adapted from hawkeye's KBYTDownloadStream class for downloading youtube files, largely pruned to remove irrelevant sections + updated to cancel the xfer + remodified/updated to use blocks instead of antiquated delegate methods.
 
 */

#import "KBYTDownloadStream.h"


@implementation KBYTDownloadStream

@synthesize downloadLocation;

#pragma mark -
#pragma mark •• URL code

- (void)dealloc
{
	downloadLocation = nil;
}

- (void)cancel
{
    NSError *theError = nil;
	[self download:urlDownload didFailWithError:theError];
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

- (void)downloadStream:(KBYTStream *)inputStream
              progress:(FancyDownloadProgressBlock)progressBlock
             completed:(DownloadCompletedBlock)completedBlock
{
    self.CompletedBlock = completedBlock;
    self.FancyProgressBlock = progressBlock;

    self.downloadLocation = [[self downloadFolder] stringByAppendingPathComponent:inputStream.outputFilename];
    if (inputStream.audioStream != nil)
    {
        audioStream = inputStream.audioStream;
        self.downloadMode = 1;
    } else {
        self.downloadMode = 0;
    }
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:inputStream.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    urlDownload = [[NSURLDownload alloc] initWithRequest:theRequest delegate:self];
    [urlDownload setDestination:downloadLocation allowOverwrite:YES];
    
}

//deprecated / obsolete, SHOULD still work but should never be used.
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

       //audioStream is only set when theres adaptive video / audio streams that aren't multiplexed, the variable is also invalidated after the audio download is started.
       
       if (audioStream != nil)
       {
           videoDownloadLocation = self.downloadLocation; //back it up for when we mux, not elegant, but works.
           self.downloadLocation = [[self downloadFolder] stringByAppendingPathComponent:audioStream.outputFilename];
           NSURLRequest *theRequest = [NSURLRequest requestWithURL:audioStream.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
           audioStream = nil;
           urlDownload = [[NSURLDownload alloc] initWithRequest:theRequest delegate:self];
           [urlDownload setDestination:downloadLocation allowOverwrite:YES];
           return;
       }
       
       //downloading audio and video, since audioStream var is nil it means we have both.
       if (self.downloadMode == 1)
       {
           self.FancyProgressBlock(0, @"Multiplexing files...");
           NSString *videoStream = videoDownloadLocation;
           [[KBYourTube sharedInstance] muxFiles:@[videoStream, [self downloadLocation]] completionBlock:^(NSString *newFile) {
               
               self.CompletedBlock(newFile);
               
           }];
           
           return;
       }
       /*
        if we get this far we aren't download mode 1 with both audio / video downloading (Single file download)
       */
       if ([downloadLocation.pathExtension isEqualToString:@"aac"])
       {
           self.FancyProgressBlock(0, @"Fixing audio...");
           NSInteger volumeInt = [[NSUserDefaults standardUserDefaults] integerForKey:@"volume"];
           [[KBYourTube sharedInstance] fixAudio:downloadLocation volume:volumeInt completionBlock:^(NSString *newFile) {
               if (self.CompletedBlock != nil)
               {
                   self.CompletedBlock(newFile);
               }
           }];
           
           return;
       }
       
       //non adaptive files that are already multiplexed will be generically processed if we get this far
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
            
            if (self.FancyProgressBlock != nil)
            {
                NSString *mediaType = @"media";
                NSString *pathExt = downloadLocation.pathExtension;
                if ([pathExt isEqualToString:@"m4v"])
                {
                    mediaType = @"video";
                } else if ([pathExt isEqualToString:@"aac"])
                {
                    mediaType = @"audio";
                }
                self.FancyProgressBlock(percentComplete, [NSString stringWithFormat:@"Downloading %@ file...", mediaType]);
            }
		}
		freq++;
	    
    } else {
        
        NSLog(@"Bytes received - %f",bytesReceived);
        
    }
	
}
@end
