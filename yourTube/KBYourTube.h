//
//  KBYourTube.h
//  yourTube
//
//  Created by Kevin Bradley on 12/21/15.
//  Copyright © 2015 nito. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KBYourTube : NSObject

@property (nonatomic, strong) NSString *yttimestamp;
@property (nonatomic, strong) NSString *ytkey;

+ (id)sharedInstance;

- (void)getVideoDetailsForID:(NSString*)videoID
  completionBlock:(void(^)(NSDictionary* videoDetails))completionBlock
     failureBlock:(void(^)(NSString* error))failureBlock;



@end
