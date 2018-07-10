
#import <Foundation/Foundation.h>

@interface NSObject ( Extension )

+ (Class)baseClass;

- (void)deepEqualsTo:(id)obj;
- (void)deepCopyFrom:(id)obj;

- (BOOL)shallowCopy:(NSObject *)obj;
- (BOOL)deepCopy:(NSObject *)obj;
- (id)deepCopy;

- (id)clone;					// override point

+ (BOOL)isNullValue:(id)value;

// Convertor
- (BOOL)toBool;
- (float)toFloat;
- (double)toDouble;
- (NSInteger)toInteger;
- (NSUInteger)toUnsignedInteger;

- (NSURL *)toURL;
- (NSDate *)toDate;
- (NSNumber *)toNumber;
- (NSString *)toString;

#pragma mark - Object 2 Json\Dictionary

- (NSDictionary *)toDictionary; // 打印属性名－属性值的，键值对

- (NSData *)toJsonDataWithOptions:(NSJSONWritingOptions)options;

@end
