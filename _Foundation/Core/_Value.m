
#import "_Value.h"

@implementation _Value

#pragma mark -

+ (NSValue *)withNonretained:(id)object {
    return [NSValue valueWithNonretainedObject:object];
}

#pragma mark -

+ (NSValue *)withRange:(NSRange)range {
    return [NSValue valueWithRange:range];
}

#pragma mark -

+ (NSValue *)withChar:(char)value {
    return [NSNumber numberWithChar:value];
}

+ (NSValue *)withUnsignedChar:(unsigned char)value {
    return [NSNumber numberWithUnsignedChar:value];
}

+ (NSValue *)withShort:(short)value {
    return [NSNumber numberWithShort:value];
}

+ (NSValue *)withUnsignedShort:(unsigned short)value {
    return [NSNumber numberWithUnsignedShort:value];
}

+ (NSValue *)withInt:(int)value {
    return [NSNumber numberWithInt:value];
}

+ (NSValue *)withUnsignedInt:(unsigned int)value {
    return [NSNumber numberWithUnsignedInt:value];
}

+ (NSValue *)withLong:(long)value {
    return [NSNumber numberWithLong:value];
}

+ (NSValue *)withUnsignedLong:(unsigned long)value {
    return [NSNumber numberWithUnsignedLong:value];
}

+ (NSValue *)withLongLong:(long long)value {
    return [NSNumber numberWithLongLong:value];
}

+ (NSValue *)withUnsignedLongLong:(unsigned long long)value {
    return [NSNumber numberWithUnsignedLongLong:value];
}

+ (NSValue *)withFloat:(float)value {
    return [NSNumber numberWithFloat:value];
}

+ (NSValue *)withDouble:(double)value {
    return [NSNumber numberWithDouble:value];
}

+ (NSValue *)withBool:(BOOL)value {
    return [NSNumber numberWithBool:value];
}

+ (NSValue *)withInteger:(NSInteger)value {
    return [NSNumber numberWithInteger:value];
}

+ (NSValue *)withUnsignedInteger:(NSUInteger)value {
    return [NSNumber numberWithUnsignedInteger:value];
}

@end
