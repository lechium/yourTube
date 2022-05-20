//
//  YTDownloadOperation.m
//  yourTubeiOS
//
//  Created by Kevin Bradley on 2/9/16.
//
//

#define FM [NSFileManager defaultManager]

#import "KBYTDownloadOperation.h"
#import "KBYourTube.h"
@interface KBYTDownloadOperation (){
    
    BOOL _running;
    
}
@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURLSessionDownloadTask *downloadTask;
@end

//download operation class, handles file downloads.


@implementation KBYTDownloadOperation

@synthesize downloadInfo, downloadLocation, trackDuration, CompletedBlock;





- (BOOL)isAsynchronous
{
    return true;
}

- (id)initWithInfo:(NSDictionary *)downloadDictionary completed:(DownloadCompletedBlock)theBlock
{
    self = [super init];
    //NSLog(@"init with info: %@ ", downloadDictionary);
    downloadInfo = downloadDictionary;
    self.name = downloadInfo[@"title"];
    NSString *baseName = downloadDictionary[@"outputFilename"];
    if ([[downloadDictionary allKeys] containsObject:@"downloadFolder"]){
        
        NSString *customFolder = [[self downloadFolder] stringByAppendingPathComponent:downloadDictionary[@"downloadFolder"]];
        
        if (![FM fileExistsAtPath:customFolder]){
            
            [FM createDirectoryAtPath:customFolder withIntermediateDirectories:true attributes:nil error:nil];
            
        }
        
         self.downloadLocation = [customFolder stringByAppendingPathComponent:baseName];
        
    } else {
        self.downloadLocation = [[self downloadFolder] stringByAppendingPathComponent:baseName];
    }
    
    NSString *imageURL = downloadInfo[@"images"][@"standard"];
    NSData *downloadData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    NSString *outputJPEG = [[[self downloadLocation] stringByDeletingPathExtension] stringByAppendingPathExtension:@"jpg"];
    [downloadData writeToFile:outputJPEG atomically:true];
    NSInteger durationSeconds = [downloadDictionary[@"duration"] integerValue];
    trackDuration = durationSeconds*1000;
    CompletedBlock = theBlock;
    
    return self;
}

- (void)cancel
{
    [super cancel];
    //[self.downloader cancel];
    [[self downloadTask] cancel];
}

/*
- (void)main
{
    [self start];
  
}

*/

- (void)sendAudioCompleteMessage
{
    #if TARGET_OS_IOS
    CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"org.nito.dllistener"];
    NSDictionary *info = @{@"file": self.downloadLocation.lastPathComponent};
    
    [center sendMessageName:@"org.nito.dllistener.audioImported" userInfo:info];
#endif
}




- (void)start
{
    self.session = [self backgroundSessionWithId:self.downloadInfo[@"title"]];
    
    if (self.downloadTask)
    {
        return;
    }
    
    NSLog(@"starting task...");
    /*
     Create a new download task using the URL session. Tasks start in the “suspended” state; to start a task you need to explicitly call -resume on a task after creating it.
     */
    NSURL *downloadURL = [NSURL URLWithString:downloadInfo[@"url"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    self.downloadTask = [self.session downloadTaskWithRequest:request];
    [self.downloadTask resume];
    _running = true;
    //[self waitUntilFinished];
}



- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    /*
     Report progress on the task.
     If you created more than one task, you might keep references to them and report on them individually.
     */
    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    NSLog(@"progress: %lf to file %@", progress, self.downloadLocation.lastPathComponent);
     NSDictionary *info = @{@"status": self.downloadLocation.lastPathComponent,@"percentComplete": [NSNumber numberWithFloat:progress] };
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"updateProgressNote" object:nil userInfo:info];
    if (downloadTask == self.downloadTask)
    {
        double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        //NSLog(@"DownloadTask: %@ progress: %lf to file %@", downloadTask, progress, self.downloadLocation);
        dispatch_async(dispatch_get_main_queue(), ^{
#if TARGET_OS_IOS
            yourTubeApplication *appDelegate = (yourTubeApplication *)[[UIApplication sharedApplication] delegate];
            if ([[[appDelegate nav] visibleViewController] isKindOfClass:[KBYTDownloadsTableViewController class]])
            {
                NSDictionary *info = @{@"file": self.downloadLocation.lastPathComponent,@"completionPercent": [NSNumber numberWithFloat:progress] };
                [(KBYTDownloadsTableViewController*)[[appDelegate nav] visibleViewController] updateDownloadProgress:info];
            }
#endif
            // self.progressView.progress = progress;
        });
    }
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)downloadURL
{
    
    /*
     The download completed, you need to copy the file at targetPath before the end of this block.
     As an example, copy the file to the Documents directory of your app.
     */
    
    NSURL *destinationURL = [NSURL fileURLWithPath:[self downloadLocation]];
    NSError *errorCopy;
    
    // For the purposes of testing, remove any esisting file at the destination.
    [FM removeItemAtURL:destinationURL error:NULL];
    BOOL success = [FM copyItemAtURL:downloadURL toURL:destinationURL error:&errorCopy];
    
    if (success)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
#if TARGET_OS_IOS
            yourTubeApplication *appDelegate = (yourTubeApplication *)[[UIApplication sharedApplication] delegate];
            if ([[[appDelegate nav] visibleViewController] isKindOfClass:[KBYTDownloadsTableViewController class]])
            {
                [(KBYTDownloadsTableViewController*)[[appDelegate nav] visibleViewController] delayedReloadData];
            }
#endif
        });
    }
    else
    {
        /*
         In the general case, what you might do in the event of failure depends on the error and the specifics of your application.
         */
        NSLog(@"Error during the copy: %@", [errorCopy localizedDescription]);
    }
}

- (BOOL)isExecuting {
    
    return _running;
}

- (BOOL)isFinished {
 
    return !_running;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    
    if (error == nil)
    {
        NSLog(@"Task: %@ completed successfully", task);
        if (self.CompletedBlock != nil)
        {
            _running = false;
            [self isFinished];
            self.CompletedBlock(downloadLocation);
        }
    }
    else
    {
        NSLog(@"Task: %@ completed with error: %@", task, [error localizedDescription]);
        if (self.CompletedBlock != nil)
        {
            _running = false;
            [self isFinished];
            self.CompletedBlock(downloadLocation);
        }
    }
    
    double progress = (double)task.countOfBytesReceived / (double)task.countOfBytesExpectedToReceive;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"progress; %f", progress);
        //  self.progressView.progress = progress;
    });
    
    self.downloadTask = nil;
}


- (NSURLSession *)backgroundSessionWithId:(NSString *)sessionID
{
    /*
     Using disptach_once here ensures that multiple background sessions with the same identifier are not created in this instance of the application. If you want to support multiple background sessions within a single process, you should create each session with its own identifier.
     */
    static NSURLSession *session = nil;
    
    static dispatch_once_t onceToken;

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:sessionID];
    session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    return session;
}




@end
