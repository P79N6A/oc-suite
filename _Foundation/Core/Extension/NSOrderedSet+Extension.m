
#import "NSOrderedSet+Extension.h"

@implementation NSOrderedSet ( Extension )
    
- (void)each:(void (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}
    
- (void)apply:(void (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    [self enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}
    
- (id)match:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    NSUInteger index = [self indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return block(obj);
    }];
    
    if (index == NSNotFound) return nil;
    return self[index];
}
    
- (NSOrderedSet *)select:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    NSArray *objects = [self objectsAtIndexes:[self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return block(obj);
    }]];
    
    if (!objects.count) return [[self class] orderedSet];
    return [[self class] orderedSetWithArray:objects];
}
    
- (NSOrderedSet *)reject:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    return [self select:^BOOL(id obj) {
        return !block(obj);
    }];
}
    
- (NSOrderedSet *)map:(id (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    NSMutableOrderedSet *result = [NSMutableOrderedSet orderedSetWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = block(obj) ?: [NSNull null];
        [result addObject:value];
    }];
    
    return result;
}
    
- (id)reduce:(id)initial withBlock:(id (^)(id sum, id obj))block {
    NSParameterAssert(block != nil);
    
    __block id result = initial;
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        result = block(result, obj);
    }];
    
    return result;
}
    
- (BOOL)any:(BOOL (^)(id obj))block {
    return [self match:block] != nil;
}
    
- (BOOL)none:(BOOL (^)(id obj))block {
    return [self match:block] == nil;
}
    
- (BOOL)all:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    __block BOOL result = YES;
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (!block(obj)) {
            result = NO;
            *stop = YES;
        }
    }];
    
    return result;
}
    
- (BOOL)corresponds:(NSOrderedSet *)list withBlock:(BOOL (^)(id obj1, id obj2))block {
    NSParameterAssert(block != nil);
    
    __block BOOL result = NO;
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx < list.count) {
            id obj2 = list[idx];
            result = block(obj, obj2);
        } else {
            result = NO;
        }
        *stop = !result;
    }];
    
    return result;
}

@end
