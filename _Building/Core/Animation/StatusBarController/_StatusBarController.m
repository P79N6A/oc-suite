//
//  _Layout.m
//  _Building
//
//  Created by 7 on 2018/8/12.
//

#import "_Layout.h"

@implementation _Layout

@end

// MARK: -

@implementation UIView (AutoLayout)

- (BOOL)resetFirstLayoutAttribute:(NSLayoutAttribute)attribute withConstant:(CGFloat)constant {
    NSArray *leftBorderConstraintsArray = [self constraints];
    BOOL hasAttr = NO;
    for (NSLayoutConstraint *constraint in leftBorderConstraintsArray) {
        if (constraint.firstAttribute == attribute) {
            constraint.constant = constant;
            hasAttr = YES;
            break;
        }
    }
    return hasAttr;
}

@end
