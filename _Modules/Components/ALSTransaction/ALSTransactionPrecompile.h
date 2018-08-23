//
//  ALSTransactionPrecompile.h
//  _Modules
//
//  Created by 7 on 2018/8/23.
//

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

/**
 *  @author yangzm
 *
 *  回调状态码
 */
typedef NS_ENUM(NSInteger,FLErrCode) {
    FLErrCodeSuccess,// 成功
    FLErrCodeFailure,// 失败
    FLErrCodeCancel// 取消
};

typedef NS_ENUM(NSInteger,PAYType) {
    Enum_WEI_XIN,
    Enum_ALI_PAY
};
