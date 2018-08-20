//
//  NSSessionObserveProtocol.h
//  wesg
//
//  Created by 7 on 06/12/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_LoginObserveProtocol.h"
#import "_LogoutObserveProtocol.h"

@protocol _SessionObserveProtocol <
_LoginObserveProtocol,
_LogoutObserveProtocol
>

@end
