
#import "NSDictionary+Extension.h"
#import "NSMutableDictionary+Extension.h"
#import "NSObject+Extension.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation NSDictionary(Extension)

- (BOOL)hasObjectForKey:(id)key {
	return [self objectForKey:key] ? YES : NO;
}

- (id)objectForOneOfKeys:(NSArray *)array {
	for ( NSString * key in array ) {
		NSObject * obj = [self objectForKey:key];
		
		if ( obj ) {
			return obj;
		}
	}
	
	return nil;
}

- (id)objectAtPath:(NSString *)path {
	return [self objectAtPath:path separator:nil];
}

- (id)objectAtPath:(NSString *)path separator:(NSString *)separator {
	if ( nil == separator ) {
		path = [path stringByReplacingOccurrencesOfString:@"." withString:@"/"];
		separator = @"/";
	}
	
	NSArray * array = [path componentsSeparatedByString:separator];
	if ( 0 == [array count] ) {
		return nil;
	}

	NSObject * result = nil;
	NSDictionary * dict = self;
	
	for ( NSString * subPath in array ) {
		if ( 0 == [subPath length] )
			continue;
		
		result = [dict objectForKey:subPath];
		if ( nil == result )
			return nil;

		if ( [array lastObject] == subPath ) {
			return result;
		} else if ( NO == [result isKindOfClass:[NSDictionary class]] ) {
			return nil;
		}

		dict = (NSDictionary *)result;
	}
	
	return (result == [NSNull null]) ? nil : result;
}

- (id)objectAtPath:(NSString *)path otherwise:(NSObject *)other {
	NSObject * obj = [self objectAtPath:path];
	
	return obj ? obj : other;
}

- (id)objectAtPath:(NSString *)path otherwise:(NSObject *)other separator:(NSString *)separator {
	NSObject * obj = [self objectAtPath:path separator:separator];
	
	return obj ? obj : other;
}

- (BOOL)boolAtPath:(NSString *)path {
	return [self boolAtPath:path otherwise:NO];
}

- (BOOL)boolAtPath:(NSString *)path otherwise:(BOOL)other {
	NSObject * obj = [self objectAtPath:path];
	
	if ( [obj isKindOfClass:[NSNull class]] ) {
		return NO;
	} else if ( [obj isKindOfClass:[NSNumber class]] ) {
		return [(NSNumber *)obj intValue] ? YES : NO;
	} else if ( [obj isKindOfClass:[NSString class]] ) {
		if ( [(NSString *)obj hasPrefix:@"y"] || [(NSString *)obj hasPrefix:@"Y"] ||
			 [(NSString *)obj hasPrefix:@"T"] || [(NSString *)obj hasPrefix:@"t"] ||
			 [(NSString *)obj isEqualToString:@"1"] ) {
			return YES;
		} else {
			return NO;
		}
	}

	return other;
}

- (NSNumber *)numberAtPath:(NSString *)path {
	NSObject * obj = [self objectAtPath:path];
	
	if ( [obj isKindOfClass:[NSNull class]] ) {
		return nil;
	} else if ( [obj isKindOfClass:[NSNumber class]] ) {
		return (NSNumber *)obj;
	} else if ( [obj isKindOfClass:[NSString class]] ) {
		return [NSNumber numberWithDouble:[(NSString *)obj doubleValue]];
	}

	return nil;
}

- (NSNumber *)numberAtPath:(NSString *)path otherwise:(NSNumber *)other {
	NSNumber * obj = [self numberAtPath:path];
	
	return obj ? obj : other;
}

- (NSString *)stringAtPath:(NSString *)path {
	NSObject * obj = [self objectAtPath:path];
	
	if ( [obj isKindOfClass:[NSNull class]] ) {
		return nil;
	} else if ( [obj isKindOfClass:[NSNumber class]] ) {
		return [NSString stringWithFormat:@"%d", [(NSNumber *)obj intValue]];
	} else if ( [obj isKindOfClass:[NSString class]] ) {
		return (NSString *)obj;
	}
	
	return nil;
}

- (NSString *)stringAtPath:(NSString *)path otherwise:(NSString *)other {
	NSString * obj = [self stringAtPath:path];
	
	return obj ? obj : other;
}

- (NSArray *)arrayAtPath:(NSString *)path {
	NSObject * obj = [self objectAtPath:path];
	
	return [obj isKindOfClass:[NSArray class]] ? (NSArray *)obj : nil;
}

- (NSArray *)arrayAtPath:(NSString *)path otherwise:(NSArray *)other {
	NSArray * obj = [self arrayAtPath:path];
	
	return obj ? obj : other;
}

- (NSMutableArray *)mutableArrayAtPath:(NSString *)path {
	NSObject * obj = [self objectAtPath:path];
	
	return [obj isKindOfClass:[NSMutableArray class]] ? (NSMutableArray *)obj : nil;	
}

- (NSMutableArray *)mutableArrayAtPath:(NSString *)path otherwise:(NSMutableArray *)other {
	NSMutableArray * obj = [self mutableArrayAtPath:path];
	
	return obj ? obj : other;
}

- (NSDictionary *)dictAtPath:(NSString *)path {
	NSObject * obj = [self objectAtPath:path];
	
	return [obj isKindOfClass:[NSDictionary class]] ? (NSDictionary *)obj : nil;	
}

- (NSDictionary *)dictAtPath:(NSString *)path otherwise:(NSDictionary *)other {
	NSDictionary * obj = [self dictAtPath:path];
	
	return obj ? obj : other;
}

- (NSMutableDictionary *)mutableDictAtPath:(NSString *)path {
	NSObject * obj = [self objectAtPath:path];
	
	return [obj isKindOfClass:[NSMutableDictionary class]] ? (NSMutableDictionary *)obj : nil;	
}

- (NSMutableDictionary *)mutableDictAtPath:(NSString *)path otherwise:(NSMutableDictionary *)other {
	NSMutableDictionary * obj = [self mutableDictAtPath:path];
	
	return obj ? obj : other;
}

@end

#pragma mark -

@implementation NSDictionary (Primitive)

- (BOOL)hasKey:(NSString *)key {
    NSObject *o = self[key];
    BOOL has = o != nil;
    return has;
}

- (BOOL)boolForKey:(NSString *)key {
    BOOL i = [self[key] boolValue];
    return i;
}

- (int)intForKey:(NSString *)key {
    int i = [self[key] intValue];
    return i;
}

- (NSInteger)integerForKey:(NSString *)key {
    NSInteger i = [self[key] integerValue];
    return i;
}

- (NSUInteger)unsignedIntegerForKey:(NSString *)key {
    NSUInteger i = [self[key] unsignedIntegerValue];
    return i;
}

- (CGFloat)cgFloatForKey:(NSString *)key {
    CGFloat f = [self[key] doubleValue];
    return f;
}

- (int)charForKey:(NSString *)key {
    char i = [self[key] charValue];
    return i;
}

- (float)floatForKey:(NSString *)key {
    float i = [self[key] floatValue];
    return i;
}

- (CGPoint)pointForKey:(NSString *)key {
    CGPoint o = CGPointFromString(self[key]);
    return o;
}

- (CGSize)sizeForKey:(NSString *)key {
    CGSize o = CGSizeFromString(self[key]);
    return o;
}

- (CGRect)rectForKey:(NSString *)key {
    CGRect o = CGRectFromString(self[key]);
    return o;
}

@end

@implementation NSMutableDictionary ( Primitive )

- (void)setBool:(BOOL)i forKey:(NSString *)key {
    self[key] = @(i);
}

- (void)setInt:(int)i forKey:(NSString*)key {
    self[key] = @(i);
}

- (void)setInteger:(NSInteger)i forKey:(NSString *)key {
    self[key] = @(i);
}

- (void)setUnsignedInteger:(NSUInteger)i forKey:(NSString *)key {
    self[key] = @(i);
}

- (void)setCGFloat:(CGFloat)f forKey:(NSString *)key {
    self[key] = @(f);
}

- (void)setChar:(char)c forKey:(NSString *)key {
    self[key] = @(c);
}

- (void)setFloat:(float)i forKey:(NSString *)key {
    self[key] = @(i);
}

- (void)setPoint:(CGPoint)o forKey:(NSString *)key{
    self[key] = NSStringFromCGPoint(o);
}

- (void)setSize:(CGSize)o forKey:(NSString *)key {
    self[key] = NSStringFromCGSize(o);
}

- (void)setRect:(CGRect)o forKey:(NSString *)key {
    self[key] = NSStringFromCGRect(o);
}

@end

@implementation NSDictionary (Function)
    
- (void)each:(void (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block(key, obj);
    }];
}
    
- (void)apply:(void (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    
    [self enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
        block(key, obj);
    }];
}
    
- (id)match:(BOOL (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    
    return self[[[self keysOfEntriesPassingTest:^(id key, id obj, BOOL *stop) {
        if (block(key, obj)) {
            *stop = YES;
            return YES;
        }
        
        return NO;
    }] anyObject]];
}
    
- (NSDictionary *)select:(BOOL (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    
    NSArray *keys = [[self keysOfEntriesPassingTest:^(id key, id obj, BOOL *stop) {
        return block(key, obj);
    }] allObjects];
    
    NSArray *objects = [self objectsForKeys:keys notFoundMarker:[NSNull null]];
    return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
}
    
- (NSDictionary *)reject:(BOOL (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    return [self select:^BOOL(id key, id obj) {
        return !block(key, obj);
    }];
}
    
- (NSDictionary *)map:(id (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:self.count];
    
    [self each:^(id key, id obj) {
        id value = block(key, obj) ?: [NSNull null];
        result[key] = value;
    }];
    
    return result;
}
    
- (BOOL)any:(BOOL (^)(id key, id obj))block {
    return [self match:block] != nil;
}
    
- (BOOL)none:(BOOL (^)(id key, id obj))block {
    return [self match:block] == nil;
}
    
- (BOOL)all:(BOOL (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    
    __block BOOL result = YES;
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (!block(key, obj)) {
            result = NO;
            *stop = YES;
        }
    }];
    
    return result;
}

@end

