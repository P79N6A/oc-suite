//
//  AliPayAutoOrder.m
//  student
//
//  Created by fallen.ink on 15/10/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "AliPayAutoOrder.h"

@implementation AliPayAutoOrder

- (NSString *)generate:(NSError **)ppError {
    return self.payUrl;
}

- (void)clear {
    self.payUrl = nil;
}

@end
