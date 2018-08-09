#import "NSMapTable+Extension.h"

@implementation NSMapTable (Extension)

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block {
    BOOL stop = NO;
    for(id key in self) {
        id obj = [self objectForKey:key];
        block(key, obj, &stop);
        if(stop) {
            break;
        }
    }
}

- (void)each:(void (^)(id key, id obj))block {
    NSParameterAssert(block != nil);

    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block(key, obj);
    }];
}

- (id)match:(BOOL (^)(id key, id obj))block {
    NSParameterAssert(block != nil);

    __block id match = nil;
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if(block(key, obj)) {
            match = obj;
            *stop = YES;
        }
    }];
    return match;
}

- (NSMapTable *)select:(BOOL (^)(id key, id obj))block {
    NSParameterAssert(block != nil);

    NSMapTable *result = [[NSMapTable alloc] initWithKeyPointerFunctions:self.keyPointerFunctions valuePointerFunctions:self.valuePointerFunctions capacity:self.count];

    [self each:^(id key, id obj) {
        if(block(key, obj)) {
            [result setObject:obj forKey:key];
        }
    }];

    return result;
}

- (NSMapTable *)reject:(BOOL (^)(id key, id obj))block {
    return [self select:^BOOL(id key, id obj) {
        return !block(key, obj);
    }];
}

- (NSMapTable *)map:(id (^)(id key, id obj))block {
    NSParameterAssert(block != nil);

    NSMapTable *result = [[NSMapTable alloc] initWithKeyPointerFunctions:self.keyPointerFunctions valuePointerFunctions:self.valuePointerFunctions capacity:self.count];

    [self each:^(id key, id obj) {
        id value = block(key, obj);
        if (!value)
            value = [NSNull null];

        [result setObject:value forKey:key];
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

- (void)performSelect:(BOOL (^)(id key, id obj))block {
	NSParameterAssert(block != nil);

	NSMutableArray *keys = [NSMutableArray arrayWithCapacity:self.count];

	[self each:^(id key, id obj) {
		if(!block(key, obj)) {
			[keys addObject:key];
		}
	}];

	for(id key in keys) {
		[self removeObjectForKey:key];
	}
}

- (void)performReject:(BOOL (^)(id key, id obj))block {
	NSParameterAssert(block != nil);
	[self performSelect:^BOOL(id key, id obj) {
		return !block(key, obj);
	}];
}

- (void)performMap:(id (^)(id key, id obj))block {
	NSParameterAssert(block != nil);

	NSMutableDictionary *mapped = [NSMutableDictionary dictionaryWithCapacity:self.count];

	[self each:^(id key, id obj) {
		mapped[key] = block(key, obj);
	}];

	[mapped enumerateKeysAndObjectsUsingBlock:^(id key, id mappedObject, BOOL *stop) {
		[self setObject:mappedObject forKey:key];
	}];
}

@end
