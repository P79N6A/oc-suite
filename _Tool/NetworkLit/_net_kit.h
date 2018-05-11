
#import "_net_host.h"
#import "_net_request.h"
#import "_net_restful.h"

#ifdef __OBJC_GC__
#error Does not support Objective-C Garbage Collection
#endif

#if TARGET_OS_IPHONE
#ifndef __IPHONE_8_0
#error Supported only on iOS 8 and above
#endif
#endif

#if ! __has_feature(objc_arc)
#error ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif


