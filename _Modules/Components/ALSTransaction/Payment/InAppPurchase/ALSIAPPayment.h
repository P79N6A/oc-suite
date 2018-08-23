//
//  ALSIAPPayment.h
//  Pay-inner
//
//  Created by  杨子民 on 2017/12/18.
//  Copyright © 2017年 yangzm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSFumentProtocol.h"


@interface ALSIAPPayment : NSObject <ALSFumentPlugProtocol>

@property(nonatomic,assign)BOOL isdebug;

- (_PaymentPlatformType)getName;
- (BOOL)IsDebug;
- (void)setDebug:(BOOL)isdebug;
@end
