//
//  CenterAlignView.m
// fallen.ink
//
//  Created by 王涛 on 15/12/7.
//
//

#import "_building_precompile.h"
#import "CenterAlignView.h"

@interface CenterAlignView ()

@property (nonatomic, strong) UIButton *imageButton;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation CenterAlignView

#pragma mark - Life Cycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.imageButton];
    [self addSubview:self.titleLabel];
    
}

#pragma mark - Private Method

- (void)makeConstraints {
    [self.imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(PIXEL_8);
        make.centerX.equalTo(self);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageButton.mas_bottom).offset(self.spacing);
        make.centerX.equalTo(self);
    }];
}

#pragma mark - Publish Method

- (void)setValueWithImage:(UIImage *)image AndTitle:(NSString *)title AndSpacing:(float)spacing {
    _image = image;
    _title = title;
    _spacing = spacing;
    [self.imageButton setImage:image forState:UIControlStateNormal];
    self.titleLabel.text = title;
    [self makeConstraints];
}

- (void)didClickTouchDown:(UIButton *)btn {
    self.alpha = 0.5;
}

- (void)didClickTouchUpInside:(UIButton *)btn {
    self.alpha = 1;
    if (self.delegate) {
        [self.delegate didClickOnCenterAlignViewTitle:self.title];
    }
}

#pragma mark - Setters And Getters

- (void)setImage:(UIImage *)image {
    _image = image;
    [self.imageButton setImage:image forState:UIControlStateNormal];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setFont:(UIFont *)font {
    _font = font;
    self.titleLabel.font = font;
}

- (void)setSpacing:(float)spacing {
    _spacing = spacing;
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
       make.top.equalTo(self.imageButton.mas_bottom).offset(self.spacing);
    }];
}

- (UIButton *)imageButton {
    if (!_imageButton) {
        _imageButton = [[UIButton alloc] init];
        [_imageButton addTarget:self action:@selector(didClickTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_imageButton addTarget:self action:@selector(didClickTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _imageButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _titleLabel;
}



@end
