// ----------------------------------
// Caution
// ----------------------------------

#if !__has_feature(objc_arc)
//#   error SUITE is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#ifdef __OBJC_GC__
#   error SUITE does not support Objective-C Garbage Collection
#endif

#if TARGET_OS_IPHONE
#ifndef __IPHONE_8_0
#   error SUITE is supported only on iOS 8 and above
#endif
#endif

#if TARGET_OS_OSX
#   error SUITE is supported only on Iphone OS
#endif

// ----------------------------------
// Unix include headers
// ----------------------------------

#import <stdio.h>
#import <stdlib.h>
#import <stdint.h>
#import <string.h>
#import <assert.h>
#import <errno.h>

#import <sys/errno.h>
#import <sys/sockio.h>
#import <sys/ioctl.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <sys/stat.h>
#import <sys/mman.h>

#import <math.h>
#import <unistd.h>
#import <limits.h>
#import <execinfo.h>

#import <netdb.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>

#import <mach/mach.h>
#import <mach/machine.h>
#import <machine/endian.h>
#import <malloc/malloc.h>

#import <sys/utsname.h>

#import <fcntl.h>
#import <dirent.h>
#import <dlfcn.h>
#import <spawn.h>

#import <mach-o/fat.h>
#import <mach-o/dyld.h>
#import <mach-o/arch.h>
#import <mach-o/nlist.h>
#import <mach-o/loader.h>
#import <mach-o/getsect.h>

#import <zlib.h>

#ifdef __IPHONE_8_0
#import <spawn.h>
#endif

// ----------------------------------
// Mac/iOS include headers
// ----------------------------------

#ifdef __OBJC__

#import <Availability.h>
#import <Foundation/Foundation.h>
#import <Foundation/NSObjCRuntime.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import <CoreText/CoreText.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <TargetConditionals.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreImage/CoreImage.h>
#import <CoreLocation/CoreLocation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <dlfcn.h>
#import <CommonCrypto/CommonDigest.h>

#endif	// #ifdef __OBJC__

#import "_Macros.h"
