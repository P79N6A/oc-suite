//
//  UIPageViewController+EnableToggle.m
//  component
//
//  Created by fallen.ink on 4/7/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import "UIPageViewController+Extension.h"

@implementation UIPageViewController ( EnableToggle )

- (void)disablePageTurning {
    for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
        recognizer.enabled = NO;
    }
}

- (void)enablePageTurning {
    for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
        recognizer.enabled = YES;
    }
}

@end
