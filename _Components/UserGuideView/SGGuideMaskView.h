//
//  SGGuideMaskView.h
//  SGUserGuide
//
//  Created by soulghost on 5/7/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGGuideNode;

@interface SGGuideMaskView : UIView

@property (nonatomic, strong) SGGuideNode *node;

@property (nonatomic, assign) BOOL touchBackgroundHide; // default: NO

// 文字提示
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, assign) CGFloat textMargin;

// 图片提示
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CGFloat imageMargin; // < 0, 高亮区域以上; >= 0, 高亮区域以下。

+ (instancetype)sharedMask;

- (void)showInViewController:(UIViewController *)viewController;

- (void)hide;

@end
