#import "NSMutableSet+Extension.h"

@implementation NSMutableSet (Extension)

- (void)performSelect:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    NSSet *list = [self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        return block(obj);
    }];
    
    [self setSet:list];
}
    
- (void)performReject:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    [self performSelect:^BOOL(id obj) {
        return !block(obj);
    }];
}
    
- (void)performMap:(id (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    NSMutableSet *new = [NSMutableSet setWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        id value = block(obj);
        if (!value) return;
        [new addObject:value];
    }];
    
    [self setSet:new];
}
@end
