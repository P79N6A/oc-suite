//
//  AliPayManualOrder.h
//  student
//
//  Created by fallen.ink on 15/10/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "AliPayOrder.h"

@interface AliPayManualOrder : AliPayOrder

@property (nonatomic, strong) NSString *no;         // 订单ID（由商家自行制定）
@property (nonatomic, strong) NSString *name;       // 商品标题
@property (nonatomic, strong) NSString *desc;       // 商品描述
@property (nonatomic, strong) NSString *price;      // 商品价格
@property (nonatomic, strong) NSString *outOfTime;

@end
