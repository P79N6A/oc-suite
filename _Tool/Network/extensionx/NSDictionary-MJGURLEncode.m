//
//  NSDictionary-MJGURLEncode.m
//  MJGFoundation
//
//  Created by Matt Galloway on 24/12/2011.
//  Copyright (c) 2011 Matt Galloway. All rights reserved.
//

#import "NSDictionary-MJGURLEncode.h"
#import "NSString+Rest.h"

@implementation NSDictionary (MJGURLEncode)

- (NSString*)getQuery {
    NSMutableArray *pairs = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSString *key in [self keyEnumerator]) {
        id value = [self objectForKey:key];
        
        // TODO: Support more than just NSString and NSNumber
        
        if ([value isKindOfClass:[NSString class]]) {
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", 
                              [key URLEncodedString],
                              [(NSString*)value URLEncodedString]]];
        } else if ([value isKindOfClass:[NSNumber class]]) {
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", 
                              [key URLEncodedString],
                              [[(NSNumber*)value stringValue] URLEncodedString]]];
        }
    }
    return [pairs componentsJoinedByString:@"&"];
}

- (NSData*)formEncodedPostData {
    return [[self getQuery] dataUsingEncoding:NSUTF8StringEncoding];
}

@end
