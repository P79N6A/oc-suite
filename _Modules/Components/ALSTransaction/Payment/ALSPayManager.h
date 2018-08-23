
#import "_Foundation.h"
#import "ALSTransactionPrecompile.h"

typedef void(^FLCompleteCallBack)(FLErrCode errCode,NSString *errStr);

@interface ALSPayManager : NSObject

// 是否还在支付中...
@property (atomic, assign) BOOL isPaying;

@singleton(ALSPayManager)

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
