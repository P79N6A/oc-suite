//
//     ____              _____    _____    _____
//    / ___\   /\ /\     \_   \   \_  _\  /\  __\
//    \ \     / / \ \     / /\/    / /    \ \  _\_
//  /\_\ \    \ \_/ /  /\/ /_     / /      \ \____\
//  \____/     \___/   \____/    /__|       \/____/
//
//	Copyright BinaryArtists development team and other contributors
//
//	https://github.com/BinaryArtists/suite.great
//
//	Free to use, prefer to discuss!
//
//  Welcome!
//

#import "NSURL+Extension.h"

#pragma mark -

@implementation NSURL ( Extension )

+ (NSURL *)URLWithStringOrNil:(NSString *)URLString {
    if (URLString) {
        return [NSURL URLWithString:URLString];
    }else {
        return nil;
    }
}


- (NSString *)baseString {
    // Let's see if we can build it, it'll be the most accurate
    if([self scheme] && [self host]) {
        NSMutableString* baseString = [[NSMutableString alloc] initWithString:@""];
        
        [baseString appendFormat:@"%@://", [self scheme]];
        
        if([self user]) {
            if([self password]) {
                [baseString appendFormat:@"%@:%@@", [self user], [self password]];
            } else {
                [baseString appendFormat:@"%@@", [self user]];
            }
        }
        
        [baseString appendString:[self host]];
        
        if([self port]) {
            [baseString appendFormat:@":%@", [self port]];
        }
        
        [baseString appendString:@"/"];
        
        return baseString;
    }
    
    // Oh Well, time to strip it down
    else {
        NSString* baseString = [self absoluteString];
        
        if(![[self path] isEqualToString:@"/"]) {
            baseString = [baseString stringByReplacingOccurrencesOfString:[self path] withString:@""];
        }
        
        if(self.query) {
            baseString = [baseString stringByReplacingOccurrencesOfString:[self query] withString:@""];
        }
        
        baseString = [baseString stringByReplacingOccurrencesOfString:@"?" withString:@""];
        
        if(![baseString hasSuffix:@"/"]) {
            baseString = [baseString stringByAppendingString:@"/"];
        }
        
        return baseString;
    }
}

@end

#pragma mark -

@implementation NSURL ( Comparison )

//http://vgable.com/blog/2009/04/22/nsurl-isequal-gotcha/
- (BOOL) isEqualToURL:(NSURL *)otherURL {
    return [[self absoluteURL] isEqual:[otherURL absoluteURL]] ||
    ([self isFileURL] && [otherURL isFileURL] && [[self path] isEqual:[otherURL path]]);
}

@end
