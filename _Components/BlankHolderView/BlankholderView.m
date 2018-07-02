
#import "_building_precompile.h"
#import "BlankholderView.h"

@interface BlankholderView ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) UILabel *leaveoutLabel;

@property (nonatomic, strong) NSString *failureText;

@end

@implementation BlankholderView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // layout imageView
    CGSize size = self.image.size;
    self.imageView.frame = CGRectMake(0, 0, size.width, size.height);
    self.imageView.center = CGPointMake(self.width/2, 120.f);
    
    // layout textLabel
    int numbersOfLine = [self.text linesWithFont:self.textLabel.font constrainedToWidth:screen_width];
    self.textLabel.frame = CGRectMake(0, 0, self.width, PIXEL_24*numbersOfLine);
    self.textLabel.center = CGPointMake(self.width/2, self.imageView.bottom+PIXEL_16*numbersOfLine);
    
    // layout leaveoutLabel
    self.leaveoutLabel.frame = CGRectMake(0, 0, self.width, PIXEL_24);
    self.leaveoutLabel.center = CGPointMake(self.width/2, self.textLabel.bottom+PIXEL_12);
}

#pragma mark - Setter / Getter

- (void)setImage:(UIImage *)image {
    _image = image;
    
    self.imageView.image = image;
    
    [self setNeedsLayout];
}

- (void)setText:(NSString *)text {
    _text = text;
    
    self.textLabel.text = text;
    
    [self setNeedsLayout];
}

- (void)setIsError:(BOOL)isError {
    _isError = isError;
    
    self.failureText = @"数据加载失败";
    
    exceptioning(@"未开发完")
}

- (void)setShowLeaveoutPoint:(BOOL)showLeaveoutPoint {
    _showLeaveoutPoint = showLeaveoutPoint;
    
    self.leaveoutLabel.hidden = !_showLeaveoutPoint;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        
        [self addSubview:_imageView];
    }
    
    return _imageView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 0;
        _textLabel.font = font_m;
        _textLabel.textColor = font_gray_2;
        _textLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_textLabel];
    }
    
    return _textLabel;
}

- (UILabel *)leaveoutLabel {
    if (!_leaveoutLabel) {
        _leaveoutLabel = [[UILabel alloc] init];
        _leaveoutLabel.textAlignment = NSTextAlignmentCenter;
        _leaveoutLabel.font = font_m;
        _leaveoutLabel.textColor = font_gray_2;
        _leaveoutLabel.text = @"······";
        _leaveoutLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_leaveoutLabel];
    }
    
    return _leaveoutLabel;
}

@end
