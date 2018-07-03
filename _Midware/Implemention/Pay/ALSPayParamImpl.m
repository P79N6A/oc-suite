//
//  ALSPayParamImpl.m
//  Pay-inner
//
//  Created by 7 on 27/12/2017.
//  Copyright © 2017 yangzm. All rights reserved.
//

#import "ALSPayParamImpl.h"

@implementation ALSPayParamImpl

@synthesize payload;
@synthesize products;
@synthesize userid;
@synthesize paymentInfo;

- (void)cleanup {
    self.payload = nil;
}

@end
