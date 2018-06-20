
#import <Foundation/Foundation.h>

@interface NSObject ( Extension )

+ (Class)baseClass;

- (void)deepEqualsTo:(id)obj;
- (void)deepCopyFrom:(id)obj;

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

@end
