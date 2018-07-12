
#import <_Foundation/_Foundation.h>
#import "_AppInit.h"
#import "_AppUninit.h"
#import "_AppUser.h"

// ----------------------------------
// Macro
// ----------------------------------

#undef  app_context
#define app_context [_AppContext sharedInstance]

// ----------------------------------
// Class Definition
//
// TODO: 当前还不支持多context, 但context和user是一对一的
// ----------------------------------

@interface _AppContext : NSObject

@singleton( _AppContext )

@prop_singleton( _AppInit, initialize )
@prop_singleton( _AppUninit, uninitialize )

@prop_singleton( _AppUser, user )

// 重要的通知
@notification( LaunchedStateNofitication )
@notification( LoginedStateNotification )
@notification( LogoutedStateNotification )
@notification( CookieExpiredNotification )

/**
    服务功能
 
    1. 地址、城市信息
 **/
// 位置信息

@prop_assign( double, longitude ) // 经度
@prop_assign( double, latitude) // 纬度
// 市信息
@prop_assign( int64_t, cityId )
@prop_assign( int64_t, cityCode )
@prop_strong( NSString *, cityCodes )
@prop_strong( NSString *, cityName )
// 省信息
@prop_assign( int64_t, provinceId )
@prop_assign( int64_t, provinceCode )
@prop_strong( NSString *, provinceName )
// 区信息
@prop_assign( int64_t, areaId )
@prop_assign( int64_t, areaCode )
@prop_strong( NSString *, areaName )

/**
 *  @brief 异步检查地区是否改变，如果改变，changed为YES；用户如果选择切换地区，则返回YES，修改用户位置信息。
 *         因为，需要搜集用户反馈信息，所以这里不能用通知，需要控制链转移.
 
 *  当前界定为城市
 */
- (void)checkUserLocationIfChanged:(BOOL (^)(BOOL changed))locationChangedHandler;

@end
