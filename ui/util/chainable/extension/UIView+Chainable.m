//
//  UIView+Chainable.m
//  JJChainableExample
//
//  Created by JJ on 2017/2/18.
//  Copyright © 2017年 JJ. All rights reserved.
//

#import "UIView+Chainable.h"
#import "_chainable.h"

@implementation UIView (Chainable)

- (_Chainable *)make{
    _Chainable * chain = [[_Chainable alloc] init];
    chain.view = self;
    return chain;
}

+ (_Chainable *)make{
    _Chainable * chain = [[_Chainable alloc] init];
    UIView *view = [[self alloc]init];
    chain.view = view;
    return chain;
}
@end
