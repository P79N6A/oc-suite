#import "NSError+Extension.h"

@interface NSObject (Property_Traversal)

- (void)objectPropertyTraversal; // 也可以withBlock，对属性进行处理

+ (void)objectPropertyTraversal; // 也可以withBlock，对属性进行处理

@end

@implementation NSError ( Extension )

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

+ (NSError *)errorForCode:(NSInteger)code {
    NSError *error = make_error(make_string_obj(NSStringFromClass([self class])), code);
    
    if (![error isPooled]) { // pool中没有该key的error
        [self objectPropertyTraversal];
    }
    
    return make_error_3(make_string_obj(NSStringFromClass([self class])), code, nil);
}

- (NSError *)errorForCode:(NSInteger)code {
    NSError *error = make_error(make_string_obj(NSStringFromClass([self class])), code);
    
    if (![error isPooled]) {
        [self objectPropertyTraversal];
    }
    
    return make_error_3(make_string_obj(NSStringFromClass([self class])), code, nil);
}

@end

#pragma mark -

@implementation NSError (Handler)

@def_nsstring( messagedKey, @"NSError.message.key" )

@def_nsstring( CocoaErrorDomain           , NSCocoaErrorDomain )
@def_nsstring( LocalizedDescriptionKey    , NSLocalizedDescriptionKey )
@def_nsstring( StringEncodingErrorKey     , NSStringEncodingErrorKey )
@def_nsstring( URLErrorKey                , NSURLErrorKey )
@def_nsstring( FilePathErrorKey           , NSFilePathErrorKey )
@def_nsstring( SamuraiErrorDomain         , @"NSError.samurai.domain" )

#pragma mark - Error maker

+ (instancetype)errorWithDomain:(NSString *)domain
                           code:(NSInteger)code
                           desc:(NSString *)desc { // desc 可以为空
    NSAssert(domain, @"Domain nil");
    
    desc = !desc ? @"" : desc;
    
    NSDictionary *userInfo      = @{[self messagedKey]:desc};
    NSError *error              = [self errorWithDomain:domain code:code userInfo:userInfo];;
    
    // 加入pool
    if (![error isPooled]) {
        [error toPool];
        
        return error;
    } else {
        return [error fromPool];
    }
}

#pragma mark - Equal

- (BOOL)isInteger:(NSInteger)code {
    return [self code] == code;
}

- (BOOL)is:(NSError *)error {
    
    if ([[self domain] isEqual:[error domain]] &&
        [self code] == [error code]) {
        return YES;
    } else if ([self code] == [error code]) {
        LOG(@"error 相比，code相等，domain不同, %@, %@", self, error);
        
        return YES;
    }
    
    return NO;
}

#pragma mark - UserInfo

- (NSString *)message {
    
    if (self.userInfo &&
        [self.userInfo.allKeys containsString:[self messagedKey]]) {
        
        return self.userInfo[[self messagedKey]];
    }
    
    // 没有消息
    return undefined_string;
}

#pragma mark - Key

- (NSString *)storedKey {
    return [NSString stringWithFormat:@"%@.%zd", self.domain, self.code]; // todo: use MACRO
}

- (NSString *)domainKey {
    return [self domain];
}

- (NSNumber *)codeKey {
    return @(self.code);
}

#pragma mark - Error pool

+ (id)errorPoolOrCreate {
    static NSMutableDictionary *pool;
    
    if (!pool) {
        pool                        = [NSMutableDictionary new];
    }
    
    return pool;
}

+ (id)errorPool {
    return [self errorPoolOrCreate];
}

- (id)errorPoolOrCreate {
    return [self.class errorPoolOrCreate];
}

- (id)errorPool {
    return [self.class errorPool];
}

#pragma mark - Error manage

+ (BOOL)isPooled:(NSString *)key {
    NSAssert(key, @"Error key nil");
    
    return NO;
}

- (BOOL)isPooled {
    NSMutableDictionary *pool       = [self errorPool];
    
    if (!pool) {
        return NO;
    }
    
    LOG(@"storeKey = %@", [self storedKey]);
    
    /**
     *  @knowledge
     
     *  containsObject:
     
     *  This method determines whether anObject is present in the receiver by sending an isEqual: message to each of the receiver’s objects (and passing anObject as the parameter to each isEqual: message).
     */
    //    if ([pool.allKeys containsObject:[self storedKey]]) {
    //        return YES;
    //    }
    
    if ([pool.allKeys containsString:[self storedKey]]) {
        return YES;
    }
    
    return NO;
}

- (void)toPool {
    NSAssert(self.storedKey, @"Error key nil");
    
    // 加入到pool
    NSMutableDictionary *pool       = [self errorPool];
    
    if (pool && ![pool.allKeys containsString:[self storedKey]]) {
        [pool setObject:self forKey:[self storedKey]];
    }
}

- (NSDictionary *)pooling {
    return @{[self storedKey] : self};
}

// 从内部pool中取出来
- (id)fromPool {
    if ([self isPooled]) {
        NSMutableDictionary *pool       = [self errorPool];
        
        return [pool objectForKey:[self storedKey]];
    } else {
        return nil;
    }
}

// 不移除外部pool中的信息
- (void)removeFromPool {
    NSAssert(self.storedKey, @"Error key nil");
    
    NSMutableDictionary *pool       = [self errorPool];
    
    if (pool && [pool.allKeys containsString:[self storedKey]]) {
        [pool removeObjectForKey:[self storedKey]];
    }
}

- (void)removeAllErrorsFromPool {
    NSMutableDictionary *pool       = [self errorPool];
    
    if (pool) {
        [pool removeAllObjects];
    }
}

@end

#pragma mark - NSObject (Property_Traversal)

@implementation NSObject (Property_Traversal)

+ (void)objectPropertyTraversal {
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([self class], &propsCount);
    
    //    TODO( "Should be 递归" )
    for(int i = 0; i < propsCount; i++) {
        objc_property_t prop    = props[i];
        NSString *propName      = [NSString stringWithUTF8String:property_getName(prop)];
        __unused id value       = [self valueForKey:propName];
    }
}

- (void)objectPropertyTraversal {
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([self class], &propsCount);
    
    //    TODO( "Should be 递归" )
    
    for(int i = 0; i < propsCount; i++) {
        objc_property_t prop    = props[i];
        NSString *propName      = [NSString stringWithUTF8String:property_getName(prop)];
        __unused id value       = [self valueForKey:propName];
    }
}

@end
