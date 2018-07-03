//
//  ALSharesImpl.h
//  NewStructure
//
//  Created by 7 on 22/12/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSLaunchableProtocol.h"
#import "ALSharesProtocol.h"
#import "ALSportsMacro.h"

@interface ALSharesImpl : NSObject <ALSharesProtocol, NSLaunchableProtocol>

@singleton( ALSharesImpl )

@end
