//
//  JHUDAnimationView.h
//  JHudViewDemo
//
//  Created by 晋先森 on 16/7/16.
//  Copyright © 2016年 晋先森. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, _WebHUDAnimationType) {
    _WebHUDAnimationTypeCircle = 0,
    _WebHUDAnimationTypeCircleJoin,
    _WebHUDAnimationTypeDot,
};

@interface _WebHUDAnimationView : UIView

@property (nonatomic,assign) NSInteger  count;

@property (nonatomic) UIColor  *defaultBackGroundColor;//

@property (nonatomic) UIColor  *foregroundColor;

- (void)showAnimationAtView:(UIView *)view animationType:(_WebHUDAnimationType)animationType;

- (void)removeSubLayer;

@end

