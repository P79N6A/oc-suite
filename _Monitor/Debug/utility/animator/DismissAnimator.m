//
//  DismissAnimator.m
//  monitor
//
//  Created by 7 on 21/08/2017.
//  Copyright © 2017 7. All rights reserved.
//

#import "UIView+Rect.h"
#import "UIView+AnimationProperty.h"
#import "DismissAnimator.h"

@implementation DismissAnimator

- (void)animateTransitionEvent {
    [UIView animateWithDuration:self.transitionDuration animations:^{
        
        self.toViewController.view.scale = 1.f;
        self.fromViewController.view.y   = screen_height;
        
    } completion:^(BOOL finished) {
        
        [self completeTransition];
    }];
}

@end
