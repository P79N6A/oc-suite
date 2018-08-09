#import "_Precompile.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableIndexSet (Extension)

/** Filters a mutable index set to the indexes matching the block.
 */
- (void)performSelect:(BOOL (^)(NSUInteger index))block;

/** Filters a mutable index set to all indexes but the ones matching the block,
 the logical inverse to select:.
 */
- (void)performReject:(BOOL (^)(NSUInteger index))block;

/** Transform each index of the index set to a new index, as returned by the
 block.
 */
- (void)performMap:(NSUInteger (^)(NSUInteger index))block;

@end

NS_ASSUME_NONNULL_END
