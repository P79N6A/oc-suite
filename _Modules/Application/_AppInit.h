//
//  _app_init.h
//  kata
//
//  Created by fallen on 17/3/10.
//  Copyright © 2017年 fallenink. All rights reserved.
//

#import "_building_precompile.h"

// ----------------------------------
// Macro
// ----------------------------------

#undef  app_initializer
#define app_initializer [_AppInit sharedInstance]

// ----------------------------------
// Class Definition
// ----------------------------------

@interface _AppInit : NSObject

@singleton( _AppInit )

@end
