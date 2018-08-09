
#import "NSMutableDictionary+Extension.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

static const void *	__RetainFunc( CFAllocatorRef allocator, const void * value ) { return value; }
static void			__ReleaseFunc( CFAllocatorRef allocator, const void * value ) { }

#pragma mark -

@implementation NSMutableDictionary(Extension)

+ (NSMutableDictionary *)nonRetainingDictionary {
	CFDictionaryValueCallBacks callbacks = kCFTypeDictionaryValueCallBacks;
	callbacks.retain = __RetainFunc;
	callbacks.release = __ReleaseFunc;
	return (__bridge_transfer NSMutableDictionary *)CFDictionaryCreateMutable( NULL, 0, &kCFTypeDictionaryKeyCallBacks, &callbacks );
}

+ (NSMutableDictionary *)keyValues:(id)first, ... {
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	
	va_list args;
	va_start( args, first );
	
	for ( ;; first = nil )
	{
		NSObject * key = first ? first : va_arg( args, NSObject * );
		if ( nil == key || NO == [key isKindOfClass:[NSString class]] )
			break;
		
		NSObject * value = va_arg( args, NSObject * );
		if ( nil == value )
			break;
		
		[dict setObject:value atPath:(NSString *)key];
	}
    va_end( args );
	return dict;
}

- (BOOL)setObject:(NSObject *)obj atPath:(NSString *)path {
	return [self setObject:obj atPath:path separator:nil];
}

- (BOOL)setObject:(NSObject *)obj atPath:(NSString *)path separator:(NSString *)separator {
	if ( 0 == [path length] )
		return NO;
	
	if ( nil == separator ) {
		path = [path stringByReplacingOccurrencesOfString:@"." withString:@"/"];
		separator = @"/";
	}
	
	NSArray * array = [path componentsSeparatedByString:separator]; 
	if ( 0 == [array count] ) {
		[self setObject:obj forKey:path];
		return YES;
	}

	NSMutableDictionary *	upperDict = self;
	NSDictionary *			dict = nil;
	NSString *				subPath = nil;

	for ( subPath in array ) {
		if ( 0 == [subPath length] )
			continue;

		if ( [array lastObject] == subPath )
			break;

		dict = [upperDict objectForKey:subPath];
		if ( nil == dict ) {
			dict = [NSMutableDictionary dictionary];
			[upperDict setObject:dict forKey:subPath];
		} else {
			if ( NO == [dict isKindOfClass:[NSDictionary class]] )
				return NO;

			if ( NO == [dict isKindOfClass:[NSMutableDictionary class]] )
			{
				dict = [NSMutableDictionary dictionaryWithDictionary:dict];
				[upperDict setObject:dict forKey:subPath];
			}
		}

		upperDict = (NSMutableDictionary *)dict;
	}

	if ( subPath && obj ) {
		[upperDict setObject:obj forKey:subPath];
	}
	return YES;
}

- (BOOL)setKeyValues:(id)first, ... {
	va_list args;
	va_start( args, first );
	
	for ( ;; first = nil ) {
		NSObject * key = first ? first : va_arg( args, NSObject * );
		if ( nil == key || NO == [key isKindOfClass:[NSString class]] )
			break;

		NSObject * value = va_arg( args, NSObject * );
		if ( nil == value )
			break;

		BOOL ret = [self setObject:value atPath:(NSString *)key];
		if ( NO == ret ) {
            va_end( args );
			return NO;
        }
	}
	va_end( args );
	return YES;
}

- (id)objectForOneOfKeys:(NSArray *)array remove:(BOOL)flag {
	id result = [self objectForOneOfKeys:array];
	
	if ( flag ) {
		[self removeObjectsForKeys:array];
	}
	
	return result;
}

@end

@implementation NSMutableDictionary (Function)
    
- (void)performSelect:(BOOL (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    
    NSArray *keys = [[self keysOfEntriesWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id key, id obj, BOOL *stop) {
        return !block(key, obj);
    }] allObjects];
    
    [self removeObjectsForKeys:keys];
}

- (void)performReject:(BOOL (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    [self performSelect:^BOOL(id key, id obj) {
        return !block(key, obj);
    }];
}

- (void)performMap:(id (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    
    NSMutableDictionary *new = [self mutableCopy];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id value = block(key, obj) ?: [NSNull null];
        if ([value isEqual:obj]) return;
        new[key] = value;
    }];
    
    [self setDictionary:new];
}

@end

