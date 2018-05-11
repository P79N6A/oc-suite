//
//  MJGImageLoader.h
//  MJGFoundation
//
//  Created by Matt Galloway on 18/01/2012.
//  Copyright 2012 Matt Galloway. All rights reserved.
//

//  如果下面不工作，那么再去看一下：http://stackoverflow.com/questions/4676000/is-there-a-way-for-xcode-to-warn-about-new-api-calls

/**
 http://www.jianshu.com/p/4929953420f2
 
 检查API可用性的工具
 
 比较好的方案是用MJGAvailability.h在编译期检查。
 把MJGAvailability.h文件加入工程中，在预编译头文件最开头加上下面的代码即可:
 
 #define __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED __IPHONE_7_0
 #import "MJGAvailability.h"
 其中的__IPHONE_7_0定义在Availability.h文件中，可以改成需要的任何系统版本。
 配置完成后，调用不可用的API会出现如下形式的警告：
 
 xxxxxxx.m:64:18: 'containsString:' is deprecated: TOO NEW!
 如果配置后编译没有生效，把Build Settings里面的Enable Modules (C and Objective-C)项改为NO试试，具体原因我还不知道是为什么。
 
 project 和 target 中都要设置
 
 这个工具无法检查出我们的代码有没有进行过版本兼容处理，它会对所有有问题的代码报错。所以我们要在处理过兼容性的地方，显式的用宏把代码包起来：
 
 MJG_START_IGNORE_TOO_NEW
 if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
 [cell setPreservesSuperviewLayoutMargins:NO];
 }
 if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
 [cell setLayoutMargins:UIEdgeInsetsZero];
 }
 MJG_END_IGNORE_TOO_NEW
 另外有一个叫做Faux Pas的代码静态分析工具，可以进行API可用性的检查，但因为它的试用版随机隐藏了检查结果，所以就没再研究了。
 */

/**
 * Example usage:
 *   If you want to see if you're using methods that are only defined in iOS 4.0 and lower 
 *   then you would use the following. Replace the __IPHONE_4_0 with whatever other macro 
 *   you require. See Availability.h for iOS versions these relate to.
 * 
 * YourProjectPrefixHeader.pch:
 *   #define __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED __IPHONE_4_0
 *   #import "MJGAvailability.h"
 *   
 *   // The rest of your prefix header as normal
 *   #import <UIKit/UIKit.h>
 * 
 * For OSX, you also get the warnings:
 * 
 * YourOSXPrefixHeader.pch
 *   #define __MAC_OS_X_VERSION_SOFT_MAX_REQUIRED __MAC_10_7
 *   #import "MJGAvailability.h"
 *
 * If you want to suppress a single warning (i.e. because you know that what you're doing is 
 * actually OK) then you can do something like this:
 *
 *   UINavigationBar *navBar = self.navigationController.navigationBar;
 *   if ([navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
 *   #pragma clang diagnostic push
 *   #pragma clang diagnostic ignored "-Wdeprecated-declarations"
 *       [navBar setBackgroundImage:[UIImage imageNamed:@"navbar_bg.png"] forBarMetrics:UIBarMetricsDefault];
 *   #pragma clang diagnostic pop
 *   }
 *
 * Or you can use the handy macros defined in this file also, like this:
 *
 *   UINavigationBar *navBar = self.navigationController.navigationBar;
 *   if ([navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
 *   MJG_START_IGNORE_TOO_NEW
 *       [navBar setBackgroundImage:[UIImage imageNamed:@"navbar_bg.png"] forBarMetrics:UIBarMetricsDefault];
 *   MJG_END_IGNORE_TOO_NEW
 *   }
 *
 */

#import <Availability.h>

#define MJG_START_IGNORE_TOO_NEW _Pragma("clang diagnostic push") _Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")
#define MJG_END_IGNORE_TOO_NEW _Pragma("clang diagnostic pop")

#define __AVAILABILITY_TOO_NEW __attribute__((deprecated("TOO NEW!"))) __attribute__((weak_import))

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)

#ifndef __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED
#define __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED __IPHONE_OS_VERSION_MIN_REQUIRED
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_OS_VERSION_MIN_REQUIRED
    #error You cannot ask for a soft max version which is less than the deployment target
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_2_0
    #undef __AVAILABILITY_INTERNAL__IPHONE_2_0
    #define __AVAILABILITY_INTERNAL__IPHONE_2_0 __AVAILABILITY_TOO_NEW
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_2_1
    #undef __AVAILABILITY_INTERNAL__IPHONE_2_1
    #define __AVAILABILITY_INTERNAL__IPHONE_2_1 __AVAILABILITY_TOO_NEW
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_2_2
    #undef __AVAILABILITY_INTERNAL__IPHONE_2_2
    #define __AVAILABILITY_INTERNAL__IPHONE_2_2 __AVAILABILITY_TOO_NEW
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_3_0
    #undef __AVAILABILITY_INTERNAL__IPHONE_3_0
    #define __AVAILABILITY_INTERNAL__IPHONE_3_0 __AVAILABILITY_TOO_NEW
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_3_1
    #undef __AVAILABILITY_INTERNAL__IPHONE_3_1
    #define __AVAILABILITY_INTERNAL__IPHONE_3_1 __AVAILABILITY_TOO_NEW
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_3_2
    #undef __AVAILABILITY_INTERNAL__IPHONE_3_2
    #define __AVAILABILITY_INTERNAL__IPHONE_3_2 __AVAILABILITY_TOO_NEW
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_4_0
    #undef __AVAILABILITY_INTERNAL__IPHONE_4_0
    #define __AVAILABILITY_INTERNAL__IPHONE_4_0 __AVAILABILITY_TOO_NEW
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_4_1
    #undef __AVAILABILITY_INTERNAL__IPHONE_4_1
    #define __AVAILABILITY_INTERNAL__IPHONE_4_1 __AVAILABILITY_TOO_NEW
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_4_2
    #undef __AVAILABILITY_INTERNAL__IPHONE_4_2
    #define __AVAILABILITY_INTERNAL__IPHONE_4_2 __AVAILABILITY_TOO_NEW
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_4_3
    #undef __AVAILABILITY_INTERNAL__IPHONE_4_3
    #define __AVAILABILITY_INTERNAL__IPHONE_4_3 __AVAILABILITY_TOO_NEW
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_5_0
    #undef __AVAILABILITY_INTERNAL__IPHONE_5_0
    #define __AVAILABILITY_INTERNAL__IPHONE_5_0 __AVAILABILITY_TOO_NEW
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_5_1
    #undef __AVAILABILITY_INTERNAL__IPHONE_5_1
    #define __AVAILABILITY_INTERNAL__IPHONE_5_1 __AVAILABILITY_TOO_NEW
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_6_0
    #undef __AVAILABILITY_INTERNAL__IPHONE_6_0
    #define __AVAILABILITY_INTERNAL__IPHONE_6_0 __AVAILABILITY_TOO_NEW
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_6_1
    #undef __AVAILABILITY_INTERNAL__IPHONE_6_1
    #define __AVAILABILITY_INTERNAL__IPHONE_6_1 __AVAILABILITY_TOO_NEW
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_7_0
    #undef __AVAILABILITY_INTERNAL__IPHONE_7_0
    #define __AVAILABILITY_INTERNAL__IPHONE_7_0 __AVAILABILITY_TOO_NEW
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_7_1
    #undef __AVAILABILITY_INTERNAL__IPHONE_7_1
    #define __AVAILABILITY_INTERNAL__IPHONE_7_1 __AVAILABILITY_TOO_NEW
#endif

#if __IPHONE_OS_VERSION_SOFT_MAX_REQUIRED < __IPHONE_8_0
    #undef __AVAILABILITY_INTERNAL__IPHONE_8_0
    #define __AVAILABILITY_INTERNAL__IPHONE_8_0 __AVAILABILITY_TOO_NEW
#endif

#endif // end of #if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)

#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED)

#ifndef __MAC_OS_X_VERSION_SOFT_MAX_REQUIRED
#define __MAC_OS_X_VERSION_SOFT_MAX_REQUIRED __MAC_OS_X_VERSION_MIN_REQUIRED
#endif

#if __MAC_OS_X_VERSION_SOFT_MAX_REQUIRED < __MAC_OS_X_VERSION_MIN_REQUIRED
#error You cannot ask for a soft max version which is less than the deployment target
#endif

#if __MAC_OS_X_VERSION_SOFT_MAX_REQUIRED < __MAC_10_0
#undef __AVAILABILITY_INTERNAL__MAC_10_0
#define __AVAILABILITY_INTERNAL__MAC_10_0 __AVAILABILITY_TOO_NEW
#endif

#if __MAC_OS_X_VERSION_SOFT_MAX_REQUIRED < __MAC_10_1
#undef __AVAILABILITY_INTERNAL__MAC_10_1
#define __AVAILABILITY_INTERNAL__MAC_10_1 __AVAILABILITY_TOO_NEW
#endif

#if __MAC_OS_X_VERSION_SOFT_MAX_REQUIRED < __MAC_10_2
#undef __AVAILABILITY_INTERNAL__MAC_10_2
#define __AVAILABILITY_INTERNAL__MAC_10_2 __AVAILABILITY_TOO_NEW
#endif

#if __MAC_OS_X_VERSION_SOFT_MAX_REQUIRED < __MAC_10_3
#undef __AVAILABILITY_INTERNAL__MAC_10_3
#define __AVAILABILITY_INTERNAL__MAC_10_3 __AVAILABILITY_TOO_NEW
#endif

#if __MAC_OS_X_VERSION_SOFT_MAX_REQUIRED < __MAC_10_4
#undef __AVAILABILITY_INTERNAL__MAC_10_4
#define __AVAILABILITY_INTERNAL__MAC_10_4 __AVAILABILITY_TOO_NEW
#endif

#if __MAC_OS_X_VERSION_SOFT_MAX_REQUIRED < __MAC_10_5
#undef __AVAILABILITY_INTERNAL__MAC_10_5
#define __AVAILABILITY_INTERNAL__MAC_10_5 __AVAILABILITY_TOO_NEW
#endif

#if __MAC_OS_X_VERSION_SOFT_MAX_REQUIRED < __MAC_10_6
#undef __AVAILABILITY_INTERNAL__MAC_10_6
#define __AVAILABILITY_INTERNAL__MAC_10_6 __AVAILABILITY_TOO_NEW
#endif

#if __MAC_OS_X_VERSION_SOFT_MAX_REQUIRED < __MAC_10_7
#undef __AVAILABILITY_INTERNAL__MAC_10_7
#define __AVAILABILITY_INTERNAL__MAC_10_7 __AVAILABILITY_TOO_NEW
#endif

#if __MAC_OS_X_VERSION_SOFT_MAX_REQUIRED < __MAC_10_8
#undef __AVAILABILITY_INTERNAL__MAC_10_8
#define __AVAILABILITY_INTERNAL__MAC_10_8 __AVAILABILITY_TOO_NEW
#endif

#if __MAC_OS_X_VERSION_SOFT_MAX_REQUIRED < __MAC_10_9
#undef __AVAILABILITY_INTERNAL__MAC_10_9
#define __AVAILABILITY_INTERNAL__MAC_10_9 __AVAILABILITY_TOO_NEW
#endif

#endif // end of #if defined(__MAC_OS_X_VERSION_MIN_REQUIRED)

#if (defined(__IPHONE_7_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0) || (defined(__MAC_10_9) &&  __MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_10_9)
#include <CoreFoundation/CFAvailability.h>
#undef CF_AVAILABLE
#define CF_AVAILABLE(_mac, _ios) __OSX_AVAILABLE_STARTING(__MAC_##_mac, __IPHONE_##_ios)
#undef CF_AVAILABLE_MAC
#define CF_AVAILABLE_MAC(_mac) __OSX_AVAILABLE_STARTING(__MAC_##_mac, __IPHONE_NA)
#undef CF_AVAILABLE_IOS
#define CF_AVAILABLE_IOS(_ios) __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_##_ios)
#endif // if iOS SDK >= 7.0 || OSX SDK >= 10.9

