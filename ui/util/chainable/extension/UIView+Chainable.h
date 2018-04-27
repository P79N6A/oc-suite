//
//  UIView+Chainable.h
//  JJChainableExample
//
//  Created by JJ on 2017/2/18.
//  Copyright © 2017年 JJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class _Chainable;

@interface UIView (Chainable)

- (_Chainable *)make;
+ (_Chainable *)make;

@end
