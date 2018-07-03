//
//  _application.h
//  kata
//
//  Created by fallen.ink on 22/02/2017.
//  Copyright © 2017 fallenink. All rights reserved.
//

#import "_precompile.h"
#import "_greats.h"

/**
 *  @knowledge
 *  [AppDelegate中常用的代理方法回调的时机](http://www.jianshu.com/p/a8c2f6b8a4ad)
 */

/**
 *  继承 _Application，这里传达的是，将应用必要功能、事件，用中介者、代理模式包装一下，于是有：
 *  1. 应用主体         _application
 *  2. 应用外观         _app_appearance
 *  3. 应用配置         _app_config
 *  4. 应用上下文        _app_context
 *  5. 应用上下文管理器     _app_context_manager
 *  6. 应用 简易封装      _app_easycoding
 *  7. 应用初始化器       _app_init
 *  8. 应用反初始化器      _app_uinit
 *  9. 应用模块器        _app_module
 *  10. 应用评分        _app_versioner
 *  11. 应用规则        即将废弃
 *  11. 应用 用户       _app_user
 *
 *  简单例子：
 *  1. AppDelegate 实现了 app_uinitializer 的 delegate
 *  2. 当用户点击了'登出', 调用 app_uinitializer.logout,
 *  3. app_uinitializer 通知代理，调用 onLogout
 *  4. AppDelegate 中进行 数据的清理、视图的切换
 *
 *  这样的好处是：让应用的骨架结构紧凑，否则会比较松散，一旦松散，业务流程越复杂，代码逻辑就会越凌乱。
 */

// ----------------------------------
// Cluster code
// ----------------------------------

#import "_app_context.h"
#import "_app_module.h"
#import "_app_rule.h"
#import "_app_appearance.h"
#import "_app_config.h"

// ----------------------------------
// Macro
// ----------------------------------

#undef  app_inst
#define app_inst ((_Application *)[UIApplication sharedApplication].delegate)

// ----------------------------------
// Protocol code
// ----------------------------------

@protocol ApplicationLifeStyleProtocol <NSObject> // 应用生命周期，不要这里做UI的事情，业务UI请关注ApplicationRuntimePeriodProtocol

- (void)willLaunch; // 程序即将加载

- (void)didLaunch; // 程序加载完毕

- (void)willTerminate; // 程序即将终止

- (void)didBecomeActive; // 程序获取焦点

- (void)willEnterForeground; // 程序即将从后台，回到前台

- (void)didEnterBackground; // 程序即将从前台，退到后台

- (void)willResignActive; // 程序即将失去焦点

@end

@protocol ApplicationNofiticationProtocol <NSObject> // 应用推送回调（外部不关心api版本问题）

- (void)onReceiveNotificationAtLaunching:(id)notification; // 从关闭到启动

- (void)onReceiveNotificationAtActivating:(id)notification;// 从后台到启动

- (void)onReceiveNotificationAtRunning:(id)notification; // 在前台收到通知

@end

@protocol ApplicationExternalEventProtocol <NSObject> // 应用外部事件回调

- (void)onLaunchByOpeningUrl:(NSURL *)url;

- (void)onSignificantTimeChanged; // 当系统时间发生改变时

- (void)onMemoryOverflow; // 内存要溢出了

@end

@protocol ApplicationRuntimePeriodProtocol <NSObject> // 非必要的业务流程回调

- (void)onConfig:(_AppConfig *)appConfig; // 配置：不可以做时间过长的任务

- (UIViewController *)forLaunchViewController; // 返回等效的启动画面

/**
 *  Usage
 *
 *  @brief 
 *      1. 该方法在启动时执行，会block在启动页面
 *      2. 用于启动时候同步数据
 *      3. 如果网络数据回来了，则调用[super onSynchronize]，通知回来，继续当前线程
 */
- (void)onSynchronize; // 同步基本数据信息，信息获取OK后，需要调用父类方法

- (void)onLaunch;

- (void)onCleanup; // 应用终止的时候，做必要的清理

/**
 *  @desc
 *
 *  @param url  略
 *  @param options 略
 */
- (BOOL)onOpenUrl:(NSURL *)url options:(NSDictionary<NSString*, id> *)options;

/**
 * @param adSettingHandler 需要通过网络请求等，设置新的广告数据，当前只需要提供image信息，跳转信息自行处理
 *
 * @return Block 需要返回点击事件处理句柄，注意：该句柄会在onLaunch后面调用
 */
- (Block)onAdvertise:(StringBlock)adSettingHandler;

@end

// ----------------------------------
// Class code
//
// 参考的SamuraiApp
// ----------------------------------

@interface _Application : UIResponder <
    UIApplicationDelegate,
    ApplicationLifeStyleProtocol,
    ApplicationRuntimePeriodProtocol,
    ApplicationExternalEventProtocol,
    ApplicationNofiticationProtocol
>

@notification( PushEnabled )
@notification( PushError )

@notification( LocalNotification )
@notification( RemoteNotification )

@notification( EnterBackground )
@notification( EnterForeground )
@notification( Ready )

@prop_strong( UIWindow *,			window )
@prop_strong( NSString *,			pushToken )
@prop_strong( NSError *,			pushError )
@prop_strong( NSString *,			sourceUrl )
@prop_strong( NSString *,			sourceBundleId )

@prop_readonly( BOOL,				active )
@prop_readonly( BOOL,				inactive )
@prop_readonly( BOOL,				background )

// If u wanna using block replaced notification
@prop_strong( Block,			whenEnterBackground )
@prop_strong( Block,			whenEnterForeground )

@prop_singleton( _AppConfig,        config )
@prop_singleton( _AppModule,        module )
@prop_singleton( _AppContext,       context )

- (void)quit;

@end
