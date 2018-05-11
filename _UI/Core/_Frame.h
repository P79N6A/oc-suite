#import <UIKit/UIKit.h>

@interface UIView ( Frame )

// Frame
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;

// Frame Origin
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;

// Frame Size
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

// Frame Borders
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat right;

// Center Point
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

// Middle Point
@property (nonatomic, readonly) CGPoint middlePoint;
@property (nonatomic, readonly) CGFloat middleX;
@property (nonatomic, readonly) CGFloat middleY;

// Syntax sugar
- (void)addCenteredSubview:(UIView *)subview;
- (void)moveToCenterOfSuperview;
- (void)centerVerticallyInSuperview;
- (void)centerHorizontallyInSuperview;

@end

@interface UIScrollView ( Frame )

// Content Offset
@property (nonatomic) CGFloat contentOffsetX;
@property (nonatomic) CGFloat contentOffsetY;

// Content Size
@property (nonatomic) CGFloat contentSizeWidth;
@property (nonatomic) CGFloat contentSizeHeight;

// Content Inset
@property (nonatomic) CGFloat contentInsetTop;
@property (nonatomic) CGFloat contentInsetLeft;
@property (nonatomic) CGFloat contentInsetBottom;
@property (nonatomic) CGFloat contentInsetRight;

@property (nonatomic, readonly) CGPoint topContentOffset;
@property (nonatomic, readonly) CGPoint bottomContentOffset;
@property (nonatomic, readonly) CGPoint leftContentOffset;
@property (nonatomic, readonly) CGPoint rightContentOffset;

@end
