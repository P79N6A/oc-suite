//
//  PayService.h
//  consumer
//
//  Created by fallen on 16/8/23.
//
//

#import "_service.h"

/**
 * @knowledge
 
 * 用adapter模式，做统一接口和第三方提供接口之间的转换
 */

typedef NS_ENUM(NSInteger, PayServiceErrorCode) {
    // mainly
    PayServiceErrorCodeSucceed        = 0,
    PayServiceErrorCodeFailure        = -10,
    PayServiceErrorCodeCancel         = -20,
    PayServiceErrorCodeUninstalled    = -30,
    
    // 前置错误（未实际调用api）
    PayServiceErrorCodeInvalidData    = -40,
    PayServiceErrorCodeSignature      = -50,
};

typedef enum : NSUInteger {
    PayServiceType_Alipay = 1,
    PayServiceType_Wechat = 2,
    PayServiceType_Union  = 3,
} PayServiceType;

@interface PayService : _Service

@singleton( PayService )

/**
 *  @desc 最近一次错误的实际原因（子类中）
 
 *  @error 而handler中传的错误是通用错误（ComponentPayment中声明）
 */
@property (nonatomic, assign) NSUInteger    errorCode; // 调试版本使用
@property (nonatomic, copy)   NSString *    errorDesc; // 调试版本使用

@property (nonatomic, copy) ObjectBlock     waitingHandler;
@property (nonatomic, copy) ObjectBlock     succeedHandler;
@property (nonatomic, copy) ErrorBlock      failedHandler; // 支付错误、支付取消

/**
 *  支付成功，不区分qqing支付、第三方支付
 */
@error( err_Succeed )
/**
 *  支付失败，不区分qqing支付、第三方支付
 */
@error( err_Failure )
/**
 *  第三方支付取消
 */
@error( err_Cancel )
/**
 *  指定的第三方支付没有安装
 */
@error( err_Uninstalled )

/**
 *  NSNumber
 */
@notification( WAITTING )

/**
 *  携带必要的应答对象
 */
@notification( SUCCEED )

/**
 *  携带错误对象
 
 *  NSError
 */
@notification( FAILED )

/**
 *  @desc 是否支持该支付方式
 */
+ (BOOL)supported;

// Tool methods
- (void)notifyWaiting:(NSNumber *)progress;
- (void)notifySucceed:(id)result; // 当前：携带err_Succeed
- (void)notifyFailed:(NSError *)error;
- (void)notifyUnknown; // 未知情况

// Overrided
- (BOOL)pay; // @return 不可不必处理，错误处理在failedHandler
- (void)process:(id)data;

- (void)parse:(NSURL *)url; // Call this in Share/Pay app call back by open url

@end
