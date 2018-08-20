//
//  ALSAppContextProtocol.h
//  wesg
//
//  Created by 7 on 27/12/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>

// -------------------------------------------
// Notification Definition
// -------------------------------------------

#define kNotificationAppContextLaunch   @"NotificationAppContextLaunch" // 应用加载完毕

#define kNotificationAppContextReady    @"NotificationAppContextReady" // 应用主功能加载完毕

// -------------------------------------------
// Class Definition
// -------------------------------------------

@protocol _AppContextProtocol <NSObject>

// 事件埋点

- (void)launch;
- (void)ready;

@end
