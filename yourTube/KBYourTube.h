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

- (NSArray *)getVideoStreamsForID:(NSString *)videoID;

@end
