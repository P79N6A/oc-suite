#import "_Protocol.h"

typedef enum : NSUInteger {
    _SharePlatformWechatMask = 0x000f,         // 0000 0000 0000 1111
    _SharePlatformWechatSession = 1 << 0,      // 0000 0000 0000 0001
    _SharePlatformWechatTimeLine = 1 << 1,     // 0000 0000 0000 0010
    _SharePlatformWechatFavorate = 1 << 2,     // 0000 0000 0000 0100
    
    _SharePlatformWeiboMask = 0x00f0,          // 0000 0000 1111 0000
    _SharePlatformWeiboCommon = 1 << 4,        // 0000 0000 0001 0000
    
    _SharePlatformTencentMask = 0x0f00,        // 0000 1111 0000 0000
    _SharePlatformTencentQQ = 1 << 8,          // 0000 0001 0000 0000
    _SharePlatformTencentQZone = 1 << 9,       // 0000 0010 0000 0000
} _SharePlatformType;

@protocol _ShareParamProtocol <_Protocol>

// 分享平台 & 场景

@property (nonatomic, assign) _SharePlatformType type;

// 分享场景

@property (nonatomic, strong) NSString *platform;
@property (nonatomic, assign) NSUInteger scene; // FIXME: NSString -> NSUInteger

// 分享参数

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSObject *thumb; // url of thumb image / just image
@property (nonatomic, strong) NSString *url; // url of html

@end
