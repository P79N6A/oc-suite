#import <Foundation/Foundation.h>

@protocol _AppConfigProtocol <NSObject>
// FIXME: 这里key去维护，是不是比显性字段要好呢？

// 友盟
@property (nonatomic, strong) NSString *UMengAnalyticsAppId;
@property (nonatomic, strong) NSString *UMengFeedbackAppId;

// 淘宝
@property (nonatomic, strong) NSString *TaobaoKey;
@property (nonatomic, strong) NSString *TaobaoSecret;

// 微信
@property (nonatomic, strong) NSString *WechatKey;
@property (nonatomic, strong) NSString *WechatSecret;

// 微博
@property (nonatomic, strong) NSString *WeiboKey;
@property (nonatomic, strong) NSString *WeiboSecret;

// 腾讯QQ
@property (nonatomic, strong) NSString *TencentKey;
@property (nonatomic, strong) NSString *TencentSecret;

// Member??
//@property (nonatomic, strong) NSString *MemberKey;
//@property (nonatomic, strong) NSString *MemberSecret;

// 账户中心
@property (nonatomic, strong) NSString *AccountKey;
@property (nonatomic, strong) NSString *AccountSecret;

@end
