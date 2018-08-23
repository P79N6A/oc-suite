//
//  ALSFumentServiceConformer.h
//  Pay-inner
//
//  Created by  杨子民 on 2017/12/1.
//  Copyright © 2017年 yangzm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_Protocols.h"
#import "ALSFumentProtocol.h"

@interface ALSFumentServiceConformer: NSObject<ALSFumentService>

- (void)setInitDelegate:(id)alsthirdpartypaymentInitDelegate;
- (bool)supportPlatform:(_PaymentPlatformType)platform;
- (void)startPayment:(ALSFument*)payment callback:(ALSFuCompleteCallBack)callback;
- (void)queryPaymentWithOrderId: (NSString*)orderid  callback:(ALSFuCompleteCallBack)callback;
- (BOOL)handleThirdPartyPaymentCallback:(NSURL*)url;

- (void)getPaymentInfor:(ALSFument*)payment callback:(ALSFuCompleteCallBack)back;
@end
