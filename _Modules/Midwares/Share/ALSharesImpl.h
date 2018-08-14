//
//  ALSharesImpl.h
//  NewStructure
//
//  Created by 7 on 22/12/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "_Foundation.h"
#import "_LaunchableProtocol.h"
#import "_SharesProtocol.h"

@interface ALSharesImpl : NSObject <_SharesProtocol, _LaunchableProtocol>

@singleton( ALSharesImpl )

@end
