//
//  ALShareParamProtocol.h
//  NewStructure
//
//  Created by 7 on 22/12/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSProtocol.h"

typedef enum : NSUInteger {
    ALSharePlatformWechatMask = 0x000f,         // 0000 0000 0000 1111
    ALSharePlatformWechatSession = 1 << 0,      // 0000 0000 0000 0001
    ALSharePlatformWechatTimeLine = 1 << 1,     // 0000 0000 0000 0010
    ALSharePlatformWechatFavorate = 1 << 2,     // 0000 0000 0000 0100
    
    ALSharePlatformWeiboMask = 0x00f0,          // 0000 0000 1111 0000
    ALSharePlatformWeiboCommon = 1 << 4,        // 0000 0000 0001 0000
    
    ALSharePlatformTencentMask = 0x0f00,        // 0000 1111 0000 0000
    ALSharePlatformTencentQQ = 1 << 8,          // 0000 0001 0000 0000
    ALSharePlatformTencentQZone = 1 << 9,       // 0000 0010 0000 0000
} ALSharePlatformType;

@protocol ALShareParamProtocol <ALSProtocol>

// 分享平台 & 场景

@property (nonatomic, assign) ALSharePlatformType type;

// 分享场景

@property (nonatomic, strong) NSString *platform;
@property (nonatomic, assign) NSUInteger scene; // FIXME: NSString -> NSUInteger

// 分享参数

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSObject *thumb; // url of thumb image / just image
@property (nonatomic, strong) NSString *url; // url of html

@end
