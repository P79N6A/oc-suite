//
//  rn-precompile.h
//  startup
//
//  Created by 7 on 24/12/2017.
//  Copyright © 2017 7. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#if __has_include("RCTBridgeModule.h")
#   define __has_RCTBridgeModule 1
#   import "RCTBridgeModule.h"
#else
#   define __has_RCTBridgeModule 0
#endif

#if __has_include("RCTRootView.h")
#   define __has_RCTRootView 1
#   import "RCTRootView.h"
#else
#   define __has_RCTRootView 0
#endif
