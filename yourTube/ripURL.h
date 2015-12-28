//
//  ripURL.h
//  Seas0nPass
//
//  Created by Kevin Bradley on 3/9/07.
//  Copyright 2007 nito, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ripURLDelegate

- (void)downloadFinished:(NSString *)downloadFile;
- (void)downloadFailed:(NSString *)downloadFile;
- (void)setDownloadProgress:(double)theProgress;

@end


@interface ripURL : NSObject <NSURLDownloadDelegate>  {
	
	NSURLDownload				*urlDownload;
    NSURLResponse				*myResponse;
	float						bytesReceived;
	NSString					*downloadLocation;
	long long					updateFrequency;
	long long					freq;
}

@property (strong, atomic) void (^ProgressBlock)(double percentComplete);
@property (strong, atomic) void (^CompletedBlock)(NSString *downloadedFile);

typedef void(^DownloadProgressBlock)(double percentComplete);
typedef void(^DownloadCompletedBlock)(NSString *downloadedFile);

@property (nonatomic, retain) NSString *downloadLocation;


- (void)downloadVideoWithURL:(NSURL *)url
                toLocation:(NSString *)dlLocation
                  progress:(DownloadProgressBlock)progressBlock
                 completed:(DownloadCompletedBlock)completedBlock;


- (long long)updateFrequency;
- (void)setUpdateFrequency:(long long)newUpdateFrequency;
- (void)setDownloadResponse:(NSURLResponse *)response;
- (void)cancel;

@end
