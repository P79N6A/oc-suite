#import "_Precompile.h"

NS_ASSUME_NONNULL_BEGIN

/** Block extensions for NSMutableOrderedSet.
 */
@interface __GENERICS(NSMutableOrderedSet, ObjectType) (Extension)

/** Filters a mutable ordered set to the objects matching the block.
 */
- (void)performSelect:(BOOL (^)(id ObjectType))block;

/** Filters a mutable ordered set to all objects but the ones matching the
 block, the logical inverse to select:.
 */
- (void)performReject:(BOOL (^)(id ObjectType))block;

/** Transform the objects in the ordered set to the results of the block.
 */
- (void)performMap:(id (^)(id ObjectType))block;

@end

NS_ASSUME_NONNULL_END
