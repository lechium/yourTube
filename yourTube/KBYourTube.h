//
//  KBYourTube.h
//  yourTube
//
//  Created by Kevin Bradley on 12/21/15.
//  Copyright © 2015 nito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBYTWebKitViewController.h"

@interface NSObject  (convenience)

- (NSString *)applicationSupportFolder;
- (NSString *)downloadFolder;

@end

@interface NSString  (SplitString)

- (NSArray *)splitString;

@end

@interface KBYourTube : NSObject
{
    NSInteger bestTag;
}

@property (nonatomic, strong) NSString *yttimestamp;
@property (nonatomic, strong) NSString *ytkey;


+ (id)sharedInstance;

- (void)getVideoDetailsForID:(NSString*)videoID
  completionBlock:(void(^)(NSDictionary* videoDetails))completionBlock
     failureBlock:(void(^)(NSString* error))failureBlock;

- (void)fixAudio:(NSString *)theFile
          volume:(NSInteger)volume
 completionBlock:(void(^)(NSString *newFile))completionBlock;

- (void)extractAudio:(NSString *)theFile
     completionBlock:(void(^)(NSString *newFile))completionBlock;

@end
