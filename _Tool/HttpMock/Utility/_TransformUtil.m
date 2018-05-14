//
//  _TransformUtil.m
//  NewStructureTests
//
//  Created by 7 on 15/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "_TransformUtil.h"

@interface _QueryStringPair : NSObject

@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (instancetype)initWithField:(id)field value:(id)value; // Like field="a", value="b"
- (instancetype)initWithString:(NSString *)string; // Like "a=b"

- (NSString *)URLEncodedStringValue;

@end

@implementation _QueryStringPair

- (instancetype)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.field = field;
    self.value = value;
    
    return self;
}

- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (!self ||
        ![string containsString:@"="]) {
        return nil;
    }
    
    NSArray *pair = [string componentsSeparatedByString:@"="];
    NSString *first = pair.firstObject;
    NSString *second = pair.lastObject;
    
    if (pair.count < 2 ||
        second.length <= 0) {
        return nil;
    }
    
    self.field = first;
    self.value = second;
    
    return self;
}

- (NSString *)URLEncodedStringValue {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return __PercentEscapedStringFromString([self.field description]);
    } else {
        return [NSString stringWithFormat:@"%@=%@", __PercentEscapedStringFromString([self.field description]), __PercentEscapedStringFromString([self.value description])];
    }
}

@end

#pragma mark -

/**
 Returns a percent-escaped string following RFC 3986 for a query string key or value.
 RFC 3986 states that the following characters are "reserved" characters.
 - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
 - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
 
 In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
 query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
 should be percent-escaped in the query string.
 - parameter string: The string to be percent-escaped.
 - returns: The percent-escaped string.
 */
NSString * __PercentEscapedStringFromString(NSString *string) {
    static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
    
    // FIXME: https://github.com/AFNetworking/AFNetworking/pull/3028
    // return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    
    static NSUInteger const batchSize = 50;
    
    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;
    
    while (index < string.length) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"
        NSUInteger length = MIN(string.length - index, batchSize);
#pragma GCC diagnostic pop
        NSRange range = NSMakeRange(index, length);
        
        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [string rangeOfComposedCharacterSequencesForRange:range];
        
        NSString *substring = [string substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];
        
        index += range.length;
    }
    
    return escaped;
}

NSString * __QueryStringFromParameters(NSDictionary *parameters) {
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (_QueryStringPair *pair in __QueryStringPairsFromDictionary(parameters)) {
        [mutablePairs addObject:[pair URLEncodedStringValue]];
    }
    
    return [mutablePairs componentsJoinedByString:@"&"];
}

NSArray * __QueryStringPairsFromDictionary(NSDictionary *dictionary) {
    return __QueryStringPairsFromKeyAndValue(nil, dictionary);
}

NSArray * __QueryStringPairsFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[sortDescriptor ]]) {
            id nestedValue = dictionary[nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:__QueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray:__QueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            [mutableQueryStringComponents addObjectsFromArray:__QueryStringPairsFromKeyAndValue(key, obj)];
        }
    } else {
        [mutableQueryStringComponents addObject:[[_QueryStringPair alloc] initWithField:key value:value]];
    }
    
    return mutableQueryStringComponents;
}

#pragma mark -

NSArray * __QueryStringPairsFromQueryString(NSString *string) {
    NSMutableArray *pairs = [NSMutableArray new];
    
    NSArray *pairStrings = [string componentsSeparatedByString:@"&"];
    
    for ( NSString *pairString in pairStrings) {
        _QueryStringPair *pair = [[_QueryStringPair alloc] initWithString:pairString];
        if (pair) {
            [pairs addObject:pair];
        }
    }
    
    return pairs;
}

NSDictionary * __DictionaryFromQueryStringPairs(NSArray *pairs) {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    for (_QueryStringPair *pair in pairs) {
        [dict setObject:pair.value forKey:pair.field];
    }
    
    return dict;
}

NSDictionary * __DictionaryFromQueryString(NSString *string) {
    return __DictionaryFromQueryStringPairs(__QueryStringPairsFromQueryString(string));
}

NSString * __JsonStringFromDictionary(NSDictionary *dict, NSError **ptrError) {
    if (ptrError) *ptrError = nil;
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = @"";
    
    if (! jsonData) {
        if (ptrError) {
            *ptrError = error;
            
            return nil;
        }
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
}
