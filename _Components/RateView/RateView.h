//
//  MJGRateView.h
//  MJGFoundation
//
//  Created by Matt Galloway on 03/01/2012.
//  Copyright 2012 Matt Galloway. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RateView;

@interface RateView : UIControl

@property (nonatomic, assign) NSInteger max;
@property (nonatomic, assign) CGFloat value;

@property (nonatomic, assign) BOOL allowHalf; // 是否允许半星

- (void)setOnImage:(UIImage*)onImage offImage:(UIImage*)offImage;
- (void)setOnImage:(UIImage*)onImage halfImage:(UIImage*)halfImage offImage:(UIImage*)offImage;

@end


/**
 * Usage
    
    default image : @"star_on", @"star_off"
 
    _rateView = [[RateView alloc] initWithFrame:CGRectMake(20.0f, 20.0f, 180.0f, 60.0f)];
    _rateView.max = 5;
    _rateView.allowHalf = NO;
    [_rateView addTarget:self action:@selector(changedValue:) forControlEvents:UIControlEventValueChanged];
    [_rateView setOnImage:image_named(@"star_yellow") offImage:image_named(@"star_gray")];
    [self addSubview:_rateView];
 
    [_rateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_iconImageView.mas_trailing).offset(margin_s);
        make.centerY.equalTo(_iconImageView.mas_centerY);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(120);
    }];
 
 */
