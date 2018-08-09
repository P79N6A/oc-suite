
#import "_Precompile.h"

NS_ASSUME_NONNULL_BEGIN

@interface __GENERICS(NSSet, ObjectType) ( Extension )

/**
 *  遍历
 */
- (void)each:(void (^)(ObjectType obj))block;
- (void)eachWithIndex:(void (^)(ObjectType obj, int idx))block;

/**
 * 并发
 */
- (void)apply:(void (^)(ObjectType obj))block;

/**
 *  匹配
 */
- (nullable id)match: (BOOL (^)(ObjectType obj))block;

/**
 *  筛选
 */
- (NSSet *)select: (BOOL (^)(ObjectType obj))block;

/**
 *  排除
 */
- (NSSet *)reject:(BOOL (^)(ObjectType obj))block;

/**
 *  映射
 */
- (NSSet *)map: (id (^)(ObjectType obj))block;

/**
 *  化简
 */
- (id)reduce:(id)initial withBlock:(id (^)(id sum, id obj))block;

/**
 * 条件判断：任意一个满足
 */
- (BOOL)any:(BOOL (^)(ObjectType obj))block;

/**
 * 条件判断：无一满足
 */
- (BOOL)none:(BOOL (^)(ObjectType obj))block;

/**
 * 条件判断：所有都满足
 */
- (BOOL)all:(BOOL (^)(ObjectType obj))block;

/**
 *  排序
 */
- (NSSet *)sort;

@end

NS_ASSUME_NONNULL_END

