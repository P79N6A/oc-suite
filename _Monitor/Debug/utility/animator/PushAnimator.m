//
//  PushAnimator.m
//  monitor
//
//  Created by 7 on 21/08/2017.
//  Copyright © 2017 7. All rights reserved.
//

#import "UIView+Rect.h"
#import "UIView+AnimationProperty.h"
#import "PushAnimator.h"

@implementation PushAnimator

- (void)animateTransitionEvent {
    // http://stackoverflow.com/questions/25588617/ios-8-screen-blank-after-dismissing-view-controller-with-custom-presentation
    [self.containerView addSubview:self.toViewController.view];
    
    UIViewController *controller = (UIViewController *)self.fromViewController;
    
    self.toViewController.view.x = screen_width;
    [UIView animateWithDuration:self.transitionDuration - 0.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        controller.view.alpha        = 0.f;
        self.toViewController.view.x = 0;
        
    } completion:^(BOOL finished) {
        
        controller.view.alpha = 1.f;
        [self completeTransition];
    }];
}
@end
