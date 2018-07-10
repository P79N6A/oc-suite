
#import <objc/runtime.h>
#import "_Property.h"
#import "_Encoding.h"
#import "_Runtime.h"
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

- (BOOL)shallowCopy:(NSObject *)obj {
    Class currentClass = [self class];
    Class instanceClass = [obj class];
    
    if (self == obj) { //相同实例
        return NO;
    }
    
    if (![obj isMemberOfClass:currentClass] ) { //不是当前类的实例
        return NO;
    }
    
    while (instanceClass != [NSObject class]) {
        unsigned int propertyListCount = 0;
        objc_property_t *propertyList = class_copyPropertyList(currentClass, &propertyListCount);
        for (int i = 0; i < propertyListCount; i++) {
            objc_property_t property = propertyList[i];
            const char *property_name = property_getName(property);
            NSString *propertyName = [NSString stringWithCString:property_name encoding:NSUTF8StringEncoding];
            
            //check if property is dynamic and readwrite
            char *dynamic = property_copyAttributeValue(property, "D");
            char *readonly = property_copyAttributeValue(property, "R");
            if (propertyName && !readonly) {
                id propertyValue = [obj valueForKey:propertyName];
                [self setValue:propertyValue forKey:propertyName];
            }
            free(dynamic);
            free(readonly);
        }
        free(propertyList);
        instanceClass = class_getSuperclass(instanceClass);
    }
    
    return YES;
}

- (BOOL)deepCopy:(NSObject *)obj {
    Class currentClass = [self class];
    Class instanceClass = [obj class];
    
    if (self == obj) { // 相同实例
        return NO;
    }
    
    if (![obj isMemberOfClass:currentClass] ) { // 不是当前类的实例
        return NO;
    }
    
    while (instanceClass != [NSObject class]) {
        unsigned int propertyListCount = 0;
        objc_property_t *propertyList = class_copyPropertyList(currentClass, &propertyListCount);
        for (int i = 0; i < propertyListCount; i++) {
            objc_property_t property = propertyList[i];
            const char *property_name = property_getName(property);
            NSString *propertyName = [NSString stringWithCString:property_name encoding:NSUTF8StringEncoding];
            
            //check if property is dynamic and readwrite
            char *dynamic = property_copyAttributeValue(property, "D");
            char *readonly = property_copyAttributeValue(property, "R");
            if (propertyName && !readonly) {
                id propertyValue = [obj valueForKey:propertyName];
                Class propertyValueClass = [propertyValue class];
                BOOL flag = [NSObject isNSObjectClass:propertyValueClass];
                if (flag) {
                    if ([propertyValue conformsToProtocol:@protocol(NSCopying)]) {
                        NSObject *copyValue = [propertyValue copy];
                        [self setValue:copyValue forKey:propertyName];
                    }else{
                        NSObject *copyValue = [[[propertyValue class]alloc]init];
                        [obj deepCopy:propertyValue];
                        [self setValue:copyValue forKey:propertyName];
                    }
                }else{
                    [self setValue:propertyValue forKey:propertyName];
                }
            }
            free(dynamic);
            free(readonly);
        }
        free(propertyList);
        instanceClass = class_getSuperclass(instanceClass);
    }
    
    return YES;
}

- (id)deepCopy {
    id obj = nil;
    @try {
        obj = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
    }
    
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    return obj;
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

- (NSString *)toString {
    EncodingType encoding = [_Encoding typeOfObject:self];
    
    if ( EncodingType_Null == encoding ) {
        return nil;
    } else if ( EncodingType_Number == encoding ) {
        return [self description];
    } else if ( EncodingType_String == encoding ) {
        return (NSString *)self;
    } else if ( EncodingType_Date == encoding ) {
        return [(NSDate *)self toString:@"yyyy/MM/dd HH:mm:ss z"];
    } else if ( EncodingType_Data == encoding ) {
        NSData *    data = (NSData *)self;
        NSString *    text = nil;
        
        text = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
        if ( nil == text ) {
            text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ( nil == text ) {
                text = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            }
        }
        
        return text;
    } else if ( EncodingType_Url == encoding ) {
        NSURL * url = (NSURL *)self;
        return [url absoluteString];
    }
    
    return nil;
}

#pragma mark - Object 2 Json\Dictionary

- (id)getObjectInternal:(id)obj {
    if([obj isKindOfClass:[NSString class]]
       || [obj isKindOfClass:[NSNumber class]]
       || [obj isKindOfClass:[NSNull class]]) {
        return obj;
    }
    
    if([obj isKindOfClass:[NSArray class]]) {
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        
        for(int i = 0; i < objarr.count; i++) {
            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        
        return arr;
    }
    
    if([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        
        for(NSString *key in objdic.allKeys) {
            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
        }
        
        return dic;
    }
    
    return [self getObjectData:obj];
}

- (NSDictionary*)getObjectData:(NSObject *)obj {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);
    
    for(int i = 0; i < propsCount; i++) {
        objc_property_t prop = props[i];
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        id value = [obj valueForKey:propName];
        if(value == nil) {
            value = [NSNull null];
        } else {
            value = [self getObjectInternal:value];
            
        }
        
        [dic setObject:value forKey:propName];
    }
    
    return dic;
}

- (NSDictionary *)toDictionary {
    return [self getObjectData:self];
}

- (NSData *)toJsonDataWithOptions:(NSJSONWritingOptions)options {
    return [NSJSONSerialization dataWithJSONObject:[self getObjectData:self] options:options error:nil];
}


@end
