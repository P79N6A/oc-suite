
/**
 *  业务组件（Business component）
 
 *  1. 组件（component）
 *  2. 流程（process）
 */

/**
 *  @brief 包含业务逻辑的组件模块
 
 *  1.
 */

#import "_Module.h"

#pragma mark -

@protocol ManagedComponent <NSObject>
@end

#pragma mark -

@interface _Component : _Module

+ (instancetype)instance;

- (void)install;
- (void)uninstall;

@end
