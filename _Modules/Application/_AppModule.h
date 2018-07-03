//
//  _app_module.h
//  kata
//
//  Created by fallen on 17/3/10.
//  Copyright © 2017年 fallenink. All rights reserved.
//

#import "_building_precompile.h"

// ----------------------------------
// Macro
// ----------------------------------

#undef  app_module
#define app_module  [_AppModule sharedInstance]

// ----------------------------------
// Class Definition
// ----------------------------------

@interface _AppModule : NSObject

@singleton(_AppModule)

- (void)initComponents;

- (void)initServices;

@end
