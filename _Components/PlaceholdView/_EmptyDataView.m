//
//  KTCEmptyDataView.m
//  KidsTC
//
//  Created by Altair on 12/5/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import "_Foundation.h"
#import "_Building.h"
#import "_EmptyDataView.h"

@interface _EmptyDataView ()

@property (nonatomic, strong) UILabel *descriptionLabel;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, copy) NSString *descriptionString;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) BOOL needGoHome;

- (void)buildSubView;

- (void)didClickedGoHomeButton;

@end

@implementation _EmptyDataView

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)img description:(NSString *)des {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.descriptionString = des;
        if (!img) {
//            img = [UIImage imageNamed:@""];
        }
        self.image = img;
        [self buildSubView];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)img description:(NSString *)des needGoHome:(BOOL)bNeed {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.descriptionString = des;
        if (!img) {
//            img = [UIImage imageNamed:@""];
        }
        self.image = img;
        self.needGoHome = bNeed;
        [self buildSubView];
    }
    return self;
}

- (void)buildSubView {
    CGFloat viewWidth = self.frame.size.width;
    CGFloat viewHeight = self.frame.size.height;
    CGFloat imageSize = 200;
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageSize, imageSize)];
    [self.imageView setCenter:CGPointMake(viewWidth / 2, viewHeight / 2 - 50)];
    [self.imageView setImage:self.image];
    [self addSubview:self.imageView];
    
    if (self.needGoHome) {
        UIButton *clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [clickButton setFrame:CGRectMake(0, self.imageView.frame.origin.y + self.imageView.frame.size.height + 20, 90, 28)];
        [clickButton setCenter:CGPointMake(self.imageView.center.x, clickButton.center.y)];
        [clickButton setTitle:@"重新加载" forState:UIControlStateNormal];
        [clickButton setTitleColor:[UIColor colorWithHexString:@"#3396F6"] forState:UIControlStateNormal];
        clickButton.layer.cornerRadius = 4;
        clickButton.layer.borderWidth = border_width;
        clickButton.layer.borderColor = [UIColor colorWithHexString:@"#3396F6"].CGColor;
        clickButton.layer.masksToBounds = YES;
        [clickButton addTarget:self action:@selector(didClickedGoHomeButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clickButton];
    } else {
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.imageView.frame.origin.y + self.imageView.frame.size.height + 10, screen_width - 40, 28)];
        [self.descriptionLabel setCenter:CGPointMake(self.imageView.center.x, self.descriptionLabel.center.y)];
        [self.descriptionLabel setTextColor:self.textColor];//AESThemeDefine_TextColor_555555];
        [self.descriptionLabel setFont:[UIFont systemFontOfSize:15]];
        [self.descriptionLabel setTextAlignment:NSTextAlignmentCenter];
        [self.descriptionLabel setBackgroundColor:[UIColor clearColor]];
        [self.descriptionLabel setText:self.descriptionString];
        [self addSubview:self.descriptionLabel];
    }
}

- (void)didClickedGoHomeButton {
    if (self.GoHomeBlock) {
        self.GoHomeBlock();
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedGoHomeButtonOnEmptyView:)]) {
        [self.delegate didClickedGoHomeButtonOnEmptyView:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
