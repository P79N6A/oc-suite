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

#ifndef _appdef_h
#define _appdef_h

// app 相关
#define app_build       [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]

#define app_version     [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define app_display_name    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] // CFBundleDisplayName 这些字符串，在用source code方式打开info.plist文件，可以看到类似的键值

#define app_bundle_name [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey] // 对应 info.plist 中 key 为 bundle name 的value，当前设置的是：$(PRODUCT_NAME)

#define app_bundle_id   [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey] // 对应 info.plist 中 key 为 bundle identifier 的value，当前设置的是：$(PRODUCT_BUNDLE_IDENTIFIER)

#define ISFirst [NSUserDefaults standardUserDefaults]

#endif /* _appdef_h */
