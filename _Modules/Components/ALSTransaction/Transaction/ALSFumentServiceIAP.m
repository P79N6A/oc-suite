//
//  ALSFumentServiceIAP.m
//  Pay-inner
//
//  Created by  杨子民 on 2017/12/5.
//  Copyright © 2017年 yangzm. All rights reserved.
//

#if __has_include("ALSInAppPurchase.h")
#define ALS_IAP_PURCHASE
#import "ALSInAppPurchase.h"
#endif

#import "ALSFumentServiceIAP.h"
#import "ALSFument.h"

#import "NetHelp.h"
#import "ALSKeyChainStore.h"
#import "ALSTransactionKit.h"
#import "ALSTransactionDef.h"

#define   KEY_CHAIN_FLAG    @"ALSFUMENT"
#define   KEY_CHAIN_ALS_DATA  @"ALS_DATA"

@interface ALSFumentServiceIAP()
{
#ifdef ALS_IAP_PURCHASE
    id < ALSRMStoreReceiptVerifier > _receiptVerifier;
    ALSRMStoreKeychainPersistence*_persistence;
#endif
}

@property ( nonatomic, strong ) id<ALSThirdPartyPaymentInitDelegate>delegate;

// 请求用到的数据
@property( nonatomic, strong) ALSThirdPartyPaymentInfitInfo* info;

@property( nonatomic, strong) ALSKeyChainStore*keychain;
@property( nonatomic,strong) ALSKeyChainStore* keychainData;
@end

@implementation ALSFumentServiceIAP

#ifdef ALS_IAP_PURCHASE
- (id)init {
    self = [super init];  // Call a designated initializer here.
    if (self != nil) {
        // 初始化keychain
        self.keychain = [ALSKeyChainStore keyChainStoreWithService:KEY_CHAIN_FLAG];
        self.keychainData = [ALSKeyChainStore keyChainStoreWithService:KEY_CHAIN_ALS_DATA];
        [ALSRMStore defaultStore].isLocalVerify = NO;
        
        _receiptVerifier = [[ALSRMStoreAppReceiptVerifier alloc] init];
        [ALSRMStore defaultStore].receiptVerifier = _receiptVerifier;
        
        _persistence = [[ALSRMStoreKeychainPersistence alloc] init];
        [ALSRMStore defaultStore].transactionPersistor = _persistence;
    }
    return self;
}

- (void)SetMsgCallback:(ALSFuCompleteCallBack)callback {
    // 查询回调
    [[ALSRMStore defaultStore] ProductRequestProc:^(id id_array, id anObject, NSDictionary *aUserInfo) {
        if ( callback )
            callback( PayquerySuccess, id_array, nil );
    } failed:^(id id_array, id anObject, NSDictionary *aUserInfo) {
        if ( callback )
            callback( PayqueryFailure, id_array, nil );
    }];
    
    // 购买回调
    [[ALSRMStore defaultStore] PaymentTransactionProc:^(id pid, id anObject, NSDictionary *aUserInfo) {
        if ( callback )
            callback( PayBuySuccess, pid, nil );
    } failed:^(id pid, id anObject, NSDictionary *aUserInfo) {
        if ( callback )
            callback( PayBuyFailure, pid, nil );
    } deferred:^(id pid, id anObject, NSDictionary *aUserInfo) {
        if ( callback )
            callback( Paydeferred, pid, nil );
    }];
    
    // 本地认证是否成功
    [[ALSRMStore defaultStore] LocalVerifyProc:^(id pid, NSData *receiptData, NSString *receiptString) {
        if(callback)
            callback( PayLocalVerifySuccess, pid, nil );
    } failed:^(id pid, NSData *data, NSString *receiptString) {
        if ( callback )
            callback( PayLocalVerifyFailure, pid, nil );
        [[ALSRMStore defaultStore] RefreshReceiptProc:^(id pid, id anObject, NSDictionary *aUserInfo) {
            if ( callback )
                callback( PayLocalVerifyRefreshSuccess, pid, nil );
        } failed:^(id pid, id anObject, NSDictionary *aUserInfo) {
            if ( callback )
                callback( PayLocalVerifyRefreshFailure, pid, nil );
        }];
    }];
    
    // 恢复购买时才会收到消息
    [[ALSRMStore defaultStore] RestoreTransactionsProc:^(id pid, id anObject, NSDictionary *aUserInfo) {
        if ( callback )
            callback( PayRestoreSuccess, pid, nil );
    } failed:^(id pid, id anObject, NSDictionary *aUserInfo) {
        if ( callback )
            callback( PayRestoreFailure, pid, nil );
    }];
    
    // 只有在NO时才能调用下边的block 数据
    __weak typeof(self) weakSelf = self;
    
    [ALSRMStore defaultStore].isLocalVerify = NO;
    [[ALSRMStore defaultStore] RemoteVerify:^(id pid, NSData *data, NSString *receiptString, BOOL *bSucceed, NSError* error)
     {
         NSString *userinfo = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
         [weakSelf verifyCertificate:receiptString transactionId:pid map:nil userinfo:userinfo error:error callback:callback];
         *bSucceed = YES;
     }];
}

- (void)setInitDelegate:(id)alsthirdpartypaymentInitDelegate {
    self.delegate = alsthirdpartypaymentInitDelegate;
    if ( self.delegate ){
        self.info = [self.delegate thirdPartyPaymentInitInfoPlatform:_PaymentPlatformIAP];
    }
}

- (BOOL)WritetoKeychian:(NSString*)transactionId receipt:(NSString*)receipt dic:(NSDictionary*)dic {
    // 添加数据
    NSMutableDictionary* append = [[NSMutableDictionary alloc] initWithDictionary:dic];
    [append setObject:receipt forKey:@"ALS_RECIPT"];
    
    NSString* strDictionary = [NetHelp dictionaryToJson:append];
    if ( self.keychain )
        [self.keychain setString:strDictionary forKey:transactionId];
    else
        return NO;
    
    return YES;
}

- (void)startPaymentProc:(ALSFument*)payment callback:(ALSFuCompleteCallBack)callback
{
    NSString* urlFromClient;
    if ( [ALSTransactionKit shareManager].isDebug )
        urlFromClient = [ALSTransactionDef sharedInstance].payInfoUrlDaily;
    else
        urlFromClient = [ALSTransactionDef sharedInstance].payInfoUrlProduct;
    
    NSMutableDictionary* dicFromClient = [[NSMutableDictionary alloc] initWithDictionary:payment.map];
    [dicFromClient setObject:@"MOBILE_SDK" forKey:@"platform"];
    
    //__weak typeof (self) weakself = self;
    [NetHelp post:urlFromClient RequestParams:dicFromClient FinishBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError)
     {
         //NSString* sData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         if ( connectionError == nil ){
             NSError* error;
             NSDictionary *retdic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
             
             NSString* strCode = [retdic objectForKey:@"alisp_code"];
             NSString* str = [@"" stringByAppendingFormat:@"%@%@",@"6",strCode];
             NSString *msg = [retdic objectForKey:@"alisp_msg"];
             
             if ( 200 != [strCode integerValue] ){
                 if ( callback ){
                     // yangzm add data
                     NSString *data = [retdic objectForKey:@"alisp_data"];
                     data = data ? data : @"支付错误";
                     NSError *error = [NSError errorWithDomain:data code:-1 userInfo:nil];
                     callback( [str integerValue], msg, error );
                 }
             }
             else
             {
                 // 开始支付的接口
                 NSString *orderMessage = [retdic objectForKey:@"alisp_data"];
                 if ( self.keychainData ){
                     [self.keychainData setString:orderMessage forKey:@"alisp_data"];
                 }
                 
                 // 恢复购买时才会收到消息
                 [[ALSRMStore defaultStore] RestoreTransactionsProc:^(id pid, id anObject, NSDictionary *aUserInfo) {
                     if ( callback )
                         callback( PayRestoreSuccess, pid, nil );
                 } failed:^(id pid, id anObject, NSDictionary *aUserInfo) {
                     if ( callback )
                         callback( PayRestoreFailure, pid, nil );
                 }];
                 
                 [[ALSRMStore defaultStore] RemoteVerify:^(id pid, NSData *data, NSString *receiptString, BOOL *bSucceed, NSError* erro)
                  {
                      *bSucceed = YES;
                      NSString *userinfo = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
                      [self verifyCertificate:receiptString transactionId:pid map:nil userinfo:userinfo error:erro callback:callback];
                  }];
                 
                 // 开始支付
                 [[ALSRMStore defaultStore] addPayment:payment.paymentInfo user:payment.userid success:^(SKPaymentTransaction *transaction)
                  {
                      //if ( callback )
                      //    callback( 0, @"transaction ok", nil );
                  }
                  failure:^(SKPaymentTransaction *transaction, NSError *error)
                  {
                      if ( callback )
                          callback( PayAppleApiFailure, @"transaction error", error );
                  }];
             }
         }
         else{
             NSLog( @"first request error:-----$$$$$$$$$$$$$%ld", (long)connectionError.code );
             if ( callback )
                 callback( PayRemoteVerifyFailure, @"first request error...", connectionError );
         }
     }];
}

- (BOOL)canMakePayments
{
    return [ALSRMStore canMakePayments];
}

- (void)startPayment:(ALSFument*)payment callback:(ALSFuCompleteCallBack)callback
{
    if( nil == callback )
        return;
    
    // 这里开始iap 交易
    [self startPaymentProc:payment callback:callback];
}

- (void)requestProducts:(NSSet*)identifiers success:(IAPProductsRequestSuccessBlock)successBlock failure:(IAPStoreFailureBlock)failureBlock
{
    // 调用查询接口
    [[ALSRMStore defaultStore] requestProducts:identifiers success:successBlock failure:failureBlock];
}

- (void) verifyCertificate:(NSString*)certificate transactionId:(NSString*)transactionId map:(NSDictionary*)entermap userinfo:(NSString*)info error:(NSError*)error callback:(ALSFuCompleteCallBack)callback
{
    NSString* url;
    if ( [ALSTransactionKit shareManager].isDebug )
        url = [ALSTransactionDef sharedInstance].payNotifyUrlDaily;
    else
        url = [ALSTransactionDef sharedInstance].payNotifyUrlProduct;
    
    NSString* orderMessage;
    if ( nil == entermap ){
        if ( [self.keychainData contains:@"alisp_data" ] ){
            orderMessage =  [self.keychainData stringForKey:@"alisp_data"];
            [self.keychainData removeItemForKey:@"alisp_data"];
        }
    }
    else
        orderMessage = [NetHelp dictionaryToJson:entermap];
    
    if ( certificate == nil ){
        if ( callback ){
            // 处理用户取消的情况
            if ( error.code == SKErrorPaymentCancelled )
                callback(600000+9999, @"PayRemoteVerifyFailure...", error);
            else
                callback(PayRemoteVerifyFailure, @"apple store return error...", error);
        }
        NSLog(@"apple store return error.......100235");
        return;
    }
    
    NSString* encodedUrl = [NetHelp encodeString:certificate];
    NSDictionary* dic = @{ @"receipt": encodedUrl, @"receive_info": orderMessage,@"transaction_id":transactionId };
    
    __weak typeof (self) weakself = self;
    [NetHelp post:url RequestParams:dic FinishBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
         if ( connectionError == nil ){
             NSString* result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSError* error;
             NSDictionary *retdic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
             NSInteger retCode = [[retdic objectForKey:@"alisp_code"] integerValue];
             
             if ( callback && 200 == retCode ){
                 // 如果认证成功并且，本地存在就把本地存储删除
                 if ( [self containsBytransactionId:transactionId] ){
                     [self removeRestoreBytransactionId:transactionId];
                 }
                 callback(0, result, nil);
             }else{
                 // 这些情况不进行记录  https://lark.alipay.com/pe7ost/hg7rgr/kyede7
                 // 收据信息是沙箱环境使用，但却被发送到产品环境中验证
                 // 收据信息是生产环境中使用，但却被发送到沙箱环境中验证
                 if ( 40132 != retCode && 40133 != retCode ){
                     // 失败时调用写入keychian功能
                     NSDictionary* map = [NetHelp dictionaryWithJsonString:orderMessage];
                     [weakself WritetoKeychian:transactionId receipt:certificate dic:map];
                 }
                 NSString *msg = [retdic objectForKey:@"alisp_msg"];
                 NSString* str = [@"" stringByAppendingFormat:@"%@%ld",@"6",(long)retCode];
                 
                 callback([str integerValue], msg, nil);
             }
         }
         else{
             if ( callback )
                 callback(PayRemoteVerifyFailure, @"second request...", connectionError);
             
             // 失败时调用写入keychian功能
             NSDictionary* map = [NetHelp dictionaryWithJsonString:orderMessage];
             [weakself WritetoKeychian:transactionId receipt:certificate dic:map];
         }
     }];
}

- (NSInteger) unfinishedOrderCount
{
    NSArray *items = self.keychain.allItems;
    if ( items )
        return items.count;
    
    return 0;
}

- (BOOL) carryOnUnfinishedVerify:(ALSFuCompleteCallBack)callback
{
    if ( nil == callback )
        return NO;
    
    // 先查找现在有多少个没有处理完成的数据
    NSArray* arr = [self queryAllUnfinishedVerify];
    if ( arr.count == 0 )
        return NO;
    
    // 循环进行服务器的认证
    for( id key in arr )
    {
        NSString* k = [key objectForKey:@"key"];
        NSDictionary* dic = [self queryUnfinishedVerifyByid:k];
        NSString* receiptString = [self queryUnfinishedVerifyStringByid:k];

        if ( dic && receiptString )
           [self verifyCertificate:receiptString transactionId:k map:dic userinfo:nil error:nil callback:callback];
    }
    
    return YES;
}

- (BOOL)containsBytransactionId:(NSString*)transactionId
{
    return [self.keychain contains:transactionId];
}

- (NSString*) queryUnfinishedVerifyStringByid:(NSString*)transactionId
{
    if ( [self.keychain contains:transactionId] ){
        NSString *strValue = [self.keychain stringForKey:transactionId];
        
        NSMutableDictionary* undic = [[NetHelp dictionaryWithJsonString:strValue] mutableCopy];
        if ( [[undic allKeys] containsObject:@"ALS_RECIPT"] )
            return [undic objectForKey:@"ALS_RECIPT"];
    }
    return nil;
}

- (NSDictionary*) queryUnfinishedVerifyByid:(NSString*)transactionId
{
    if ( [self.keychain contains:transactionId] ){
        NSString *strValue = [self.keychain stringForKey:transactionId];
    
        NSMutableDictionary* undic = [[NetHelp dictionaryWithJsonString:strValue] mutableCopy];
        if ( [[undic allKeys] containsObject:@"ALS_RECIPT"] )
            [undic removeObjectForKey:@"ALS_RECIPT"];
        
        return [undic copy];
    }
    
    return nil;
}

- (NSArray*) queryAllUnfinishedVerify
{
    NSMutableArray* array = [NSMutableArray array];
    NSArray *items = self.keychain.allItems;
     for (NSString *key in items) {
         [array addObject:key];
     }
    
    return array;
}

- (BOOL) removeRestoreBytransactionId:(NSString*)transactionId
{
    if ( [self.keychain contains:transactionId] )
      return [self.keychain removeItemForKey:transactionId];
    
    return NO;
}

- (BOOL) removeAllRestore
{
    return [ALSKeyChainStore removeAllItemsForService:KEY_CHAIN_FLAG error:nil];
}
#endif

@end
