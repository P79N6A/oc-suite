
#import <Foundation/Foundation.h>

@interface _MutexSet : NSObject

#pragma mark - Init
+ (instancetype)set;
+ (instancetype)setWithCapacity:(NSUInteger)num;
+ (instancetype)setWithArray:(NSArray *)array;
+ (instancetype)setWithObject:(id)object;

#pragma mark - Add
- (void)addObject:(id)object;
- (void)addObjectsFromArray:(NSArray *)array;

#pragma mark - Remove
- (void)removeObject:(id)object;
- (void)removeAllObjects;

#pragma mark - Query
- (NSUInteger)count;
- (nullable NSArray *)allObjects;

#pragma mark - Enumerate
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, BOOL *stop))block;

@end
