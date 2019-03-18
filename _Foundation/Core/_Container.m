
#import "_Precompile.h"
#import "_Container.h"
#import "_Macros.h"

// ----------------------------------
// MARK: NSObject SafeValueWithJSON
// ----------------------------------

@implementation NSObject ( SafeValueWithJSON )

- (id)safeValueFromJSON {
    return self == [NSNull null] ? nil : self;
}

- (id)safeObjectWithClass:(Class)class {
    if ([self isKindOfClass:class]) {
        return self;
    } else {
        NSAssert(NO,
                 @"Object class not matched, self is %@, should be %@",
                 NSStringFromClass([self class]),
                 NSStringFromClass(class));
        return nil;
    }
}

- (NSString *)safeString {
    return [self safeObjectWithClass:[NSString class]];
}

- (NSNumber *)safeNumber {
    return [self safeObjectWithClass:[NSNumber class]];
}

- (NSArray *)safeArray {
    return [self safeObjectWithClass:[NSArray class]];
}

- (NSDictionary *)safeDictionary {
    return [self safeObjectWithClass:[NSDictionary class]];
}

- (NSDate *)safeDate {
    return [self safeObjectWithClass:[NSDate class]];
}

@end

// ----------------------------------
// MARK: NSArray
// ----------------------------------

@implementation NSArray ( SafeValue )

- (NSString *)safeStringAtIndex:(NSUInteger)index {
    return [[self objectAtIndexIfIndexInBounds:index] safeString];
}

- (NSNumber *)safeNumberAtIndex:(NSUInteger)index {
    return [[self objectAtIndexIfIndexInBounds:index] safeNumber];

}

- (NSArray *)safeArrayAtIndex:(NSUInteger)index {
    return [[self objectAtIndexIfIndexInBounds:index] safeArray];
}

- (NSDictionary *)safeDictionaryAtIndex:(NSUInteger)index {
    return [[self objectAtIndexIfIndexInBounds:index] safeDictionary];
}

#pragma mark -

- (id)safeObjectAtIndex:(NSUInteger)index {
    if ( index >= self.count )
        return nil;
    
    return [self objectAtIndex:index];
}

- (id)safeSubarrayWithRange:(NSRange)range {
    if ( 0 == self.count )
        return [NSArray array];
    
    if ( range.location >= self.count )
        return [NSArray array];
    
    range.length = MIN( range.length, self.count - range.location );
    if ( 0 == range.length )
        return [NSArray array];
    
    return [self subarrayWithRange:NSMakeRange(range.location, range.length)];
}

- (id)safeSubarrayFromIndex:(NSUInteger)index {
    if ( 0 == self.count )
        return [NSArray array];
    
    if ( index >= self.count )
        return [NSArray array];
    
    return [self safeSubarrayWithRange:NSMakeRange(index, self.count - index)];
}

- (id)safeSubarrayWithCount:(NSUInteger)count {
    if ( 0 == self.count )
        return [NSArray array];
    
    return [self safeSubarrayWithRange:NSMakeRange(0, count)];
}

@end

@implementation NSArray (SafeInvoke)

- (id)objectAtIndexIfIndexInBounds:(NSUInteger)index {
    if (index < [self count]) {
        return [self objectAtIndex:index];
    }
    return nil;
}

@end

// ----------------------------------
// MARK: NSDictionary SafeValue
// ----------------------------------

@implementation NSDictionary ( SafeValue )

- (NSString *)safeStringForKey:(id)key {
    id obj = [self objectForKey:key];
    
    if (is_empty(obj)) {
        return nil;
    } else {
        return [obj safeString];
    }
}

- (NSNumber *)safeNumberForKey:(id)key {
    id obj = [self objectForKey:key];
    
    if (is_empty(obj)) {
        return nil;
    } else {
        return [obj safeNumber];
    }
}

- (NSArray *)safeArrayForKey:(id)key {
    id obj = [self objectForKey:key];
    
    if (is_empty(obj)) {
        return nil;
    } else {
        return [obj safeArray];
    }
}

- (NSDictionary *)safeDictionaryForKey:(id)key {
    id obj = [self objectForKey:key];
    
    if (is_empty(obj)) {
        return nil;
    } else {
        return [obj safeDictionary];
    }
}

@end

// ----------------------------------
// MARK: NSMutableDictionary
// ----------------------------------

@implementation NSMutableDictionary ( SafeValue )

- (void)safeSetObject:(id)anObject forKey:(id)aKey {
    if (anObject && aKey) {
        [self setObject:anObject forKey:aKey];
    }
}

- (NSMutableDictionary *)safeAppendObject:(id)anObject forKey:(id)aKey {
    [self safeSetObject:anObject forKey:aKey];
    
    return self;
}

@end
