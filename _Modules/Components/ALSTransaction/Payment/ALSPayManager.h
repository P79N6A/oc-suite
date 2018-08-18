
#import <Foundation/Foundation.h>

//#import "WXApi.h"
//#import <AlipaySDK/AlipaySDK.h>

#if __has_include("WXApi.h")
#define ALS_IAP_WX
#import "WXApi.h"
#endif

#if __has_include(<AlipaySDK/AlipaySDK.h>)
#define ALS_IAP_PAY
#import <AlipaySDK/AlipaySDK.h>
#endif

/**
 *  @author yangzm
 *
 *  此处必须保证在Info.plist 中的 URL Types 的 Identifier 对应一致
 */
#define WEI_XIN @"weixin"
#define ALI_PAY_NAME @"alipay"

#define ALS_PAY [ALSPayManager shareManager]
/**
 *  @author yangzm
 *
 *  回调状态码
 */
typedef NS_ENUM(NSInteger,FLErrCode){
    FLErrCodeSuccess,// 成功
    FLErrCodeFailure,// 失败
    FLErrCodeCancel// 取消
};

typedef NS_ENUM(NSInteger,PAYType)
{
    Enum_WEI_XIN,
    Enum_ALI_PAY
};

typedef void(^FLCompleteCallBack)(FLErrCode errCode,NSString *errStr);

@interface ALSPayManager : NSObject
{
    
}

// 是否还在支付中...
@property (atomic, assign) BOOL is_paying;

+ (instancetype)shareManager;

/**
 *  @author yangzm
 *
 *  是否安装
 *
 *  @return YES 安装了 No:没有安装
 */
- (BOOL)isAppInstalled:(PAYType)paytype;

/**
 *  @author yangzm
 *
 *  返回当前版本号
 *
 *  @return 返回微信或支付宝版本号
 */
-(NSString*) currentVersion:(PAYType)paytype;

/**
 *  @author yangzm
 *
 *  处理跳转url，回到应用，需要在delegate中实现
 */
- (BOOL)handleUrl:(NSURL *)url;

/**
 *  @author yangzm
 *
 *  注册App，需要在 didFinishLaunchingWithOptions 中调用
 *  读取URLType当中的数据
 */
- (void)registerPay;


/**
 注册微信和支付宝

 @param param  key:@"weixin" value:@“65654“  key:@“alipay” value:@"som..." 以后可以扩展
 */
- (BOOL)registerPay:(NSDictionary*)param;

/**
 *  @author yangzm
 *
 *  发起支付
 *
 * @param orderMessage 传入订单信息,如果是字符串，则对应是跳转支付宝支付；如果传入PayReq 对象，这跳转微信支付,注意，不能传入空字符串或者nil
 * @param callBack     回调，有返回状态信息
 */
- (void)payWithOrderMessage:(id)orderMessage callBack:(FLCompleteCallBack)callBack;

// 下边是个性化的接口


@end
