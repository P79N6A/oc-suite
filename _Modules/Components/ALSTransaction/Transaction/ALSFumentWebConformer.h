//
//  ALSFumentWebConformer.h
//  Pay-inner
//
//  Created by  杨子民 on 2018/4/26.
//  Copyright © 2018年 yangzm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "_Protocols.h"
#import "ALSFumentProtocol.h"

@interface ALSFumentWebConformer : NSObject<ALSFumentService>

- (void)setInitDelegate:(id)alsthirdpartypaymentInitDelegate;
- (bool)supportPlatform:(_PaymentPlatformType)platform;
- (void)startPayment:(ALSFument*)payment callback:(ALSFuCompleteCallBack)callback;
- (void)queryPaymentWithOrderId: (NSString*)orderid  callback:(ALSFuCompleteCallBack)callback;
- (BOOL)handleThirdPartyPaymentCallback:(NSURL*)url;

- (void)getPaymentInfor:(ALSFument*)payment callback:(ALSFuCompleteCallBack)back;
@end


