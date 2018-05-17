#import "NSString+NetworkLit.h"
#import "NSDictionary+NetworkLit.h"

@implementation NSDictionary (NetworkLit)

- (NSString *)urlEncodedKeyValueString {
    NSMutableString *string = [NSMutableString string];
    for (NSString *key in self) {
        NSObject *value = [self valueForKey:key];
        if([value isKindOfClass:[NSString class]])
            [string appendFormat:@"%@=%@&", [key netURLEncodedString], [((NSString*)value) netURLEncodedString]];
        else
            [string appendFormat:@"%@=%@&", [key netURLEncodedString], value];
    }

    if([string length] > 0)
        [string deleteCharactersInRange:NSMakeRange([string length] - 1, 1)];

    return string;
}

- (NSString *)jsonEncodedKeyValueString {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self
                                                   options:0 // non-pretty printing
                                                     error:&error];
    if(error)
        NSLog(@"JSON Parsing Error: %@", error);

    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)plistEncodedKeyValueString {
    NSError *error = nil;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:self
                                                            format:NSPropertyListXMLFormat_v1_0
                                                           options:0 error:&error];
    if(error)
        NSLog(@"JSON Parsing Error: %@", error);

    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
