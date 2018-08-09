
#import "NSArray+Extension.h"

#pragma mark -

@protocol NSMutableArrayProtocol <NSObject>
@required
- (void)addObject:(id)anObject;
@optional
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeLastObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
@end

#pragma mark -

@interface NSMutableArray(Extension)<NSMutableArrayProtocol>

+ (NSMutableArray *)nonRetainingArray;			// copy from Three20

- (void)addUniqueObject:(id)object compare:(NSArrayCompareBlock)compare;
- (void)addUniqueObjects:(const id [])objects count:(NSUInteger)count compare:(NSArrayCompareBlock)compare;
- (void)addUniqueObjectsFromArray:(NSArray *)array compare:(NSArrayCompareBlock)compare;

- (void)unique;
- (void)unique:(NSArrayCompareBlock)compare;

- (void)sort;
- (void)sort:(NSArrayCompareBlock)compare;

- (void)shrink:(NSUInteger)count;
- (void)append:(id)object;

- (NSMutableArray *)pushHead:(NSObject *)obj;
- (NSMutableArray *)pushHeadN:(NSArray *)all;
- (NSMutableArray *)popTail;
- (NSMutableArray *)popTailN:(NSUInteger)n;

- (NSMutableArray *)pushTail:(NSObject *)obj;
- (NSMutableArray *)pushTailN:(NSArray *)all;
- (NSMutableArray *)popHead;
- (NSMutableArray *)popHeadN:(NSUInteger)n;

- (NSMutableArray *)keepHead:(NSUInteger)n;
- (NSMutableArray *)keepTail:(NSUInteger)n;

- (void)addObjectIfNotNil:(id)anObject;
- (BOOL)addObjectsFromArrayIfNotNil:(NSArray *)otherArray;

@end

NS_ASSUME_NONNULL_BEGIN

@interface __GENERICS(NSMutableArray, ObjectType) (Function)

/** Filters a mutable array to the objects matching the block.
 */
- (void)performSelect:(BOOL (^)(id ObjectType))block;

/** Filters a mutable array to all objects but the ones matching the block,
 the logical inverse to select:.
 */
- (void)performReject:(BOOL (^)(id ObjectType))block;

/** Transform the objects in the array to the results of the block.
 */
- (void)performMap:(id (^)(id ObjectType))block;

@end

NS_ASSUME_NONNULL_END
