//
//  _db_entity_batch.m
//  student
//
//  Created by fallen.ink on 12/11/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "_db_entity_batch.h"

@implementation _Entity ( Batch )

@end

#pragma mark 直接存储数组.

@implementation NSArray ( DatabaseEntity )

/**
 存储数组.
 @name 唯一标识名称.
 **/
- (BOOL)saveArrayWithName:(nonnull NSString * const)name {
    if ([self isKindOfClass:[NSArray class]]) {
        __block BOOL result;
        [[_Database sharedInstance] saveArray:self name:name complete:^(BOOL isSuccess) {
            result = isSuccess;
        }];
        
        //关闭数据库
        [[_Database sharedInstance] closeDB];
        return result;
    } else {
        return NO;
    }
}

/**
 添加数组元素.
 @name 唯一标识名称.
 @object 要添加的元素.
 */
+ (BOOL)addObjectWithName:(nonnull NSString * const)name object:(nonnull id const)object{
    NSAssert(object,@"元素不能为空!");
    __block BOOL result;
    [[_Database sharedInstance] saveArray:@[object] name:name complete:^(BOOL isSuccess) {
        result = isSuccess;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}
/**
 获取数组元素数量.
 @name 唯一标识名称.
 */
+ (NSInteger)countWithName:(NSString* const _Nonnull)name{
    NSUInteger count = [[_Database sharedInstance] countForTable:name where:nil];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return count;
    
}
/**
 查询整个数组
 */
+ (NSArray *)arrayWithName:(NSString* const _Nonnull)name{
    __block NSMutableArray* results;
    [[_Database sharedInstance] queryArrayWithName:name complete:^(NSArray * _Nullable array) {
        if(array&&array.count){
            results = [NSMutableArray arrayWithArray:array];
        }
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return results;
}
/**
 获取数组某个位置的元素.
 @name 唯一标识名称.
 @index 数组元素位置.
 */
+ (id)objectWithName:(NSString * const)name index:(NSInteger)index {
    id resultValue = [[_Database sharedInstance] queryArrayWithName:name index:index];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return resultValue;
}
/**
 更新数组某个位置的元素.
 @name 唯一标识名称.
 @index 数组元素位置.
 */
+ (BOOL)updateObjectWithName:(NSString* const _Nonnull)name object:(id _Nonnull)object index:(NSInteger)index{
    BOOL result = [[_Database sharedInstance] updateObjectWithName:name object:object index:index];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}
/**
 删除数组的某个元素.
 @name 唯一标识名称.
 @index 数组元素位置.
 */
+ (BOOL)deleteObjectWithName:(NSString* const _Nonnull)name index:(NSInteger)index {
    BOOL result = [[_Database sharedInstance] deleteObjectWithName:name index:index];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}
/**
 清空数组元素.
 @name 唯一标识名称.
 */
+ (BOOL)clearArrayWithName:(NSString * const)name {
    __block BOOL result;
    [[_Database sharedInstance] dropSafeTable:name complete:^(BOOL isSuccess) {
        result = isSuccess;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}

@end

// ----------------------------------
// MARK: 直接存储字典.
// ----------------------------------

@implementation NSDictionary ( DatabaseEntity )
/**
 存储字典.
 */
- (BOOL)saveDictionary {
    if([self isKindOfClass:[NSDictionary class]]) {
        __block BOOL result;
        [[_Database sharedInstance] saveDictionary:self complete:^(BOOL isSuccess) {
            result = isSuccess;
        }];
        //关闭数据库
        [[_Database sharedInstance] closeDB];
        return result;
    } else {
        return NO;
    }
}

/**
 添加字典元素.
 */
+ (BOOL)setValue:(id const _Nonnull)value forKey:(NSString* const _Nonnull)key {
    BOOL result = [[_Database sharedInstance] bg_setValue:value forKey:key];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}
/**
 更新字典元素.
 */
+ (BOOL)updateValue:(id const)value forKey:(NSString * const)key {
    BOOL result = [[_Database sharedInstance] bg_updateValue:value forKey:key];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}
/**
 遍历字典元素.
 */
+ (void)enumerateKeysAndObjectsUsingBlock:(void (^)(NSString * key, id value,BOOL *stop))block {
    [[_Database sharedInstance] bg_enumerateKeysAndObjectsUsingBlock:block];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
}
/**
 获取字典元素.
 */
+ (id)valueForKey:(NSString *const)key {
    id value = [[_Database sharedInstance] bg_valueForKey:key];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return value;
}
/**
 移除字典某个元素.
 */
+ (BOOL)removeValueForKey:(NSString * const)key {
    BOOL result = [[_Database sharedInstance] bg_deleteValueForKey:key];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}
/**
 清空字典.
 */
+ (BOOL)clearDictionary {
    __block BOOL result;
    NSString* const tableName = @"BG_Dictionary";
    [[_Database sharedInstance] dropSafeTable:tableName complete:^(BOOL isSuccess) {
        result = isSuccess;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}

@end
