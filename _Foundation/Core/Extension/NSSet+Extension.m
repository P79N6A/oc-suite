
#import "NSSet+Extension.h"

@implementation NSSet ( Extension )

- (void)each:(void (^)(id))block {
    NSParameterAssert(block != nil);
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        block(obj);
    }];
}
    
- (void)eachWithIndex:(void (^)(id, int))block {
    __block int counter = 0;
    
    NSParameterAssert(block != nil);
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        block(obj, counter);
        counter ++;
    }];
}
    
- (void)apply:(void (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    [self enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, BOOL *stop) {
        block(obj);
    }];
}
    
- (id)match:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    return [[self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        if (block(obj)) {
            *stop = YES;
            return YES;
        }
        
        return NO;
    }] anyObject];
}

- (NSSet *)select:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    return [self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        return block(obj);
    }];
}
    
- (NSSet *)reject:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    return [self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        return !block(obj);
    }];
}

- (NSSet *)map:(id (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    NSMutableSet *result = [NSMutableSet setWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        id value = block(obj) ?:[NSNull null];
        [result addObject:value];
    }];
    
    return result;
}

- (id)reduce:(id)initial withBlock:(id (^)(id sum, id obj))block {
    NSParameterAssert(block != nil);
    
    __block id result = initial;
    
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
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
    
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if (!block(obj)) {
            result = NO;
            *stop = YES;
        }
    }];
    
    return result;
}

- (NSArray *)sort {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    return [self sortedArrayUsingDescriptors:@[sortDescriptor]];
}

@end
