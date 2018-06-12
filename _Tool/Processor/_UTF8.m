//
//  _utf8.m
//  student
//
//  Created by fallen.ink on 01/04/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "_utf8.h"

// ----------------------------------
// Category source code
// ----------------------------------

@implementation NSString ( utf8 )

- (NSData *)utf8EncodedData {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)unicodeString {
    NSString *tempStr1 = [self stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *returnStr = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListMutableContainersAndLeaves format:NULL error:NULL];
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}

@end

// ----------------------------------
// Source code
// ----------------------------------

@implementation _utf8

@end
