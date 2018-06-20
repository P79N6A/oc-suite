
#import <objc/runtime.h>
#import "_Property.h"
#import "_Encoding.h"
#import "NSDate+Extension.h"
#import "NSObject+Extension.h"
#import "NSDictionary+Extension.h"
#import "NSMutableDictionary+Extension.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation NSObject(Extension)

+ (Class)baseClass {
    return [NSObject class];
}

- (void)deepEqualsTo:(id)obj {
    Class baseClass = [[self class] baseClass];
    if ( nil == baseClass ) {
        baseClass = [NSObject class];
    }
    
    for ( Class clazzType = [self class]; clazzType != baseClass; ) {
        unsigned int		propertyCount = 0;
        objc_property_t *	properties = class_copyPropertyList( clazzType, &propertyCount );
        
        for ( NSUInteger i = 0; i < propertyCount; i++ ) {
            const char *	name = property_getName(properties[i]);
            const char *	attr = property_getAttributes(properties[i]);
            
            if ( [_Encoding isReadOnly:attr] ) {
                continue;
            }
            
            NSString * propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            NSObject * propertyValue = [(NSObject *)obj valueForKey:propertyName];
            
            [self setValue:propertyValue forKey:propertyName];
        }
        
        free( properties );
        
        clazzType = class_getSuperclass( clazzType );
        if ( nil == clazzType )
            break;
    }
}

- (void)deepCopyFrom:(id)obj {
    if ( nil == obj ) {
        return;
    }
    
    Class baseClass = [[obj class] baseClass];
    if ( nil == baseClass ) {
        baseClass = [NSObject class];
    }
    
    for ( Class clazzType = [obj class]; clazzType != baseClass; ) {
        unsigned int		propertyCount = 0;
        objc_property_t *	properties = class_copyPropertyList( clazzType, &propertyCount );
        
        for ( NSUInteger i = 0; i < propertyCount; i++ ) {
            const char *	name = property_getName(properties[i]);
            const char *	attr = property_getAttributes(properties[i]);
            
            if ( [_Encoding isReadOnly:attr] ) {
                continue;
            }
            
            NSString * propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            NSObject * propertyValue = [(NSObject *)obj valueForKey:propertyName];
            
            [self setValue:propertyValue forKey:propertyName];
        }
        
        free( properties );
        
        clazzType = class_getSuperclass( clazzType );
        if ( nil == clazzType )
            break;
    }
}

- (id)clone {
    id newObject = [[[self class] alloc] init];
    
    if ( newObject ) {
        [newObject deepCopyFrom:self];
    }
    
    return newObject;
}

// ----------------------------------
// MARK: -
// ----------------------------------

+ (BOOL)isNullValue:(id)value {
    return ((NSNull *)value == [NSNull null] ||
            [@"<null>" isEqualToString:(NSString *)value] ||
            [@"(null)" isEqualToString:(NSString *)value] ||
            [@"null" isEqualToString:(NSString *)value] ||
            value == nil);
}

// ----------------------------------
// MARK: -
// ----------------------------------

- (BOOL)toBool
{
    return [[self toNumber] boolValue];
}

- (float)toFloat
{
    return [[self toNumber] floatValue];
}

- (double)toDouble
{
    return [[self toNumber] doubleValue];
}

- (NSInteger)toInteger
{
    return [[self toNumber] integerValue];
}

- (NSUInteger)toUnsignedInteger
{
    return [[self toNumber] unsignedIntegerValue];
}

- (NSURL *)toURL
{
    NSString * string = [self toString];
    if ( nil == string )
    {
        return nil;
    }
    
    return [NSURL URLWithString:string];
}

- (NSDate *)toDate
{
    EncodingType encoding = [_Encoding typeOfObject:self];
    
    if ( EncodingType_Null == encoding )
    {
        return nil;
    }
    else if ( EncodingType_Number == encoding )
    {
        NSNumber * number = (NSNumber *)self;
        return [NSDate dateWithTimeIntervalSince1970:[number doubleValue]];
    }
    else if ( EncodingType_String == encoding )
    {
        return [NSDate fromString:(NSString *)self];
    }
    else if ( EncodingType_Date == encoding )
    {
        return (NSDate *)self;
    }
    else if ( EncodingType_Data == encoding )
    {
        NSData *    data = (NSData *)self;
        NSString *    string = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
        
        return [NSDate fromString:string];
    }
    else if ( EncodingType_Url == encoding )
    {
        return nil;
    }
    else if ( EncodingType_Array == encoding )
    {
        return nil;
    }
    else if ( EncodingType_Dict == encoding )
    {
        return nil;
    }
    
    return nil;
}

- (NSNumber *)toNumber
{
    EncodingType encoding = [_Encoding typeOfObject:self];
    
    if ( EncodingType_Null == encoding )
    {
        return [NSNumber numberWithInt:0];
    }
    else if ( EncodingType_Number == encoding )
    {
        return (NSNumber *)self;
    }
    else if ( EncodingType_String == encoding )
    {
        NSString * string = (NSString *)self;
        
        if ( NSOrderedSame == [string compare:@"yes" options:NSCaseInsensitiveSearch] ||
            NSOrderedSame == [string compare:@"true" options:NSCaseInsensitiveSearch] ||
            NSOrderedSame == [string compare:@"on" options:NSCaseInsensitiveSearch] ||
            NSOrderedSame == [string compare:@"1" options:NSCaseInsensitiveSearch] )
        {
            return [NSNumber numberWithBool:YES];
        }
        else if ( NSOrderedSame == [string compare:@"no" options:NSCaseInsensitiveSearch] ||
                 NSOrderedSame == [string compare:@"off" options:NSCaseInsensitiveSearch] ||
                 NSOrderedSame == [string compare:@"false" options:NSCaseInsensitiveSearch] ||
                 NSOrderedSame == [string compare:@"0" options:NSCaseInsensitiveSearch] )
        {
            return [NSNumber numberWithBool:NO];
        }
        else
        {
            return [NSNumber numberWithInteger:[string integerValue]];
        }
    }
    else if ( EncodingType_Date == encoding )
    {
        NSDate * date = (NSDate *)self;
        return [NSNumber numberWithDouble:[date timeIntervalSince1970]];
    }
    else if ( EncodingType_Data == encoding )
    {
        NSData * data = (NSData *)self;
        NSString * string = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
        if ( string )
        {
            return [NSNumber numberWithInteger:[string integerValue]];
        }
    }
    else if ( EncodingType_Url == encoding )
    {
        return nil;
    }
    else if ( EncodingType_Array == encoding )
    {
        return nil;
    }
    else if ( EncodingType_Dict == encoding )
    {
        return nil;
    }
    
    return nil;
}

- (NSString *)toString
{
    EncodingType encoding = [_Encoding typeOfObject:self];
    
    if ( EncodingType_Null == encoding )
    {
        return nil;
    }
    else if ( EncodingType_Number == encoding )
    {
        return [self description];
    }
    else if ( EncodingType_String == encoding )
    {
        return (NSString *)self;
    }
    else if ( EncodingType_Date == encoding )
    {
        return [(NSDate *)self toString:@"yyyy/MM/dd HH:mm:ss z"];
    }
    else if ( EncodingType_Data == encoding )
    {
        NSData *    data = (NSData *)self;
        NSString *    text = nil;
        
        text = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
        if ( nil == text )
        {
            text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ( nil == text )
            {
                text = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            }
        }
        
        return text;
    }
    else if ( EncodingType_Url == encoding )
    {
        NSURL * url = (NSURL *)self;
        return [url absoluteString];
    }
    
    return nil;
}

@end
