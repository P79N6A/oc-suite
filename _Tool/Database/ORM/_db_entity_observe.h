
#import "_db_entity.h"

/**
 *  数据观察
 */

@interface _Entity ( Observe )

/**
 注册数据变化监听.
 @name 注册名称,此字符串唯一,不可重复,移除监听的时候使用此字符串移除.
 @return YES: 注册监听成功; NO: 注册监听失败.
 */
+ (BOOL)observeWithName:(NSString * const)name block:(DatabaseDealStateBlock)block;

/**
 移除数据变化监听.
 @name 注册监听的时候使用的名称.
 @return YES: 移除监听成功; NO: 移除监听失败.
 */
+ (BOOL)unobserveWithName:(NSString * const)name;

@end
