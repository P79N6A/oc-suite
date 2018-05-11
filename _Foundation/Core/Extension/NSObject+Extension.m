
#import <objc/runtime.h>
#import "_Property.h"
#import "_Encoding.h"
#import "NSObject+Extension.h"
#import "NSDictionary+Extension.h"
#import "NSMutableDictionary+Extension.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation NSObject(Extension)

+ (Class)baseClass
{
    return [NSObject class];
}

+ (id)unserializeForUnknownValue:(id)value
{
    UNUSED( value )
    
    return nil;
}

+ (id)serializeForUnknownValue:(id)value
{
    UNUSED( value )
    
    return nil;
}

- (void)deepEqualsTo:(id)obj
{
    Class baseClass = [[self class] baseClass];
    if ( nil == baseClass )
    {
        baseClass = [NSObject class];
    }
    
    for ( Class clazzType = [self class]; clazzType != baseClass; )
    {
        unsigned int		propertyCount = 0;
        objc_property_t *	properties = class_copyPropertyList( clazzType, &propertyCount );
        
        for ( NSUInteger i = 0; i < propertyCount; i++ )
        {
            const char *	name = property_getName(properties[i]);
            const char *	attr = property_getAttributes(properties[i]);
            
            if ( [_Encoding isReadOnly:attr] )
            {
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

- (void)deepCopyFrom:(id)obj
{
    if ( nil == obj )
    {
        return;
    }
    
    Class baseClass = [[obj class] baseClass];
    if ( nil == baseClass )
    {
        baseClass = [NSObject class];
    }
    
    for ( Class clazzType = [obj class]; clazzType != baseClass; )
    {
        unsigned int		propertyCount = 0;
        objc_property_t *	properties = class_copyPropertyList( clazzType, &propertyCount );
        
        for ( NSUInteger i = 0; i < propertyCount; i++ )
        {
            const char *	name = property_getName(properties[i]);
            const char *	attr = property_getAttributes(properties[i]);
            
            if ( [_Encoding isReadOnly:attr] )
            {
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


- (id)clone
{
    id newObject = [[[self class] alloc] init];
    
    if ( newObject )
    {
        [newObject deepCopyFrom:self];
    }
    
    return newObject;
}

#pragma mark -

+ (BOOL)isNullValue:(id)value {
    return ((NSNull *)value == [NSNull null] ||
            [@"<null>" isEqualToString:(NSString *)value] ||
            [@"(null)" isEqualToString:(NSString *)value] ||
            [@"null" isEqualToString:(NSString *)value] ||
            value == nil);
}


@end
