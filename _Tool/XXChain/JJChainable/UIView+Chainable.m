//
//  UIView+Chainable.m
//  JJChainableExample
//
//  Created by JJ on 2017/2/18.
//  Copyright © 2017年 JJ. All rights reserved.
//

#import "UIView+Chainable.h"
#import "JJChainableKit.h"

@implementation UIView (Chainable)

- (JJChainableKit *)make{
    JJChainableKit * chain = [[JJChainableKit alloc] init];
    chain.view = self;
    return chain;
}

+ (JJChainableKit *)make{
    JJChainableKit * chain = [[JJChainableKit alloc] init];
    UIView *view = [[self alloc]init];
    chain.view = view;
    return chain;
}
@end
