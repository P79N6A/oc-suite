
/**
 * This class is designed to be an array that keeps itself sorted as you add objects to it. 
 * When you add an object, you get the index where it was added returned.
 */

#import <Foundation/Foundation.h>

@interface _SortedMutableArray : NSArray

- (id)initWithDescriptors:(NSArray *)descriptors;
- (id)initWithComparator:(NSComparator)comparator;
- (id)initWithFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context;
- (id)initWithSelector:(SEL)selector;

- (NSUInteger)addObject:(id)obj;
- (NSIndexSet*)addObjectsFromArray:(NSArray*)otherArray;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeObjectsInRange:(NSRange)range;
- (void)removeAllObjects;
- (void)removeLastObject;

@end
