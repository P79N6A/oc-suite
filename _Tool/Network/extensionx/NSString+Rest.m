//
//  NSString+Rest.m
//  kata
//
//  Created by fallen.ink on 18/02/2017.
//  Copyright © 2017 fallenink. All rights reserved.
//

#import "_precompile.h"
#import "NSString+Rest.h"
#import "_pragma_push.h"

@implementation NSString (Rest)

- (NSString *)URLEncodedString {
    __autoreleasing NSString *encodedString;
    NSString *originalString = (NSString *)self;
    encodedString = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                          NULL,
                                                                                          (__bridge CFStringRef)originalString,
                                                                                          NULL,
                                                                                          (CFStringRef)@":!*();@/&?#[]+$,='%’\"",
                                                                                          kCFStringEncodingUTF8
                                                                                          );
    return encodedString;
}

- (NSString *)URLDecodedString {
    __autoreleasing NSString *decodedString;
    NSString *originalString = (NSString *)self;
    decodedString = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                                                                          NULL,
                                                                                                          (__bridge CFStringRef)originalString,
                                                                                                          CFSTR(""),
                                                                                                          kCFStringEncodingUTF8
                                                                                                          );
    return decodedString;
}

// 从URL中解析出参数字典
- (NSDictionary *)queryDictionaryUsingEncoding:(NSStringEncoding)encoding {
    NSCharacterSet *delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
    NSMutableDictionary *pairs = [NSMutableDictionary dictionary];
    NSScanner *scanner = [[NSScanner alloc] initWithString:self];
    while (![scanner isAtEnd]) {
        NSString *pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray *kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 1 || kvPair.count == 2) {
            NSString *key = [[kvPair objectAtIndex:0]
                             stringByReplacingPercentEscapesUsingEncoding:encoding];
            
            if (kvPair.count == 1) {
                [pairs setObject:[NSNull null] forKey:key];
                
            } else if (kvPair.count == 2) {
                NSString *value = [[kvPair objectAtIndex:1]
                                   stringByReplacingPercentEscapesUsingEncoding:encoding];
                
                [pairs setObject:value forKey:key];
            }
        }
    }
    return [NSDictionary dictionaryWithDictionary:pairs];
}


- (NSString *)removeUnescapedCharacter {
    NSCharacterSet *controlChars = [NSCharacterSet controlCharacterSet];
    NSRange range = [self rangeOfCharacterFromSet:controlChars]; //获取那些特殊字符
    
    //寻找字符串中有没有这些特殊字符
    if (range.location != NSNotFound) {
        NSMutableString *mutable = [NSMutableString stringWithString:self];
        while (range.location != NSNotFound) {
            [mutable deleteCharactersInRange:range]; //去掉这些特殊字符
            range = [mutable rangeOfCharacterFromSet:controlChars];
        }
        return mutable;
    }
    return self;
}

- (NSDictionary *)JSONDictionary {
    NSError *error = nil;
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                    options:kNilOptions
                                                      error:&error]; //json数据当中没有 \n \r \t 等制表符
    
    
    if (error) {
        LOG(@"%@", error);
        
        NSString *filteredString = [self removeUnescapedCharacter]; // json 里面的特殊控制字符，需要过滤
        jsonObject = [NSJSONSerialization JSONObjectWithData:[filteredString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        
        if (error) {
            return nil;
        }
    }
    
    return jsonObject;
}

// 对参数列表生成URL编码后字符串
+ (NSString *)makeQueryStringFromArgs:(NSDictionary *)args {
    NSMutableString *formatString = nil;
    
    for (NSString *key in args) {
        if (formatString == nil) {
            formatString = [NSMutableString stringWithFormat:@"%@=%@", key, [[args valueForKey:key] URLEncodedString]];
        } else {
            [formatString appendFormat:@"&%@=%@", key, [[args valueForKey:key] URLEncodedString]];
        }
    }
    
    return [NSString stringWithString:formatString];
}

@end

#import "_pragma_pop.h"
