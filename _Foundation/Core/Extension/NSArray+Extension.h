
#import "_Precompile.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark -

typedef NSMutableArray * 	(^NSArrayElementBlock)(id obj );
typedef NSComparisonResult	(^NSArrayCompareBlock)(id left, id right );

#pragma mark -

@interface NSArray(Extension)

- (NSMutableArray *)head:(NSUInteger)count;
- (NSMutableArray *)tail:(NSUInteger)count;

- (NSString *)join;
- (NSString *)join:(NSString *)delimiter;

/**
 *  辅助方法
 */

// 鉴于containsObject:是比较对象：调用isEqual:，该方法比较的是hash值，所以添加如下方法
- (BOOL)containsString:(NSString *)aString;

- (NSArray *)filteredArrayWhereProperty:(NSString *)property equals:(id)value;

@end

#pragma mark -

@interface __GENERICS(NSArray, ObjectType) ( Function )

/**
 *  遍历
 */
- (void)each:(void (^)(ObjectType obj))block;

- (void)apply:(void (^)(ObjectType obj))block;

/**
 *  匹配
 */
- (id)match: (BOOL (^)(ObjectType obj))block;

/**
 *  筛选
 */
- (NSArray *)select: (BOOL (^)(ObjectType obj))block;

- (NSArray *)reject:(BOOL (^)(ObjectType obj))block;

/**
 *  映射
 */
- (NSArray *)map: (id (^)(ObjectType obj))block;

- (NSArray *)compact:(id (^)(ObjectType obj))block;

/**
 *  化简
 *
 *  @param initial 初始值
 *  @param block handler of client's operation
 *
 *  @return result
 */
- (id)reduce:(nullable id)initial withBlock:(__nullable id (^)(__nullable id sum, ObjectType obj))block;
- (NSInteger)reduceInteger:(NSInteger)initial withBlock:(NSInteger(^)(NSInteger result, ObjectType obj))block;
- (CGFloat)reduceFloat:(CGFloat)inital withBlock:(CGFloat(^)(CGFloat result, ObjectType obj))block;

- (BOOL)any:(BOOL (^)(ObjectType obj))block;

/** Loops through an array to find whether no objects match the block.
 */
- (BOOL)none:(BOOL (^)(ObjectType obj))block;

/** Loops through an array to find whether all objects match the block.
 
 @param block A single-argument, BOOL-returning code block.
 @return YES if the block returns YES for all objects in the array, NO otherwise.
 */
- (BOOL)all:(BOOL (^)(ObjectType obj))block;

/** Tests whether every element of this array relates to the corresponding element of another array according to match by block.
 */
- (BOOL)corresponds:(NSArray *)list withBlock:(BOOL (^)(ObjectType obj1, id obj2))block;

@end

// inspired by https://github.com/nbasham/iOS-Collection-Utilities/blob/master/Classes/NSArray%2BPrimitive.h

/**
 *  Usage
 
 NSMutableArray* array = [NSMutableArray array];
 [array addInt:1]; // array = [1]
 [array addInt:2]; // array = [1, 2]
 int i = [array intAtIndex:0]; // i = 1
 [array swapIndex1:0 index2:1]; // array = [2, 1]
 [array replaceIntAtIndex:0 withInt:3];  // array = [3, 1]
 [array insertInt:4 atIndex:1];
 NSLog(@"%@", [array description]); // console shows [3, 4, 1]
 
 */

@interface NSArray ( Primitive )

- (BOOL)boolAtIndex:(NSUInteger)index;
- (char)charAtIndex:(NSUInteger)index;
- (int)intAtIndex:(NSUInteger)index;
- (float)floatAtIndex:(NSUInteger)index;
- (NSString*)intArrayToString;
- (NSValue*)valueAtIndex:(NSUInteger)index;
- (CGPoint)pointAtIndex:(NSUInteger)index;
- (CGSize)sizeAtIndex:(NSUInteger)index;
- (CGRect)rectAtIndex:(NSUInteger)index;
- (NSInteger)integerAtIndex:(NSUInteger)index;
- (NSUInteger)unsignedIntegerAtIndex:(NSUInteger)index;
- (CGFloat)cgFloatAtIndex:(NSUInteger)index;

@end

@interface NSMutableArray ( Primitive )

- (void)swapIndex1:(NSUInteger)index1 index2:(NSUInteger)index2;

- (void)addBool:(BOOL)b;
- (void)insertBool:(BOOL)b atIndex:(NSUInteger)index;
- (void)replaceBoolAtIndex:(NSUInteger)index withBool:(BOOL)b;

- (void)addChar:(char)c;
- (void)insertChar:(char)c atIndex:(NSUInteger)index;
- (void)replaceCharAtIndex:(NSUInteger)index withChar:(char)c;

- (void)addInt:(int)i;
- (void)insertInt:(int)i atIndex:(NSUInteger)index;
- (void)replaceIntAtIndex:(NSUInteger)index withInt:(int)i;

- (void)addInteger:(NSInteger)i;
- (void)insertInteger:(NSInteger)i atIndex:(NSUInteger)index;
- (void)replaceIntegerAtIndex:(NSUInteger)index withInteger:(NSInteger)i;

- (void)addUnsignedInteger:(NSInteger)i;
- (void)insertUnsignedInteger:(NSInteger)i atIndex:(NSUInteger)index;
- (void)replaceUnsignedIntegerAtIndex:(NSUInteger)index withUnsignedInteger:(NSInteger)i;

- (void)addCGFloat:(CGFloat)f;
- (void)insertCGFloat:(CGFloat)f atIndex:(NSUInteger)index;
- (void)replaceCGFloatAtIndex:(NSUInteger)index withCGFloat:(CGFloat)f;

- (void)addFloat:(float)f;
- (void)insertFloat:(float)f atIndex:(NSUInteger)index;
- (void)replaceFloatAtIndex:(NSUInteger)index withFloat:(float)f;

- (void)addValue:(NSValue*)o;
- (void)insertValue:(NSValue*)o atIndex:(NSUInteger)index;
- (void)replaceValueAtIndex:(NSUInteger)index withValue:(NSValue*)o;

- (void)addPoint:(CGPoint)o;
- (void)insertPoint:(CGPoint)o atIndex:(NSUInteger)index;
- (void)replacePointAtIndex:(NSUInteger)index withPoint:(CGPoint)o;

- (void)addSize:(CGSize)o;
- (void)insertSize:(CGSize)o atIndex:(NSUInteger)index;
- (void)replaceSizeAtIndex:(NSUInteger)index withSize:(CGSize)o;

- (void)addRect:(CGRect)o;
- (void)insertRect:(CGRect)o atIndex:(NSUInteger)index;
- (void)replaceRectAtIndex:(NSUInteger)index withRect:(CGRect)o;

@end

NS_ASSUME_NONNULL_END
