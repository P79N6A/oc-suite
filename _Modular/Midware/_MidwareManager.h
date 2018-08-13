//
//  _MidwareManager.h
//  NewStructure
//
//  Created by 7 on 03/01/2018.
//  Copyright © 2018 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSportsMacro.h"

@interface _MidwareManager : NSObject

@singleton( _MidwareManager )

- (void)activateLoadableObjects;

- (void)activateLaunchableObjects;

@end
