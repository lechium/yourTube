//
//  KBYourTube.h
//  yourTube
//
//  Created by Kevin Bradley on 12/21/15.
//  Copyright © 2015 nito. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const KBYTMusicChannelID   =  @"UC-9-kyTW8ZkZNDHQJ6FgpwQ";
static NSString *const KBYTPopularChannelID =  @"UCF0pVplsI8R5kcAqgtoRqoA";
static NSString *const KBYTSportsChannelID  =  @"UCEgdi0XIXXZ-qJOFPf4JSKw";
static NSString *const KBYTGamingChannelID  =  @"UCOpNcN46UbXVtpKMrmU4Abg";
static NSString *const KBYT360ChannelID     =  @"UCzuqhhs6NWbgTzMuM09WKDQ";
static NSString *const KBYTFashionAndBeautyID =  @"UCrpQ4p1Ql_hG8rKXIKM1MOQ";
static NSString *const KBYTSpotlightChannelID = @"UCBR8-60-B28hp2BmDPdntcQ";

typedef NS_ENUM(NSUInteger, kYTSearchResultType) {
    
    kYTSearchResultTypeUnknown,
    kYTSearchResultTypeVideo,
    kYTSearchResultTypePlaylist,
    kYTSearchResultTypeChannel,
};

typedef NS_ENUM(NSUInteger, KBYTSearchType) {
    KBYTSearchTypeAll,
    KBYTSearchTypeVideos,
    KBYTSearchTypeChannels,
    KBYTSearchTypePlaylists,
};


@interface KBYTSearchResult: NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *videoId;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic, strong) NSString *age;
@property (nonatomic, strong) NSString *views;
@property (nonatomic, strong) NSString *details;
@property (nonatomic, strong) NSString *continuationToken;
@property (readwrite, assign) kYTSearchResultType resultType;

- (id)initWithDictionary:(NSDictionary *)resultDict;

@end

@interface KBYTChannel: NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *channelID;
@property (nonatomic, strong) NSString *continuationToken;
@property (nonatomic, strong) NSArray <KBYTSearchResult *> *videos;
@property (nonatomic, strong) NSArray <KBYTSearchResult *> *playlists;

@end

@interface KBYTPlaylist: NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *playlistID;
@property (nonatomic, strong) NSString *continuationToken;
@property (nonatomic, strong) NSArray <KBYTSearchResult *> *videos;

@end

@interface KBYTSearchResults: NSObject

@property (nonatomic, strong) NSString *continuationToken;
@property (nonatomic, strong) NSArray <KBYTSearchResult *> *videos;
@property (nonatomic, strong) NSArray <KBYTSearchResult *> *playlists;
@property (nonatomic, strong) NSArray <KBYTSearchResult *> *channels;
@property (readwrite, assign) NSInteger estimatedResults;
- (void)processJSON:(NSDictionary *)jsonData;

@end

@interface KBYTMedia : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *keywords;
@property (nonatomic, strong) NSString *videoId;
@property (nonatomic, strong) NSString *views;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSDictionary *images;
@property (nonatomic, strong) NSArray *streams;
@property (nonatomic, strong) NSString *details; //description
@property (readwrite, assign) NSInteger expireTime;

- (BOOL)isExpired;

@end

@interface KBYTStream : NSObject

@property (readwrite, assign) BOOL multiplexed;
@property (nonatomic, strong) NSString *outputFilename;
@property (nonatomic, strong) NSString *quality;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *format;
@property (nonatomic, strong) NSNumber *height;
@property (readwrite, assign) NSInteger itag;
@property (nonatomic, strong) NSString *s;
@property (nonatomic, strong) NSString *extension;
@property (nonatomic, strong) NSURL *url;
@property (readwrite, assign) BOOL playable;
@property (nonatomic, assign) KBYTStream *audioStream; //will be empty if its multiplexed
@property (readwrite, assign) NSInteger expireTime;

- (id)initWithDictionary:(NSDictionary *)streamDict;
- (BOOL)isExpired;
- (NSDictionary *)dictionaryValue;
@end

@interface NSObject  (convenience)

- (void)recursiveInspectObjectLikeKey:(NSString *)desiredKey saving:(NSMutableArray *)array;
- (void)recursiveInspectObjectForKey:(NSString *)desiredKey saving:(NSMutableArray *)array;
- (id)recursiveObjectsLikeKey:(NSString *)desiredKey;
- (id)recursiveObjectLikeKey:(NSString *)desiredKey;
- (id)recursiveObjectForKey:(NSString *)desiredKey;
- (id)recursiveObjectsForKey:(NSString *)desiredKey;
- (NSString *)downloadFile;
- (NSString *)applicationSupportFolder;
- (NSString *)downloadFolder;
- (NSMutableDictionary *)parseFlashVars:(NSString *)vars;
- (NSArray *)matchesForString:(NSString *)string withRegex:(NSString *)pattern;
- (NSArray *)matchesForString:(NSString *)string withRegex:(NSString *)pattern allRanges:(BOOL)includeAllRanges;
- (NSMutableDictionary *)dictionaryFromString:(NSString *)string withRegex:(NSString *)pattern;

@end

@interface NSString  (SplitString)

+ (NSString *)stringFromTimeInterval:(NSTimeInterval)timeInterval;
- (NSArray *)splitString;

@end

@interface NSDate (convenience)

+ (BOOL)passedEpochDateInterval:(NSTimeInterval)interval;
- (NSString *)timeStringFromCurrentDate;

@end

@interface NSURL (QSParameters)
- (NSArray *)parameterArray;
- (NSDictionary *)parameterDictionary;
@end

@interface KBYourTube : NSObject
{
    NSInteger bestTag;
}

@property (nonatomic, strong) NSString *yttimestamp;
@property (nonatomic, strong) NSString *ytkey;

- (void)apiSearch:(NSString *)search
             type:(KBYTSearchType)type
     continuation:(NSString *)continuation
  completionBlock:(void(^)(KBYTSearchResults *result))completionBlock
     failureBlock:(void(^)(NSString* error))failureBlock;
- (NSArray *)channelArrayFromUserName:(NSString *)userName;
- (NSString *)videoDescription:(NSString *)videoID;
- (NSString *)stringFromRequest:(NSString *)url;
+ (id)sharedInstance;
- (NSString *)rawYTFromHTML:(NSString *)html;
- (NSDictionary *)videoDetailsFromID:(NSString *)videoID;
- (BOOL)isSignedIn;

- (void)getUserDetailsDictionaryWithCompletionBlock:(void(^)(NSDictionary *outputResults))completionBlock
                                       failureBlock:(void(^)(NSString *error))failureBlock;

- (void)loadMoreVideosFromHREF:(NSString *)loadMoreLink
               completionBlock:(void(^)(NSDictionary *outputResults))completionBlock
                  failureBlock:(void(^)(NSString *error))failureBlock;

- (void)getPlaylistVideos:(NSString *)listID
          completionBlock:(void(^)(KBYTPlaylist *playlist))completionBlock
             failureBlock:(void(^)(NSString *error))failureBlock;

- (void)getPlaylistVideos:(NSString *)listID
             continuation:(NSString *)continuationToken
          completionBlock:(void(^)(KBYTPlaylist *playlist))completionBlock
             failureBlock:(void(^)(NSString *error))failureBlock;

- (void)loadMorePlaylistVideosFromHREF:(NSString *)loadMoreLink
                       completionBlock:(void(^)(NSDictionary *outputResults))completionBlock
                          failureBlock:(void(^)(NSString *error))failureBlock;

/**
 
 searchQuery is just a basic unescaped search string, this will return a dictionary with
 results, pageCount, resultCount. Beware this is super fragile, if youtube website changes
 this will almost definitely break. that being said its MUCH quicker then getSearchResults
 
 */

- (void)youTubeSearch:(NSString *)searchQuery
           pageNumber:(NSInteger)page
      completionBlock:(void(^)(NSDictionary* searchDetails))completionBlock
         failureBlock:(void(^)(NSString* error))failureBlock;

- (void)youTubeSearch2:(NSString *)searchQuery
            pageNumber:(NSInteger)page
   includeAllResults:(BOOL)includeAll
       completionBlock:(void(^)(NSDictionary* searchDetails))completionBlock
          failureBlock:(void(^)(NSString* error))failureBlock;

- (void)getOrganizedChannelData:(NSString *)channelID
                       completionBlock:(void(^)(NSDictionary* searchDetails))completionBlock
                   failureBlock:(void(^)(NSString* error))failureBlock;

- (NSString *)videoInfoPage:(NSString *)html;

- (void)getChannelVideosAlt:(NSString *)channelID
          completionBlock:(void(^)(KBYTChannel *channel))completionBlock
               failureBlock:(void(^)(NSString *error))failureBlock;

- (void)getChannelVideosAlt:(NSString *)channelID
               continuation:(NSString *)continuationToken
          completionBlock:(void(^)(KBYTChannel *channel))completionBlock
               failureBlock:(void(^)(NSString *error))failureBlock;

- (void)getChannelVideos:(NSString *)channelID
            continuation:(NSString *)continuationToken
         completionBlock:(void (^)(KBYTChannel *))completionBlock
            failureBlock:(void (^)(NSString *))failureBlock;

- (void)getChannelVideos:(NSString *)channelID
         completionBlock:(void(^)(KBYTChannel *channel))completionBlock
            failureBlock:(void(^)(NSString *error))failureBlock;

- (void)getFeaturedVideosWithCompletionBlock:(void(^)(NSDictionary* searchDetails))completionBlock
                                failureBlock:(void(^)(NSString* error))failureBlock;

- (void)getVideoDetailsForIDs:(NSArray*)videoIDs
             completionBlock:(void(^)(NSArray* videoArray))completionBlock
                failureBlock:(void(^)(NSString* error))failureBlock;

- (void)getVideoDetailsForID:(NSString*)videoID
             completionBlock:(void(^)(KBYTMedia* videoDetails))completionBlock
                failureBlock:(void(^)(NSString* error))failureBlock;


- (void)fixAudio:(NSString *)theFile
          volume:(NSInteger)volume
 completionBlock:(void(^)(NSString *newFile))completionBlock;

- (void)extractAudio:(NSString *)theFile
     completionBlock:(void(^)(NSString *newFile))completionBlock;
- (NSString *)decodeSignature:(NSString *)theSig;

- (void)muxFiles:(NSArray *)theFiles completionBlock:(void(^)(NSString *newFile))completionBlock;

+ (NSDictionary *)formatFromTag:(NSInteger)tag;

@end
