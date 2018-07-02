/**
 *  @knowledge
 
 *  服务
 */

/**
 *  @brief 在系统核心服务之上，进行包装
 
 *  1. service之间不允许依赖，如果依赖，则依赖方上至component
 */

#import "_Module.h"

@interface _Service : _Module

/**
 *  @brief 是否可用，1. 依赖系统服务，而用户没有打开 2. 依赖外部服务，而用户没有安装
 */
- (BOOL)available;

/**
 *  @brief 运行时，用户可以热开关
 */
- (void)powerOn;
- (void)powerOff;

@end

@namespace( service )
