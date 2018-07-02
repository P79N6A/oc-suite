//
//  _app_context.m
//  kata
//
//  Created by fallen on 17/3/10.
//  Copyright © 2017年 fallenink. All rights reserved.
//

#import "_app_context.h"
#import "_building_precompile.h"
#import "_building_service.h"
#import "_building_component.h"

@implementation _AppContext

@def_singleton( _AppContext )

@def_prop_singleton( _AppInit, initialize )
@def_prop_singleton( _AppUninit, uninitialize )

@def_prop_singleton( _AppUser, user )

@def_notification_alias( LaunchedStateNofitication , UIApplicationDidFinishLaunchingNotification )
@def_notification( LoginedStateNotification )
@def_notification( LogoutedStateNotification )
@def_notification( CookieExpiredNotification )

@def_prop_assign( double, longitude )
@def_prop_assign( double, latitude)

@def_prop_assign( int64_t, cityId )
@def_prop_assign( int64_t, cityCode )
@def_prop_strong( NSString *, cityCodes )
@def_prop_strong( NSString *, cityName )

@def_prop_assign( int64_t, provinceId )
@def_prop_assign( int64_t, provinceCode )
@def_prop_strong( NSString *, provinceName )

@def_prop_assign( int64_t, areaId )
@def_prop_assign( int64_t, areaCode )
@def_prop_strong( NSString *, areaName )

- (void)checkUserLocationIfChanged:(BOOL (^)(BOOL))locationChangedHandler {
//    TODO("我想让一个 item，可以cache，?可以database，可以json序列化")
    
    [service.location currentLocationWithBlock:^(LocationModel *location) {
        // 判断城市是否改变
        BOOL cityChanged = NO;
        
        
        BOOL userDecideChanged = locationChangedHandler(cityChanged);
        
        if (userDecideChanged) {
            
        } else {
            
        }
        
    }];
}

@end
