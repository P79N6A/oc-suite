//
//  _json.m
//  kata
//
//  Created by fallen on 17/3/6.
//  Copyright © 2017年 fallenink. All rights reserved.
//

#import "_json.h"

// ----------------------------------
// Category source code
// ----------------------------------

@implementation NSObject ( Json )

- (BOOL)isJsonObject {
    return [NSJSONSerialization isValidJSONObject:self];
}

- (NSString *)jsonString {
    return [_Json jsonStringFromJsonObject:self];
}

@end

//@implementation NSData ( Json )
//
//- (NSString *)jsonString {
//    return [_Json jsonStringFromData:self];
//}
//
//@end

@implementation NSString ( Json )

- (id)jsonObject {
    return [_Json jsonObjectFromString:self];
}

@end

// ----------------------------------
// Source code
// ----------------------------------

@implementation _Json

+ (NSString *)jsonStringFromJsonObject:(nonnull id)jsonObject {
    NSObject *object = jsonObject;
    
    if (object.isJsonObject) {
        NSError *parseError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&parseError];
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return nil;
}

+ (NSDictionary *)jsonObjectFromString:(NSString *)jsonString {
    NSAssert(jsonString,@"数据不能为空!");
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id obj = [NSJSONSerialization JSONObjectWithData:jsonData
                                             options:NSJSONReadingMutableContainers
                                               error:&err];
    
    NSAssert(!err,@"json解析失败");
    
    return obj;
}

@end
