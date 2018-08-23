//
//  ALSFumentServiceIAP.h
//  Pay-inner
//
//  Created by  杨子民 on 2017/12/5.
//  Copyright © 2017年 yangzm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSFumentProtocol.h"

@interface ALSFumentServiceIAP : NSObject<ALSFumentIAPService>
{
    
}

- (void)setInitDelegate:(id)alsthirdpartypaymentInitDelegate;
- (void)SetMsgCallback:(ALSFuCompleteCallBack)callback;
- (void)startPayment:(ALSFument*)payment callback:(ALSFuCompleteCallBack)callback;

- (BOOL)canMakePayments;

/**
 可以查询商品列表

 @param identifiers 商品id列表
 @param successBlock 是否成功
 @param failureBlock 是否失败
 */
- (void)requestProducts:(NSSet*)identifiers success:(IAPProductsRequestSuccessBlock)successBlock failure:(IAPStoreFailureBlock)failureBlock;

/**
 进行凭证的远程认证
 
 @param entermap 业务传来的数据
 @param certificate base64 后的串
 @param transactionId 苹果交易时的id

 */
- (void) verifyCertificate:(NSString*)certificate transactionId:(NSString*)transactionId map:(NSDictionary*)entermap userinfo:(NSString*)info error:(NSError*)error callback:(ALSFuCompleteCallBack)callback;

/**
 未完成远程验证的订单总数
 
 @return 返回个数
 */
- (NSInteger) unfinishedOrderCount;

/**
 开始完成，未完成的和远程服务器的认证功能
 
 @return 成功返回
 */
- (BOOL) carryOnUnfinishedVerify:(ALSFuCompleteCallBack)callback;

/**
 用transactionId 来查询出当时存入的map 字典的内容

 @param transactionId 传入的id
 @return 返回当时的map
 */
- (NSDictionary*) queryUnfinishedVerifyByid:(NSString*)transactionId;

/**
 返回所有没完成的任务id 数组，用queryUnfinishedVerifyByid 可以查询到当时存入的map是什么
 就可以用removeRestoreBytransactionId 来进行进行删除等操作

 @return id 数组
 */
- (NSArray*) queryAllUnfinishedVerify;

/**
 根据transactionId来删除本地记录的数据  ！！！这里一定要注意，如果与远程没有进行过验证就删除就会出现丢单的情况
 
 @param transactionId  订单号
 @return 是否成功
 */
- (BOOL) removeRestoreBytransactionId:(NSString*)transactionId;

/**
 删除所有本地存储的未完成认证信息 ！！！这里一定要注意，如果与远程没有进行过验证就删除就会出现丢单的情况
 
 @return 是否成功
 */
- (BOOL) removeAllRestore;

@end
