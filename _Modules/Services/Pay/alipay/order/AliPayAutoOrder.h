//
//  AliPayAutoOrder.h
//  student
//
//  Created by fallen.ink on 15/10/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "AliPayOrder.h"

@interface AliPayAutoOrder : AliPayOrder

/**
 *  @desc 当前工程内实现，只关注下面参数
 */
@property (nonatomic, strong) NSString *payUrl;

@end
