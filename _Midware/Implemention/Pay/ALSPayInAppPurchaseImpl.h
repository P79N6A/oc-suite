//
//  ALSPayInAppPurchaseImpl.h
//  Pay-inner
//
//  Created by 7 on 27/12/2017.
//  Copyright © 2017 yangzm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSPayInAppPurchaseProtocol.h"
#import "ALSPayImpl.h"

/**
 * 1. 应用内支付报 未知错误 处理方案
 *      - 注销账号
 *      - 通用-重制网络
 *      - 不要用正式账号
 */

@interface ALSPayInAppPurchaseImpl : ALSPayImpl <ALSPayInAppPurchaseProtocol>

@end
