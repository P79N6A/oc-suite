
#import <_Foundation/_Foundation.h>
#import "_AppRater.h"

// ----------------------------------
// Macro
// ----------------------------------

#undef  app_config
#define app_config          [_AppConfig sharedInstance]

#define app_platform_name   [AppConfig sharedInstance].platformName
#define app_name            [AppConfig sharedInstance].appName
#define app_identifier      [AppConfig sharedInstance].appIdentifier
#define app_description     [AppConfig sharedInstance].appDescription
#define app_version_serial  [AppConfig sharedInstance].appVersionSerial

#define app_udid            [[_SystemInfo sharedInstance] deviceUDID]

// ----------------------------------
// Pre Declaration
// ----------------------------------

@protocol APNServiceDelegate;

// ----------------------------------
// Class Definition
// ----------------------------------

@interface _AppConfig : NSObject

@singleton( _AppConfig )

// 广告配置
@prop_assign(BOOL, enabledLaunchAdvertise) // 启动广告，默认：NO
@prop_assign(CGFloat, launchAdvertiseDuration)

// 地图-高德SDK配置，没有配置，默认关闭
@prop_strong(NSString *, mapApiKey)

// 分享-微信配置
@prop_strong(NSString *, wechatAppId)
@prop_strong(NSString *, wechatScheme)

// 评分配置
@prop_singleton(_AppRater, rater)

// 推送配置
@prop_strong(NSString *, pushKey)
@prop_strong(NSString *, pushChannel) // 需要监听的频道
@prop_strong(id<APNServiceDelegate>, pushDelegate)

// 应用配置
@prop_strong(NSString *, platformName)
@prop_strong(NSString *, appName) // app display name , as it display at front screen~
@prop_strong(NSString *, appIdentifier)
@prop_readonly(NSString *, appDescription)

@prop_assign(int32_t , appVersionSerial) // 用于版本比对的整形数字, 存放在info.plist中，key is :CFApplicationVersionSerial
@prop_strong(NSString *, appVersion) // 版本格式：主版本号.次版本号.修订号，版本号规则如下（面向SDK、应用开发）：1. 主版本号（不兼容的API修改、重要模块功能新增）2. 次版本号（向下兼容的功能新增、个别模块功能扩容） 3. 修订号（向下兼容的问题修正、个别模块功能bug修复）

@end
