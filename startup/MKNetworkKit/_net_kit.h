
#import "MKNetworkHost.h"
#import "MKNetworkRequest.h"
#import "MKObject.h"

#ifdef __OBJC_GC__
#error Does not support Objective-C Garbage Collection
#endif

#if TARGET_OS_IPHONE
#ifndef __IPHONE_8_0
#error Supported only on iOS 8 and above
#endif
#endif

#if TARGET_OS_MAC
#ifndef __MAC_10_10
#error Supported only on Mac OS X Yosemite and above
#endif
#endif

#if ! __has_feature(objc_arc)
#error ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#ifdef DEBUG
#define DLog(fmt, ...) {NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
#else
#define DLog(...)
#endif

