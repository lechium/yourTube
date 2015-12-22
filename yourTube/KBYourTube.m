//
//  KBYourTube.m
//  yourTube
//
//  Created by Kevin Bradley on 12/21/15.
//  Copyright © 2015 nito. All rights reserved.
//

#import "KBYourTube.h"

/**
 
 Native objective-c implementation of several different functions pulled from clicktoplugin safari browser extension
 
 */


@interface NSString  (SplitString)

- (NSArray *)splitString;

@end

@implementation NSString (SplitString)

- (NSArray *)splitString
{
    NSUInteger index = 0;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.length];
    
    while (index < self.length) {
        NSRange range = [self rangeOfComposedCharacterSequenceAtIndex:index];
        NSString *substring = [self substringWithRange:range];
        [array addObject:substring];
        index = range.location + range.length;
    }
    
    return array;
}

@end

@implementation KBYourTube

@synthesize ytkey, yttimestamp;


- (NSArray *)getVideoStreamsForID:(NSString *)videoID
{
    [self getTimeStampAndKey:videoID];
    
    NSString *url = [NSString stringWithFormat:@"https://www.youtube.com/get_video_info?&video_id=%@&%@&sts=%@", videoID, @"eurl=http%3A%2F%2Fwww%2Eyoutube%2Ecom%2F", self.yttimestamp];
    
    NSString *body = [self stringFromRequest:url];
    NSDictionary *vars = [self parseFlashVars:body];
    if ([[vars allKeys] containsObject:@"status"])
    {
        if ([[vars objectForKey:@"status"] isEqualToString:@"ok"])
        {
            NSString *streamMap = [vars objectForKey:@"url_encoded_fmt_stream_map"];
            NSString *title = [vars objectForKey:@"title"];
            NSArray *maps = [[streamMap stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] componentsSeparatedByString:@","];
            NSMutableArray *videoArray = [NSMutableArray new];
            for (NSString *map in maps )
            {
                NSDictionary *videoDict = [self parseFlashVars:map];
                [videoDict setValue:title forKey:@"title"];
                NSDictionary *processed = [self processSource:videoDict];
                if (processed != nil)
                {
                    [videoArray addObject:processed];
                }
            }
            return videoArray;
        }
    }
    
    return nil;
}


- (NSString *)formatFromTag:(int)tag
{
    NSString *fmt = nil;
    switch (tag) {
            
        case 38: fmt = @"4K MP4"; break;
        case 37: fmt = @"1080p MP4"; break;
        case 22: fmt = @"720p MP4"; break;
        case 18: fmt = @"360p MP4"; break;
            
            //FLV
            
        case 35: fmt = @"480p FLV"; break;
        case 6: fmt = @"270p FLV"; break;
        case 5: fmt = @"240p FLV"; break;
            
            //WebM
            
        case 46: fmt = @"1080p WebM"; break;
        case 45: fmt = @"720p WebM"; break;
        case 44: fmt = @"480p WebM"; break;
        case 43: fmt = @"360p WebM"; break;
            
            //3gp
        
        case 17: fmt = @"350p 3GP"; break;
            
        default:
            break;
    }
    
    return fmt;
}

- (NSDictionary *)processSource:(NSDictionary *)inputSource
{
    if ([[inputSource allKeys] containsObject:@"url"])
    {
        NSString *signature = nil;
        int fmt = [[inputSource objectForKey:@"itag"] intValue];
      //  if (fmt == 22 || fmt == 18 || fmt == 37 || fmt == 38)
    //    {
            NSString *url = [[inputSource objectForKey:@"url"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if ([[inputSource allKeys] containsObject:@"sig"])
            {
                signature = [inputSource objectForKey:@"sig"];
                url = [url stringByAppendingFormat:@"&signature=%@", signature];
            } else if ([[inputSource allKeys] containsObject:@"s"])
            {
                signature = [inputSource objectForKey:@"s"];
                signature = [self decodeSignature:signature withKey:self.ytkey];
                url = [url stringByAppendingFormat:@"&signature=%@", signature];
            }
            
            url = [url stringByAppendingFormat:@"&title=%@", inputSource[@"title"]];
            [inputSource setValue:url forKey:@"url"];
        [inputSource setValue:[self formatFromTag:fmt] forKey:@"format"];
        // NSLog(@"setting url: %@", url);
            return inputSource;
       // }
    }
    
    
    return nil;
}

- (NSString *)stringFromRequest:(NSString *)url
{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:10];
    
    NSURLResponse *response = nil;
    
    [request setHTTPMethod:@"GET"];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
}

- (void)getTimeStampAndKey:(NSString *)videoID
{
    NSString *url = [NSString stringWithFormat:@"https://www.youtube.com/embed/%@", videoID];
    NSString *body = [self stringFromRequest:url];
    
    self.yttimestamp = [[[[self matchesForString:body withRegex:@"\"sts\":(\\d*)"] lastObject] componentsSeparatedByString:@":"] lastObject];
    NSString *baseJS = [NSString stringWithFormat:@"https:%@", [[[[[self matchesForString:body withRegex:@"\"js\":\"([^\"]*)\""] lastObject] componentsSeparatedByString:@":"] lastObject] stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"]];
    NSString *jsBody = [self stringFromRequest:[baseJS stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
    NSString *keyMatch = [[self matchesForString:jsBody withRegex:@"function[ $_A-Za-z0-9]*\\(a\\)\\{a=a(?:\.split|\\[[$_A-Za-z0-9]+\\])\\(\"\"\\);\\s*([^\"]*)"] lastObject];
    ////cr.Ww(a,13);cr.W9(a,69);cr.Gz(a,3);cr.Ww(a,2);cr.W9(a,79);cr.Gz(a,3);cr.Ww(a,36);return a.join(
    
    NSString *fnNameMatch = [NSString stringWithFormat:@";var %@={", [[self matchesForString:keyMatch withRegex:@"^[$_A-Za-z0-9]+"] lastObject]];
    
    NSUInteger index = [jsBody rangeOfString:fnNameMatch].location;
    NSString *x = [jsBody substringFromIndex:index];
    NSString *a, *tmp, *r, *s = nil;
    NSArray *matches = [self matchesForString:x withRegex:@"([$_A-Za-z0-9]+):|reverse|splice"];
    int i = 0;
    for (i = 0; i < [matches count]; i++)
    {
        a = [matches objectAtIndex:i];
        if (r != nil && s != nil)
        {
            break;
        }
        if([a isEqualToString:@"reverse"])
        {
            r = tmp;
        } else if ([a isEqualToString:@"splice"])
        {
            s = tmp;
        } else {
            tmp = [a stringByReplacingOccurrencesOfString:@":" withString:@""];
        }
    }
    
    
    NSMutableArray *keys = [NSMutableArray new];
    NSArray *keyMatches = [self matchesForString:keyMatch withRegex:@"[$_A-Za-z0-9]+\\.([$_A-Za-z0-9]+)\\(a,(\\d*)\\)"];
    for (NSString *theMatch in keyMatches)
    {
        //fr.Ww(a,13)
        NSString *importantSection = [[theMatch componentsSeparatedByString:@"."] lastObject];
        NSString *numberValue = [[[importantSection componentsSeparatedByString:@","] lastObject] stringByReplacingOccurrencesOfString:@")" withString:@""];
        NSString *fnName = [[importantSection componentsSeparatedByString:@"("] objectAtIndex:0];
        
        if ([fnName isEqualToString:r]) //reverse
        {
            [keys addObject:@"0"];
        } else if ([fnName isEqualToString:s])
        {
            [keys addObject:[NSString stringWithFormat:@"-%@", numberValue]];
        } else {
            [keys addObject:numberValue];
        }
    }
    
    self.ytkey = [keys componentsJoinedByString:@","];
   
}


- (NSMutableArray *)sliceArray:(NSArray *)theArray atIndex:(int)theIndex
{
    NSRange theRange = NSMakeRange(theIndex, theArray.count-theIndex);
    return [[theArray subarrayWithRange:theRange] mutableCopy];
}

- (NSMutableArray *)reversedArray:(NSArray *)theArray
{
    return [[[theArray reverseObjectEnumerator] allObjects] mutableCopy];
}

- (NSMutableArray *)swapCharacterAtIndex:(int)theIndex inArray:(NSMutableArray *)theArray
{
    [theArray exchangeObjectAtIndex:0 withObjectAtIndex:theIndex];
    return theArray;
    
}


- (NSDictionary *)parseFlashVars:(NSString *)vars
{
    return [self dictionaryFromString:vars withRegex:@"([^&=]*)=([^&]*)"];
}

- (NSArray *)matchesForString:(NSString *)string withRegex:(NSString *)pattern
{
    NSMutableArray *array = [NSMutableArray new];
    NSError *error = NULL;
    NSRange range = NSMakeRange(0, string.length);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines error:&error];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportProgress range:range];
    for (NSTextCheckingResult *entry in matches)
    {
        NSString *text = [string substringWithRange:entry.range];
        [array addObject:text];
    }
    
    return array;
}

- (NSDictionary *)dictionaryFromString:(NSString *)string withRegex:(NSString *)pattern
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSArray *matches = [self matchesForString:string withRegex:pattern];
    
    for (NSString *text in matches)
    {
        NSArray *components = [text componentsSeparatedByString:@"="];
        [dict setObject:[components objectAtIndex:1] forKey:[components objectAtIndex:0]];
    }
    
    return dict;
}


- (NSString *)decodeSignature:(NSString *)theSig withKey:(NSString *)theKey
{
    NSMutableArray *s = [[theSig splitString] mutableCopy];
    NSArray *keyArray = [theKey componentsSeparatedByString:@","];
    int i = 0;
    for (i = 0; i < [keyArray count]; i++)
    {
        int n = [[keyArray objectAtIndex:i] intValue];
        if (n == 0) //reverse
        {
            s = [self reversedArray:s];
        } else if (n < 0) //slice
        {
            s = [self sliceArray:s atIndex:-n];
            
        } else {
            s = [self swapCharacterAtIndex:n inArray:s];
        }
    }
    return[s componentsJoinedByString:@""];
}


@end
