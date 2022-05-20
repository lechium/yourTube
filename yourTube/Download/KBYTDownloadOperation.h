//
//  KBYTDownloadOperation.h
//  yourTubeiOS
//
//  Created by Kevin Bradley on 2/9/16.
//
//

#import <Foundation/Foundation.h>

@interface KBYTDownloadOperation: NSOperation <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>

typedef void(^DownloadCompletedBlock)(NSString *downloadedFile);


@property (nonatomic, strong) NSDictionary *downloadInfo;
@property (nonatomic, strong) NSString *downloadLocation;
@property (strong, atomic) void (^ProgressBlock)(double percentComplete);
@property (strong, atomic) void (^FancyProgressBlock)(double percentComplete, NSString *status);
@property (strong, atomic) void (^CompletedBlock)(NSString *downloadedFile);
@property (readwrite, assign) NSInteger trackDuration;

- (id)initWithInfo:(NSDictionary *)downloadDictionary
         completed:(DownloadCompletedBlock)theBlock;

@end
