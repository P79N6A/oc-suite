//
//  UISurePlaceholderView.m
//  student
//
//  Created by fallen.ink on 08/10/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "_SurePlaceholdView.h"

@interface UISurePlaceholderView ()

@property (nonatomic, strong) UIButton *reloadButton;

@end

@implementation UISurePlaceholderView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundColor = [UIColor whiteColor];
    [self createUI];
}

- (void)createUI {
    
    [self addSubview:self.reloadButton];
}

- (UIButton*)reloadButton {
    if (!_reloadButton) {
        _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _reloadButton.frame = CGRectMake(0, 0, 150, 150);
        _reloadButton.center = self.center;
        _reloadButton.layer.cornerRadius = 75.0;
        [_reloadButton setBackgroundImage:[UIImage imageNamed:@"no_content"] forState:UIControlStateNormal];
        [_reloadButton setTitle:@"暂时没有相关信息哦~" forState:UIControlStateNormal];
        [_reloadButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_reloadButton setTitleEdgeInsets:UIEdgeInsetsMake(200, -50, 0, -50)];
        [_reloadButton addTarget:self action:@selector(reloadClick:) forControlEvents:UIControlEventTouchUpInside];
        CGRect rect = _reloadButton.frame;
        rect.origin.y -= 50;
        _reloadButton.frame = rect;
    }
    return _reloadButton;
}

- (void)reloadClick:(UIButton*)button {
    if (self.reloadClickBlock) {
        self.reloadClickBlock();
    }
}


@end
