
#import <Foundation/Foundation.h>

@interface NSObject ( Extension )

+ (Class)baseClass;

+ (id)unserializeForUnknownValue:(id)value;
+ (id)serializeForUnknownValue:(id)value;

- (void)deepEqualsTo:(id)obj;
- (void)deepCopyFrom:(id)obj;

- (id)clone;					// override point

+ (BOOL)isNullValue:(id)value;

@end
