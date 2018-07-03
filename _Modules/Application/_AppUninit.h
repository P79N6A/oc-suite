//
//  _app_uninit.h
//  kata
//
//  Created by fallen on 17/3/10.
//  Copyright © 2017年 fallenink. All rights reserved.
//

#import "_building_precompile.h"

// ----------------------------------
// Macro
// ----------------------------------

#undef  app_uninitializer
#define app_uninitializer   [_AppUninit sharedInstance]

// ----------------------------------
// Pre Declaration
// ----------------------------------

@protocol AppUninitDelegate;

// ----------------------------------
// Class Definition
// ----------------------------------

@interface _AppUninit : NSObject

@singleton( _AppUninit )

@prop_weak(id<AppUninitDelegate>, delegate)

- (void)logout;

@end

// ----------------------------------
// Delegate Definition
// ----------------------------------

@protocol AppUninitDelegate <NSObject>

@optional

- (void)onLogout;

@end
