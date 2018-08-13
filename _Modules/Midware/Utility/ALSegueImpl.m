//
//  ALSegueImpl.m
//  wesg
//
//  Created by 7 on 24/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import "ALSportsPrecompile.h"
#import "ALSegueImpl.h"

@implementation ALSegueImpl
@synthesize animator;

- (void)push:(id)top on:(id)bottom {
    // top bottom 都是视图控制器
    if ([bottom isKindOfClass:UIViewController.class] &&
        [top isKindOfClass:UIViewController.class]) {
        UIViewController *bottomVC = bottom;
        UIViewController *topVC = top;
        
        [bottomVC.navigationController pushViewController:topVC animated:YES];
        
    }
    
    // top为AESegueModel，bottom为视图控制器
#if __has_AESegueService
    else if ([top isKindOfClass:AESegueModel.class] &&
             [top isKindOfClass:UIViewController.class]) {
        [AESegueService makeSegueWithModel:top fromController:bottom];
    }
#endif
}

- (void)present:(id)top on:(id)bottom {
    if ([bottom isKindOfClass:UIViewController.class] &&
        [top isKindOfClass:UIViewController.class]) {
        UIViewController *bottomVC = bottom;
        UIViewController *topVC = top;
        
        topVC.transitioningDelegate = self.animator;
        
        [bottomVC presentViewController:topVC animated:YES completion:nil];
    }
}

@end
