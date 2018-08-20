//
//  PresentAnimator.m
//  monitor
//
//  Created by 7 on 21/08/2017.
//  Copyright © 2017 7. All rights reserved.
//

#import "UIView+Rect.h"
#import "UIView+AnimationProperty.h"
#import "PresentAnimator.h"

@implementation PresentAnimator

- (void)animateTransitionEvent {
    // http://stackoverflow.com/questions/25588617/ios-8-screen-blank-after-dismissing-view-controller-with-custom-presentation
    [self.containerView addSubview:self.toViewController.view];
    
    self.toViewController.view.y = screen_height;
    [UIView animateWithDuration:self.transitionDuration animations:^{
        
        self.fromViewController.view.scale = 0.95f;
        self.toViewController.view.y       = 0.f;
        
    } completion:^(BOOL finished) {
        
        [self completeTransition];
    }];
}
@end
