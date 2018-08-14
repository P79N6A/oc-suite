//
//  ALSegueProtocol.h
//  wesg
//
//  Created by 7 on 24/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 场景切换
@protocol _SegueProtocol <NSObject>

@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> animator;

- (void)push:(id)top on:(id)bottom;

- (void)present:(id)top on:(id)bottom;

@end
