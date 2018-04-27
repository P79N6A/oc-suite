//
//  UIButton+Factory.m
//  teacher
//
//  Created by fallen.ink on 03/06/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "UIButton+Factory.h"

@implementation UIButton (Factory)

+ (instancetype)buttonWithType:(UIButtonType)type title:(NSString *)title target:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:type];
    
    button.frame = CGRectZero;
    [button setTitle:title forState:UIControlStateNormal];
    button.adjustsImageWhenHighlighted = NO;
    button.adjustsImageWhenDisabled = NO;
    button.showsTouchWhenHighlighted = YES;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+ (instancetype)buttonWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    return [self buttonWithType:UIButtonTypeCustom title:title target:target action:action];
}

- (void)setNormalTitle:(NSString *)normalTitle selectedTitle:(NSString *)selectedTitle {
    [self setTitle:normalTitle forState:UIControlStateNormal];
    [self setTitle:selectedTitle forState:UIControlStateSelected];
}

@end
