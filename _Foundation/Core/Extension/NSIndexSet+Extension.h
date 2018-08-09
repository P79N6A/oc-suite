#import "_Precompile.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSIndexSet (Extension)

/** Loops through an index set and executes the given block at each index.
 */
- (void)each:(void (^)(NSUInteger index))block;

/** Enumerates each index in an index set concurrently and executes the
 given block once per index.
 */
- (void)apply:(void (^)(NSUInteger index))block;

/** Loops through an array and returns the index matching the block.
 */
- (NSUInteger)match:(BOOL (^)(NSUInteger index))block;

/** Loops through an index set and returns an all indexes matching the block.
 */
- (NSIndexSet *)select:(BOOL (^)(NSUInteger index))block;

/** Loops through an index set and returns an all indexes but the ones matching the block.
 */
- (NSIndexSet *)reject:(BOOL (^)(NSUInteger index))block;

/** Call the block once for each index and create an index set with the new values.
 */
- (NSIndexSet *)map:(NSUInteger (^)(NSUInteger index))block;

/** Call the block once for each index and create an array of the return values.
 */
- (NSArray *)mapIndex:(id (^)(NSUInteger index))block;

/** Loops through an index set to find whether any of the indexes matche the block.
 */
- (BOOL)any:(BOOL (^)(NSUInteger index))block;

/** Loops through an index set to find whether all objects match the block.
 */
- (BOOL)all:(BOOL (^)(NSUInteger index))block;

/** Loops through an index set to find whether no objects match the block.
 */
- (BOOL)none:(BOOL (^)(NSUInteger index))block;

@end

NS_ASSUME_NONNULL_END
