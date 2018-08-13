//
//  NSSessionObserveProtocol.h
//  wesg
//
//  Created by 7 on 06/12/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSLoginObserveProtocol.h"
#import "NSLogoutObserveProtocol.h"

@protocol NSSessionObserveProtocol <
NSLoginObserveProtocol,
NSLogoutObserveProtocol
>

@end
