//
//  ALSportsMacro.h
//  Pay-inner
//
//  Created by 7 on 27/12/2017.
//  Copyright © 2017 yangzm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#ifndef singleton
#define singleton( __class ) \
        property (nonatomic, readonly) __class * sharedInstance; \
        - (__class *)sharedInstance; \
        + (__class *)sharedInstance;
#endif

#ifndef def_singleton
#define def_singleton( __class ) \
        dynamic sharedInstance; \
        - (__class *)sharedInstance \
        { \
            return [__class sharedInstance]; \
        } \
        + (__class *)sharedInstance \
        { \
            static dispatch_once_t once; \
            static __strong id __singleton__ = nil; \
            dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
            return __singleton__; \
        }
#endif

#ifndef weakify
#define weakify( x ) \
        autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x;
#endif

#ifndef strongify
#define strongify( x ) \
        try{} @finally{} __typeof__(x) x = __weak_##x##__;
#endif

#ifndef on_main
#define on_main( void_block )     dispatch_async(dispatch_get_main_queue(), void_block);
#endif
