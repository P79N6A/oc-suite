#import "_JSON.h"

// ----------------------------------
// Category source code
// ----------------------------------

@implementation NSObject ( JSON )

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

@implementation NSString ( JSON )

- (id)jsonObject {
    return [_Json jsonObjectFromString:self];
}

@end

@implementation NSDictionary ( JSON )

- (NSString *)JSONString {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (jsonData == nil) {
#ifdef DEBUG
        NSLog(@"fail to get JSON from dictionary: %@, error: %@", self, error);
#endif
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
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
