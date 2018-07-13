//
//  UIView+JHUD.m
//  JHudViewDemo
//
//  Created by 晋先森 on 16/7/16.
//  Copyright © 2016年 晋先森. All rights reserved.
//

#import "UIView+WebHud.h"


@implementation UIView (JHUD)

- (void)addConstraintWidth:(CGFloat)width height:(CGFloat)height {
    if (width > 0) {
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:self
                             attribute:NSLayoutAttributeWidth
                             relatedBy:NSLayoutRelationEqual
                             toItem:nil
                             attribute:0
                             multiplier:1
                             constant:width]];
    }

    if (height > 0) {
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:self
                             attribute:NSLayoutAttributeHeight
                             relatedBy:NSLayoutRelationEqual
                             toItem:nil
                             attribute:0
                             multiplier:1
                             constant:height]];
    }
}

- (void)addConstraintCenterXToView:(UIView *)xView
                         xConstant:(CGFloat)xConstant
                     centerYToView:(UIView *)yView
                         yConstant:(CGFloat)yConstant {
    if (xView) {
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:xView
                             attribute:NSLayoutAttributeCenterX
                             relatedBy:NSLayoutRelationEqual
                             toItem:self
                             attribute:NSLayoutAttributeCenterX
                             multiplier:1.0
                             constant:xConstant]];
    }

    if (yView) {
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:yView
                             attribute:NSLayoutAttributeCenterY
                             relatedBy:NSLayoutRelationEqual
                             toItem:self
                             attribute:NSLayoutAttributeCenterY
                             multiplier:1.0
                             constant:yConstant]];
    }
}

- (NSLayoutConstraint *)addConstraintCenterYToView:(UIView *)yView
                                          constant:(CGFloat)constant {
    if (yView) {
        NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint
                                                 constraintWithItem:yView
                                                 attribute:NSLayoutAttributeCenterY
                                                 relatedBy:NSLayoutRelationEqual
                                                 toItem:self
                                                 attribute:NSLayoutAttributeCenterY
                                                 multiplier:1.0
                                                 constant:constant];
        [self addConstraint:centerYConstraint];
        return centerYConstraint;
    }
    return nil;
}

- (NSLayoutConstraint *)addConstarintWithTopView:(UIView *)indicatorView
                                    toBottomView:(UIView *)bottomView
                                      constarint:(CGFloat)constarint {
    NSLayoutConstraint *topButtomConstraint =[NSLayoutConstraint
                                              constraintWithItem:indicatorView
                                              attribute:NSLayoutAttributeBottom
                                              relatedBy:NSLayoutRelationEqual
                                              toItem:bottomView
                                              attribute:NSLayoutAttributeTop
                                              multiplier:1
                                              constant:-constarint];
    [self addConstraint:topButtomConstraint];
    return topButtomConstraint;
}

- (void)removeConstraintWithAttribte:(NSLayoutAttribute)attribute {
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == attribute) {
            [self removeConstraint:constraint];
            break;
        }
    }
}

- (void)removeAllConstraints {
    [self removeConstraints:self.constraints];
}


@end

