#import <Foundation/Foundation.h>

// MARK: - _SerialQueuedArray

@interface _SerialQueuedArray : NSObject

- (instancetype)init;
- (instancetype)initWithArray:(NSArray *)array;

- (void)addObject:(NSObject *)object;
- (void)addObjectsFromArray:(NSArray *)array;

- (void)insertObject:(NSObject *)object
             atIndex:(NSUInteger)index;

- (void)removeObject:(NSObject *)object;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeAllObjects;

- (id)objectAtIndex:(NSUInteger)index;

- (NSUInteger)count;

- (NSArray *)filteredArrayUsingPredicate: (NSPredicate *) predicate;

- (NSInteger)indexOfObject: (NSObject *)object;

- (BOOL)containsObject: (id)object;

- (NSArray *)toNSArray;

@end

// MARK: - _MutexArray

@interface _MutexArray : NSObject <NSCopying, NSMutableCopying>


#pragma mark - Init
+ (instancetype)array;
+ (instancetype)arrayWithCapacity:(NSUInteger)num;
+ (instancetype)arrayWithArray:(NSArray *)anArray;
+ (instancetype)arrayWithObject:(id)anObject;

#pragma mark - Add
- (void)addObject:(id)anObject;
- (void)addObjectsFromArray:(NSArray *)otherArray;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;

#pragma mark - Remove
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeLastObject;
/**
 Removes all occurrences in the array of a given object.
 */
- (void)removeObject:(id)anObject;
- (void)removeAllObjects;

#pragma mark - Replace
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
/**
 Replaces the object at the index with the new object, possibly adding the object.
 */
- (void)setObject:(id)anObject atIndexedSubscript:(NSUInteger)index;

#pragma mark - Query
- (NSUInteger)count;
/**
 Returns the lowest index whose corresponding array value is equal to a given object.
 */
- (NSUInteger)indexOfObject:(id)anObject;
- (nullable id)objectAtIndexedSubscript:(NSUInteger)index;
- (nullable id)objectAtIndex:(NSUInteger)index;
- (nullable id)firstObject;
- (nullable id)lastObject;

#pragma mark - Enumerate
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;

@end
