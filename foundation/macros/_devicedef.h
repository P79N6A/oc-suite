//
//     ____              _____    _____    _____
//    / ___\   /\ /\     \_   \   \_  _\  /\  __\
//    \ \     / / \ \     / /\/    / /    \ \  _\_
//  /\_\ \    \ \_/ /  /\/ /_     / /      \ \____\
//  \____/     \___/   \____/    /__|       \/____/
//
//	Copyright BinaryArtists development team and other contributors
//
//	https://github.com/BinaryArtists/suite.great
//
//	Free to use, prefer to discuss!
//
//  Welcome!
//

#ifndef _devicedef_h
#define _devicedef_h

// 设备相关
#define device_name             [[UIDevice currentDevice] name]
#define device_model            [[UIDevice currentDevice] model]
#define device_system_version    [[UIDevice currentDevice] systemVersion]

// 根据屏幕旋转方法获得当前屏幕宽度
#define UIScreenCurrentWidth (UIWindowIsLandscape ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width)
// 根据屏幕旋转方法获得当前屏幕高度
#define UIScreenCurrentHeight (UIWindowIsLandscape ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)
// 根据屏幕旋转方法获得当前屏幕大小
#define UIScreenCurrentSize CGSizeMake(UIScreenCurrentWidth, UIScreenCurrentHeight)

// 判断屏幕是否横屏
#define UIWindowIsLandscape UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)

// 判断屏幕是否竖屏
#define UIWindowIsPortrait !UIWindowIsLandscape

#define UIApplicationWindow [[UIApplication sharedApplication].delegate window]

// 横竖屏
#define is_landscape ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight)

#endif /* _devicedef_h */
