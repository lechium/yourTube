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

//split a string into an NSArray of characters

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


/* 
 
 the only function you should ever have to call to get video streams
 take the video ID from a youtube link and feed it in to this function
 
 ie _7nYuyfkjCk from the link below
 
 
 https://www.youtube.com/watch?v=_7nYuyfkjCk
 
 
 
 */

- (NSArray *)getVideoStreamsForID:(NSString *)videoID
{
    //get the time stamp and cipher key in case we need to decode the signature.
    [self getTimeStampAndKey:videoID];
    
    //a fallback just in case the jsbody is changed and we cant automatically grab current signatures
    //old ciphers generally continue to work at least temporarily.
    
    if (self.yttimestamp == nil || self.ytkey == nil)
    {
        self.yttimestamp = @"16777";
        self.ytkey = @"13,0,-3,2,0,-3,36";
        
    }
    
    NSString *url = [NSString stringWithFormat:@"https://www.youtube.com/get_video_info?&video_id=%@&%@&sts=%@", videoID, @"eurl=http%3A%2F%2Fwww%2Eyoutube%2Ecom%2F", self.yttimestamp];
    
    //get the post body from the url above, gets the initial raw info we work with
    NSString *body = [self stringFromRequest:url];
    
    //turn all of these variables into an nsdictionary by separating elements by =
    NSDictionary *vars = [self parseFlashVars:body];
    if ([[vars allKeys] containsObject:@"status"])
    {
        if ([[vars objectForKey:@"status"] isEqualToString:@"ok"])
        {
            //grab the raw streams string that is available for the video
            NSString *streamMap = [vars objectForKey:@"url_encoded_fmt_stream_map"];
            NSString *title = [vars objectForKey:@"title"];
            
            //separate the streams into their initial array
            
            NSArray *maps = [[streamMap stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] componentsSeparatedByString:@","];
            NSMutableArray *videoArray = [NSMutableArray new];
            for (NSString *map in maps )
            {
                //same thing, take these raw feeds and make them into an NSDictionary with usable info
                NSDictionary *videoDict = [self parseFlashVars:map];
                //add the title from the previous dictionary created
                [videoDict setValue:title forKey:@"title"];
                //process the raw dictionary into something that can be used with download links and format details
                NSDictionary *processed = [self processSource:videoDict];
                if (processed != nil)
                {
                    //if we actually have a video detail dictionary add it to final array
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

//get the basic source dictionary and update it with useful format and url info
//decode the signature if necessary

- (NSDictionary *)processSource:(NSDictionary *)inputSource
{
    if ([[inputSource allKeys] containsObject:@"url"])
    {
        NSString *signature = nil;
        int fmt = [[inputSource objectForKey:@"itag"] intValue];
     
        //if you want to limit to mp4 only, comment this if back in
        //  if (fmt == 22 || fmt == 18 || fmt == 37 || fmt == 38)
    //    {
            NSString *url = [[inputSource objectForKey:@"url"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if ([[inputSource allKeys] containsObject:@"sig"])
            {
                signature = [inputSource objectForKey:@"sig"];
                url = [url stringByAppendingFormat:@"&signature=%@", signature];
            } else if ([[inputSource allKeys] containsObject:@"s"]) //requires cipher to update the signature
            {
                signature = [inputSource objectForKey:@"s"];
                signature = [self decodeSignature:signature withKey:self.ytkey];
                url = [url stringByAppendingFormat:@"&signature=%@", signature];
            }
        
        
        url = [url stringByAppendingFormat:@"&title=%@", inputSource[@"title"]];
        
        [inputSource setValue:url forKey:@"url"];
        
        //add more readable format informat
        [inputSource setValue:[self formatFromTag:fmt] forKey:@"format"];
            return inputSource;
       // }
    }
    
    
    return nil;
}

//take a url and get its raw body, then return in string format

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

/*
 
 if use signature cipher is true the a timestamp and a key are necessary to decipher the signature and re-add it
 to the url for proper playback and download, this method will attempt to grab those values dynamically
 
 for more details look at https://www.jwz.org/hacks/youtubedown and search for this text
 
 24-Jun-2013: When use_cipher_signature=True
 
 didnt want to plagiarize his whole thesis, and its a good explanation of why this is necessary
 
 
 */


- (void)getTimeStampAndKey:(NSString *)videoID
{
    NSString *url = [NSString stringWithFormat:@"https://www.youtube.com/embed/%@", videoID];
    NSString *body = [self stringFromRequest:url];
    
    //the timestamp that is needed for signature deciphering
    
    self.yttimestamp = [[[[self matchesForString:body withRegex:@"\"sts\":(\\d*)"] lastObject] componentsSeparatedByString:@":"] lastObject];
    
    //isolate the base.js file that we need to extract the signature from
    
    NSString *baseJS = [NSString stringWithFormat:@"https:%@", [[[[[self matchesForString:body withRegex:@"\"js\":\"([^\"]*)\""] lastObject] componentsSeparatedByString:@":"] lastObject] stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"]];
    
    //get the raw js source of the decoder file that we need to get the signature cipher from
    
    NSString *jsBody = [self stringFromRequest:[baseJS stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
    
    //crazy convoluted regex to get a signature section similiar to this
    //cr.Ww(a,13);cr.W9(a,69);cr.Gz(a,3);cr.Ww(a,2);cr.W9(a,79);cr.Gz(a,3);cr.Ww(a,36);return a.join(
    
    
    //#### IGNORE THE WARNING, if the extra escape is added as expected the regex doesnt work!
    
    NSString *keyMatch = [[self matchesForString:jsBody withRegex:@"function[ $_A-Za-z0-9]*\\(a\\)\\{a=a(?:\.split|\\[[$_A-Za-z0-9]+\\])\\(\"\"\\);\\s*([^\"]*)"] lastObject];
    
    //the jsbody is trimmed down to a smaller section to optimize the search to decipher the signature functions
    
    NSString *fnNameMatch = [NSString stringWithFormat:@";var %@={", [[self matchesForString:keyMatch withRegex:@"^[$_A-Za-z0-9]+"] lastObject]];
    
    //the index to start the new string range from for said optimization above
    
    NSUInteger index = [jsBody rangeOfString:fnNameMatch].location;
    
    //smaller string for searching for reverse / splice function names
    NSString *x = [jsBody substringFromIndex:index];
    NSString *a, *tmp, *r, *s = nil;
    
    //next baffling regex used to cycle through for which functions are linked to reversing and splicing
    NSArray *matches = [self matchesForString:x withRegex:@"([$_A-Za-z0-9]+):|reverse|splice"];
    int i = 0;
    
    /*
    adopted from the javascript version to identify the functions, probably not the most efficient way
    loop through the matches above and set the tmp value if it isnt equal the value splice or reverse
    the function names are the match above their counterpart
    
     ie Ww,splice,w9,reverse
    
     s = Ww; & r = W9;
    
     */
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
    
    /*
     
     the new signature is made into a key array for easily moving characters around as needed based on the cipher
     ie cr.Ww(a,13);cr.W9(a,69);cr.Gz(a,3);cr.Ww(a,2);cr.W9(a,79);cr.Gz(a,3);cr.Ww(a,36);return a.join(
     
     broken up into chunks like
     
     cr.Ww(a,13)
     
    */
    NSMutableArray *keys = [NSMutableArray new];
    
    NSArray *keyMatches = [self matchesForString:keyMatch withRegex:@"[$_A-Za-z0-9]+\\.([$_A-Za-z0-9]+)\\(a,(\\d*)\\)"];
    for (NSString *theMatch in keyMatches)
    {
        //fr.Ww(a,13) split this up into something like Ww and 13
        NSString *importantSection = [[theMatch componentsSeparatedByString:@"."] lastObject];
        NSString *numberValue = [[[importantSection componentsSeparatedByString:@","] lastObject] stringByReplacingOccurrencesOfString:@")" withString:@""]; //13
        NSString *fnName = [[importantSection componentsSeparatedByString:@"("] objectAtIndex:0]; // Ww
        
        if ([fnName isEqualToString:r]) //reverse
        {
            [keys addObject:@"0"]; //0 in our signature key means reverse the string
        } else if ([fnName isEqualToString:s]) //if its the splice function store it as a negative value
        {
            [keys addObject:[NSString stringWithFormat:@"-%@", numberValue]];
        } else { //were not splicing or reversing, so its going to be a swap value
            [keys addObject:numberValue];
        }
    }
    
    //take the final key array and make it into something like 13,0,-3,2,0,-3,36
    self.ytkey = [keys componentsJoinedByString:@","];
   
}

/*
 
 the youtube signature cipher has 3 basic steps (for now) swapping, splicing and reversing
 the notes from youtubedown put it better than i can think to
 
 # - r  = reverse the string;
 # - sN = slice from character N to the end;
 # - wN = swap 0th and Nth character.
 
 they store their key a little differently then the clicktoplugin scripts this code was based on
 
 but our their  w13 r s3 w2 r s3 w36 is the equivalent to our 13,0,-3,2,0,-3,36
 
 the functions below take care of all of these steps as quickly & easily as i could think of to
 
 */



/* 
 
 take the key array and splice it from the starting index to the end of the string with the value 3 would change
 105105282D9AD56125199603D23E2C93F04C9D2237A.B8A82DC92F00EF86757325D88E778BC5D08FC252252 to
 105282D9AD56125199603D23E2C93F04C9D2237A.B8A82DC92F00EF86757325D88E778BC5D08FC252252
*/

- (NSMutableArray *)sliceArray:(NSArray *)theArray atIndex:(int)theIndex
{
    NSRange theRange = NSMakeRange(theIndex, theArray.count-theIndex);
    return [[theArray subarrayWithRange:theRange] mutableCopy];
}

/*
 
 take an array and reverse it, the mutable copy thing probably isnt very efficient but a necessary? evil to
 retain mutability
 
 */

- (NSMutableArray *)reversedArray:(NSArray *)theArray
{
    return [[[theArray reverseObjectEnumerator] allObjects] mutableCopy];
}

/*
 
 take the value at index 0 and swap it with theIndex
 
 */

- (NSMutableArray *)swapCharacterAtIndex:(int)theIndex inArray:(NSMutableArray *)theArray
{
    [theArray exchangeObjectAtIndex:0 withObjectAtIndex:theIndex];
    return theArray;
    
}

/*
 
 change a wall of body text into a dictionary like &key=value
 
 */

- (NSDictionary *)parseFlashVars:(NSString *)vars
{
    return [self dictionaryFromString:vars withRegex:@"([^&=]*)=([^&]*)"];
}

/*
 
 give us the actual matches from a regex, rather then NSTextCheckingResult full of ranges
 
 */

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

/*
 
 the actual function that does the &key=value dictionary creation mentioned above
 
 */

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

/*
 
 big encirido to decode the signature, takes a value like 13,0,-3,2,0,-3,36 and a signature
 and spits out usable version of it, only needed wheb use signature cipher is true
 
 */

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
