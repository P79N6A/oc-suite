#import "_Precompile.h"

NS_ASSUME_NONNULL_BEGIN

@interface __GENERICS(NSMapTable, KeyType, ObjectType) (BlocksKit)

/** Loops through the maptable and executes the given block using each item.
 */
- (void)each:(void (^)(KeyType key, ObjectType obj))block;

/** Loops through a maptable to find the first key/value pair matching the block.
 */
- (nullable id)match:(BOOL (^)(KeyType key, ObjectType obj))block;

/** Loops through a maptable to find the key/value pairs matching the block.
 */
- (NSMapTable *)select:(BOOL (^)(KeyType key, ObjectType obj))block;

/** Loops through a maptable to find the key/value pairs not matching the block.
 */
- (NSMapTable *)reject:(BOOL (^)(KeyType key, ObjectType obj))block;

/** Call the block once for each object and create a maptable with the same keys
 and a new set of values.
 */
- (NSMapTable *)map:(id (^)(KeyType key, ObjectType obj))block;

/** Loops through a maptable to find whether any key/value pair matches the block.
 */
- (BOOL)any:(BOOL (^)(KeyType key, ObjectType obj))block;

/** Loops through a maptable to find whether no key/value pairs match the block.
 */
- (BOOL)none:(BOOL (^)(KeyType key, ObjectType obj))block;

/** Loops through a maptable to find whether all key/value pairs match the block.
 */
- (BOOL)all:(BOOL (^)(KeyType key, ObjectType obj))block;

/** Filters a mutable dictionary to the key/value pairs matching the block.
 */
- (void)performSelect:(BOOL (^)(KeyType key, ObjectType obj))block;

/** Filters a mutable dictionary to the key/value pairs not matching the block,
 the logical inverse to select:.
 */
- (void)performReject:(BOOL (^)(KeyType key, ObjectType obj))block;

/** Transform each value of the dictionary to a new value, as returned by the
 block.
 */
- (void)performMap:(id (^)(KeyType key, ObjectType obj))block;

@end

NS_ASSUME_NONNULL_END
