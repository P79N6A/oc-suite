//
//  PopAnimator.m
//  monitor
//
//  Created by 7 on 21/08/2017.
//  Copyright © 2017 7. All rights reserved.
//

#import "UIView+Rect.h"
#import "UIView+AnimationProperty.h"
#import "PopAnimator.h"

@implementation PopAnimator

- (void)animateTransitionEvent {
    // http://stackoverflow.com/questions/25513300/using-custom-ios-7-transition-with-subclassed-uinavigationcontroller-occasionall
    [self.containerView insertSubview:self.toViewController.view belowSubview:self.fromViewController.view];
    
    UIViewController *controller = (UIViewController *)self.toViewController;
    
    [UIView animateWithDuration:self.transitionDuration - 0.1 delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        controller.view.alpha          = 1.f;
        self.fromViewController.view.x = screen_width;
        
    } completion:^(BOOL finished) {
        
        [self completeTransition];
    }];
}

@end
