
//  ViewController -> ViewModel -> DataController
//  ViewController -> ViewModel -> Service

#import "_Foundation.h"


@class RACSignal;

/**
 *  fallenink:
 
 *  职责：
 *  1. 网络请求
 *  2. 数据服务（包括dataSource、dataSource的处理、变换）
 *  3. 数据服务，也包括，数据绑定）
 *  4. 数据处理，将领域模型，转接到UI
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

// 如果支持ReactiveObjc

/**
 * @brief 标识关联视图是否在最前，否则，可以取消低优先级、UI相关任务
 * @default NO
 */
@property (nonatomic, assign, getter = isActive) BOOL active;

/**
 * @brief 监测 'active'，from NO to YES
 * @manual 在 ViewController's viewDidAppear 更新 ‘active’，在ViewModel中监测，并更新数据
 */
@property (nonatomic, strong, readonly) RACSignal *didBecomeActiveSignal;

/**
 * @brief 监测 'active'，from YES to NO.
 * @manual 在 ViewController's viewDidDisappear 更新 ‘active’，在ViewModel中监测，并更新策略
 */
@property (nonatomic, strong, readonly) RACSignal *didBecomeInactiveSignal;

@end

#pragma mark -

@interface UIViewController ( ViewModel )

- (void)bind;

@end

