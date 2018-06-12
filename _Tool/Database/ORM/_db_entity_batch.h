//
//  _db_entity_batch.h
//  student
//
//  Created by fallen.ink on 12/11/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "_db_entity.h"

@interface _Entity ( Batch )

@end

// ----------------------------------
// MARK: 直接存储数组.
// ----------------------------------

@interface NSArray ( DatabaseEntity )

/**
 存储数组.
 @name 唯一标识名称.
 **/
- (BOOL)saveArrayWithName:(NSString * const)name;

/**
 添加数组元素.
 @name 唯一标识名称.
 @object 要添加的元素.
 */
+ (BOOL)addObjectWithName:(NSString * const)name object:(id const)object;

/**
 获取数组元素数量.
 @name 唯一标识名称.
 */
+ (NSInteger)countWithName:(NSString * const)name;

/**
 查询整个数组
 */
+ (NSArray *)arrayWithName:(NSString * const)name;

/**
 获取数组某个位置的元素.
 @name 唯一标识名称.
 @index 数组元素位置.
 */
+ (id)objectWithName:(NSString * const)name index:(NSInteger)index;

/**
 更新数组某个位置的元素.
 @name 唯一标识名称.
 @index 数组元素位置.
 */
+ (BOOL)updateObjectWithName:(NSString * const)name object:(id)object index:(NSInteger)index;

/**
 删除数组的某个元素.
 @name 唯一标识名称.
 @index 数组元素位置.
 */
+ (BOOL)deleteObjectWithName:(NSString * const)name index:(NSInteger)index;

/**
 清空数组元素.
 @name 唯一标识名称.
 */
+ (BOOL)clearArrayWithName:(NSString * const)name;

@end

// ----------------------------------
// MARK: 直接存储字典.
// ----------------------------------

@interface NSDictionary ( DatabaseEntity )

/**
 存储字典.
 */
- (BOOL)saveDictionary;

/**
 添加字典元素.
 */
+ (BOOL)setValue:(id const)value forKey:(NSString * const)key;

/**
 更新字典元素.
 */
+ (BOOL)updateValue:(id const)value forKey:(NSString * const)key;

/**
 获取字典元素.
 */
+ (id)valueForKey:(NSString * const)key;

/**
 遍历字典元素.
 */
+ (void)enumerateKeysAndObjectsUsingBlock:(void (^)(NSString * key, id value,BOOL *  stop))block;

/**
 移除字典某个元素.
 */
+ (BOOL)removeValueForKey:(NSString * const)key;

/**
 清空字典.
 */
+ (BOOL)clearDictionary;

@end
