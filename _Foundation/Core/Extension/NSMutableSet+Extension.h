#import "_Precompile.h"

NS_ASSUME_NONNULL_BEGIN

@interface __GENERICS(NSMutableSet, ObjectType) (Extension)
/**
 * @brief 过滤出
 */
- (void)performSelect:(BOOL (^)(id ObjectType))block;

/**
 * @brief 过滤掉
 */
- (void)performReject:(BOOL (^)(id ObjectType))block;

/**
 * @brief 映射
 */
- (void)performMap:(id (^)(id ObjectType))block;
@end

NS_ASSUME_NONNULL_END
