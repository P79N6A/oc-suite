
#import "_Precompile.h"

NS_ASSUME_NONNULL_BEGIN

@interface __GENERICS(NSOrderedSet, ObjectType) ( Extension )

/**
 * 遍历
 */
- (void)each:(void (^)(ObjectType obj))block;

/**
 * 并发遍历
 */
- (void)apply:(void (^)(ObjectType obj))block;

/**
 * 匹配查找单个
 */
- (nullable id)match:(BOOL (^)(ObjectType obj))block;

/**
 * 查询一组
 */
- (NSOrderedSet *)select:(BOOL (^)(ObjectType obj))block;

/**
 * 查询不符合的一组
 */
- (NSOrderedSet *)reject:(BOOL (^)(ObjectType obj))block;

/**
 * 映射
 */
- (NSOrderedSet *)map:(id (^)(ObjectType obj))block;

/**
 * 化简
 */
- (nullable id)reduce:(nullable id)initial withBlock:(__nullable id (^)(__nullable id sum, ObjectType obj))block;

/** Loops through an ordered set to find whether any object matches the block.
 */
- (BOOL)any:(BOOL (^)(ObjectType obj))block;

/** Loops through an ordered set to find whether no objects match the block.
 */
- (BOOL)none:(BOOL (^)(ObjectType obj))block;

/** Loops through an ordered set to find whether all objects match the block.
 */
- (BOOL)all:(BOOL (^)(ObjectType obj))block;

/** Tests whether every element of this ordered set relates to the corresponding
 element of another array according to match by block.
 */
- (BOOL)corresponds:(NSOrderedSet *)list withBlock:(BOOL (^)(ObjectType obj1, id obj2))block;
@end

NS_ASSUME_NONNULL_END
