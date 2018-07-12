//
//  SNShareQQ.h
//  component
//
//  Created by fallen.ink on 5/26/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "SNShareService.h"

typedef enum {
    SNShareQQ_Friends = 0,   // QQ好友
    SNShareQQ_Zone, // QQ空间
} SNShareQQType;

@interface SNShareQQ : SNShareService

@singleton( SNShareQQ )

@end
