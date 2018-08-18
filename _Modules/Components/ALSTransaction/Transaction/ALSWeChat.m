//
//  ALSWePay.m
//  Pay-inner
//
//  Created by  杨子民 on 2017/12/14.
//  Copyright © 2017年 yangzm. All rights reserved.
//

#import "ALSWeChat.h"

@implementation ALSWeChat

- (_PaymentPlatformType)getName {
    return _PaymentPlatformWechat;
}

- (BOOL)IsDebug {
    return self.isdebug;
}

- (void)setDebug:(BOOL)isdebug {
    self.isdebug = isdebug;
}

@end
