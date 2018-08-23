//
//  ALSTransactionKit.m
//  Pay-inner
//
//  Created by  杨子民 on 2017/12/4.
//  Copyright © 2017年 yangzm. All rights reserved.
//

#import "ALSTransactionKit.h"
#import "ALSFumentServiceConformer.h"
#import "ALSFumentServiceIAP.h"
#import "ALSFumentWebConformer.h"

#import "NetKReachability.h"

@interface ALSTransactionKit() {
    
}
@property (nonatomic,copy)ALSFuCompleteCallBack paycallBack;


@end

@implementation ALSTransactionKit {
    
}

+ (instancetype)shareManager {
    static ALSTransactionKit *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)asyncInit:(NSString*)appid callback:(ALSFuCompleteCallBack)callback {
    self.paycallBack = callback;
    NetKReachability *manager = [NetKReachability sharedInstance];
    [manager startNetworkMonitoringWithStatusChangeBlock:^ (NetKNetworkStatus status) {
        
    }];
}

- (id)getService:( _PaymentPlatformType )service {
    if ( service == _PaymentPlatformAlipay ) {
        if ( _AliFu == nil )
            _AliFu = [[NSClassFromString(@"ALSFumentServiceConformer") alloc] init];
        return  _AliFu;
    } else if ( service == _PaymentPlatformWechat ) {
        if ( _WeChat == nil )
            _WeChat = [[NSClassFromString(@"ALSFumentServiceConformer") alloc] init];
        return  _WeChat;
    } else if ( service ==  _PaymentPlatformIAP ) {
        if ( _IAPPay == nil )
           _IAPPay = [[NSClassFromString(@"ALSFumentServiceIAP") alloc] init];
        return _IAPPay;
    } else if( service == _PaymentPlatformAlipayWeb ) {
        if ( nil == _WebFu )
            _WebFu = [[NSClassFromString(@"ALSFumentWebConformer") alloc] init];
        return _WebFu;
    }
    
    return nil;
}

- (void)setService:( id<ALSFumentPlugProtocol> )protocol {
    if ( _PaymentPlatformIAP == [protocol getName]  ) {
       if ( _IAPPay == nil )
           _IAPPay = [[NSClassFromString(@"ALSFumentServiceIAP") alloc] init];
    }
    
    if ( _PaymentPlatformAlipay == [protocol getName]  ) {
        if ( _AliFu == nil )
            _AliFu = [[NSClassFromString(@"ALSFumentServiceConformer") alloc] init];
    }
    
    if ( _PaymentPlatformWechat == [protocol getName]  ) {
        if ( _WeChat == nil  )
            _WeChat = [[NSClassFromString(@"ALSFumentServiceConformer") alloc] init];
    }
}

@end
