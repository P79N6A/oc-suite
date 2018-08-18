//
//  ALSIAPPayment.m
//  Pay-inner
//
//  Created by  杨子民 on 2017/12/18.
//  Copyright © 2017年 yangzm. All rights reserved.
//

#import "ALSIAPPayment.h"
#import "ALSThirdPartyPaymentInfitInfo.h"

@interface ALSIAPPayment()
{
    
}
@end

@implementation ALSIAPPayment
{
    
}

- (ALSTKPaymentPlatform)getName
{
    return ALSTKPaymentPlatfomIAP;
}

- (BOOL)IsDebug
{
    return self.isdebug;
}

- (void)setDebug:(BOOL)isdebug
{
    self.isdebug = isdebug;
}

@end
