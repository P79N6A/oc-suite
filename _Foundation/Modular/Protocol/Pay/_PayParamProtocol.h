#import "_Protocol.h"

// -------------------------------------------
// Type Definition
// -------------------------------------------

typedef enum : NSUInteger {
    _PaymentPlatformAlipay = 0,
    _PaymentPlatformAlipayWeb,
    _PaymentPlatformWechat,
    _PaymentPlatformIAP,
} _PaymentPlatformType;

// -------------------------------------------
// Protocol Definition
// -------------------------------------------

@protocol _PayParamProtocol <_Protocol>

// 通用
@property (nonatomic, strong) id payload;

// 阿里支付
// ...

// 微信支付
// ...

// 应用内支付
@property(nonatomic, strong) NSString *paymentInfo;
@property(nonatomic, strong) NSArray *products; // ipa 用于查询商品
@property(nonatomic, strong) NSString *userid; // 用户标识，可以区分不同用户

@end
