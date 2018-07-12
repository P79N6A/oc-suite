//
//  AliPayManualOrder.m
//  student
//
//  Created by fallen.ink on 15/10/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "AliPayManualOrder.h"
#import "AliPayConfig.h"
#if 0
#import "Order.h"
#import "DataSigner.h"
#endif

@implementation AliPayManualOrder

- (NSString *)generate:(NSError **)ppError {
#if 0
    Order *order = [Order new];
    
    order.partner   = [AliPayConfig sharedInstance].parnter;
    order.seller    = [AliPayConfig sharedInstance].seller;
    order.notifyURL = [AliPayConfig sharedInstance].notifyURL;
    
    order.showUrl   = [AliPayConfig sharedInstance].showURL;
    order.service   = [AliPayConfig sharedInstance].service;
    order.paymentType   = [AliPayConfig sharedInstance].paymentType;
    order.inputCharset  = [AliPayConfig sharedInstance].inputCharset;
    
    if (self.no && self.no.length) {
        order.tradeNO = self.no;
    } else {
        *ppError    = [self err_invalidOrderNumber];
        
        return nil;
    }
    
    if (self.name && self.name.length) {
        order.productName = self.name;
    } else {
        *ppError    = [self err_invalidProductName];
        
        return nil;
    }
    
    if (self.desc && self.desc.length) {
        order.productDescription = self.desc;
    } else {
        order.productDescription = @"unknown";
    }
    
    if (self.price && self.price.length) {
        order.amount = self.price;
    } else {
        order.amount = @"0.00";
    }
    
    if(self.outOfTime && self.outOfTime.length) {
        order.itBPay = self.outOfTime;  // 格式yyyy-MM-dd HH:mm:ss（5月26号后）
        // m-分钟，h－小时，d－天，1c－当天，范围：1m－15d （5月26号之前）
    }
    
    NSString *orderDesc = [order description];
    id<DataSigner> signer = CreateRSADataSigner([AliPayConfig sharedInstance].privateKey);
    
    NSString *signedString  = [signer signString:orderDesc];
    if (!signedString) {
        *ppError    = [self err_failedGenerateOrder];
        
        return nil;
    }
    
    NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"", orderDesc, signedString, @"RSA"];
    if (!orderString ||
        !orderString.length ) {
        return nil;
    }
    
    return orderString;
#endif
    return nil;
}

- (void)clear {
    self.no = nil;
    self.name = nil;
    self.desc = nil;
    self.price = nil;
}

@end
