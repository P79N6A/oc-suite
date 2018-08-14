//
//  ALShareUtilityImpl.m
//  NewStructure
//
//  Created by 7 on 26/12/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "_MidwarePrecompile.h"
#import "ALShareUtilityImpl.h"
#if __has_ALSShareService
#import <ALSShare/ALSShareTool.h>
#endif

@implementation ALShareUtilityImpl

- (BOOL)availableForPlatform:(_SharePlatformType)platformType {
    BOOL available = NO;
    
#if __has_ALSShareService
    
    NSUInteger platform = [self typeOfPlatform:platformType];
    
    available = [ALSShareTool validateSharePlatform:(ALSSharePlatform)platform];
    
#endif
    
    return available;
}

- (NSUInteger)sceneTypeOfPlatform:(_SharePlatformType)platformType {
    NSUInteger sceneType = 0;
    
#if __has_ALSShareService
    
    switch (platformType) {
        case ALSharePlatformWeiboCommon:
        {
            sceneType = ALSShareSceneCommon;
        }
            break;
            
        case ALSharePlatformWechatSession:
        {
            sceneType = ALSShareSceneWeChatSession;
        }
            break;
            
        case ALSharePlatformWechatTimeLine:
        {
            sceneType = ALSShareSceneWeChatTimeLine;
        }
            break;
            
        case ALSharePlatformWechatFavorate:
        {
            sceneType = ALSShareSceneWeChatFavorite;
        }
            break;
            
        case ALSharePlatformTencentQQ:
        {
            sceneType = ALSShareSceneTencentQQ;
        }
            break;
            
        case ALSharePlatformTencentQZone:
        {
            sceneType = ALSShareSceneTencentQZone;
        }
            break;
            
        default:
            break;
    }
    
#endif
    
    return sceneType;
}

- (NSUInteger)typeOfPlatform:(_SharePlatformType)platformType {
    NSUInteger type = 0;
    
#if __has_ALSShareService
    
    if (platformType & ALSharePlatformWechatMask) {
        type = ALSSharePlatformWeChat;
    } else if (platformType & ALSharePlatformWeiboMask) {
        type = ALSSharePlatformWeibo;
    } else if (platformType & ALSharePlatformTencentMask) {
        type = ALSSharePlatformTencent;
    }
    
#endif
    
    return type;
}

@end
