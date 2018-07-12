
//  ViewController -> ViewModel -> DataController
//  ViewController -> ViewModel -> Service

#import "_Foundation.h"

/**
 *  fallenink:
 
 *  职责：
 *  1. 网络请求
 *  2. 数据服务（包括dataSource、dataSource的处理、变换）
 *  3. 数据服务，也包括，数据绑定）
 */

@interface BaseViewModel : NSObject

- (instancetype)initWithParams:(NSDictionary *)params;

/**
 *  Initialize self with cache.
 
 *  No limit for cache strategy.
 */
- (void)recover; // Load data from cache

#pragma mark -

/**
 *  刷新视图模型
 */
- (void)setdown:(id)data;

/**
 *  数据初始化
 */
- (void)setup;

@end

#pragma mark -

@interface UIViewController ( ViewModel )

- (void)bind;

@end

