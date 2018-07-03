//
//  ALSCacheProtocol.h
//  NewStructure
//
//  Created by 7 on 17/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSProtocol.h"
#import "NSArraySubscriptProtocol.h"
#import "NSDictionarySubscriptProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ALSCacheProtocol <ALSProtocol, NSArraySubscriptProtocol, NSDictionarySubscriptProtocol>


@end

NS_ASSUME_NONNULL_END
