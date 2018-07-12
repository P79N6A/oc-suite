//
//  SNShareWechat.h
//  component
//
//  Created by fallen.ink on 5/26/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "SNShareService.h"

typedef enum {
    SNShareWechat_Friends = 0,   // 微信好友
    SNShareWechat_CircleFriends, // 微信朋友圈
} SNShareWechatType;

@interface SNShareWechat : SNShareService

@singleton( SNShareWechat )

@end
