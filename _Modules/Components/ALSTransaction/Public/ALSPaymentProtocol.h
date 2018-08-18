//
//  ALSPaymentProtocol.h
//  Pay-inner
//
//  Created by  杨子民 on 2017/12/4.
//  Copyright © 2017年 yangzm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSPayment.h"

@protocol ALSPaymentService <NSObject>
@optional
- (void)setInitDelegate:(id)alsthirdpartypaymentInitDelegate;
- (void)startPayment:(ALSPayment*)payment callback:(ALSPayCompleteCallBack)callback;
- (bool)supportPlatform:(ALSTKPaymentPlatform)platform;
- (void)queryPaymentWithOrderId: (NSString*)orderid  callback:(ALSPayCompleteCallBack)callback;
- (BOOL)handleThirdPartyPaymentCallback:(NSURL*)str;
@end

@protocol ALSPaymentIAPService <ALSPaymentService>
@optional
- (void)SetMsgCallback:(ALSPayCompleteCallBack)callback;

/**
 是否可以购买，因为有的账号有问提时后边操作会不能判断，所以这个要在
 购买 button 判断是不是灰色的来阻止后边出现未知错误

 @return ok yes
 */
- (BOOL)canMakePayments;

/**
 查询商品

 @param identifiers 产品列表
 @param successBlock 成功回调
 @param failureBlock 失败回调
 */
- (void)requestProducts:(NSSet*)identifiers success:(IAPProductsRequestSuccessBlock)successBlock failure:(IAPStoreFailureBlock)failureBlock;

/**
 进行凭证的远程认证
*/
- (void) verifyCertificate:(NSString*)certificate transactionId:(NSString*)transactionId map:(NSDictionary*)entermap userinfo:(NSString*)info error:(NSError*)error callback:(ALSPayCompleteCallBack)callback;

/**
 未完成远程验证的订单总数

 @return 返回个数
 */
- (NSInteger) unfinishedOrderCount;

/**
 开始完成，为完成的认证

 @return 成功返回
 */
- (BOOL) carryOnUnfinishedVerify:(ALSPayCompleteCallBack)callback;

/**
 返回当时传入的参数,用于定位是否是当时传来的值
 @param transactionId 根据id 返回当时进入的数据
 @return 返回当时传入的值
 */
- (NSDictionary*) queryUnfinishedVerifyByid:(NSString*)transactionId;

/**
 查询所有未完成的订单

 @return 返回id 数组
 */
- (NSArray*) queryAllUnfinishedVerify;

/**
 根据订单号来删除本地记录的数据

 @param transactionId  订单号
 @return 是否成功
 */
- (BOOL) removeRestoreBytransactionId:(NSString*)transactionId;

/**
 删除所有本地存储的未完成成信息

 @return 是否成功
 */
- (BOOL) removeAllRestore;

@end

@protocol ALSPaymentPlugProtocol <NSObject>
   - (ALSTKPaymentPlatform)getName;
@end
