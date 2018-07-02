#import "_Frame.h"

@implementation UIView ( Frame )

#pragma mark Frame

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}


- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

#pragma mark - Frame Origin

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)newX {
    CGRect newFrame = self.frame;
    newFrame.origin.x = newX;
    self.frame = newFrame;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)newY {
    CGRect newFrame = self.frame;
    newFrame.origin.y = newY;
    self.frame = newFrame;
}


#pragma mark Frame Size

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)newHeight {
    CGRect newFrame = self.frame;
    newFrame.size.height = newHeight;
    self.frame = newFrame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)newWidth {
    CGRect newFrame = self.frame;
    newFrame.size.width = newWidth;
    self.frame = newFrame;
}


#pragma mark Frame Borders

- (CGFloat)left {
    return self.x;
}

- (void)setLeft:(CGFloat)left {
    self.x = left;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    self.x = right - self.width;
}

- (CGFloat)top {
    return self.y;
}

- (void)setTop:(CGFloat)top {
    self.y = top;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    self.y = bottom - self.height;
}


#pragma mark - Center Point

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)newCenterX {
    self.center = CGPointMake(newCenterX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)newCenterY {
    self.center = CGPointMake(self.center.x, newCenterY);
}


#pragma mark Middle Point

- (CGPoint)middlePoint {
    return CGPointMake(self.middleX, self.middleY);
}

- (CGFloat)middleX {
    return self.width / 2;
}

- (CGFloat)middleY {
    return self.height / 2;
}

#pragma mark -

// inspired by https://github.com/ethercrow/UIView-position

- (void)addCenteredSubview:(UIView *)subview {
    subview.x = (int)((self.bounds.size.width - subview.frame.size.width) / 2);
    subview.y = (int)((self.bounds.size.height - subview.frame.size.height) / 2);
    
    [self addSubview:subview];
}

- (void)moveToCenterOfSuperview {
    if (!self.superview)
        NSLog(@"Trying to move view inside superview before attaching. Expect weird stuff.");
    
    self.x = (int)((self.superview.bounds.size.width - self.frame.size.width) / 2);
    self.y = (int)((self.superview.bounds.size.height - self.frame.size.height) / 2);
}

- (void)centerVerticallyInSuperview {
    if (!self.superview)
        NSLog(@"Trying to move view inside superview before attaching. Expect weird stuff.");
    
    self.y = (int)((self.superview.bounds.size.height - self.frame.size.height) / 2);
}

- (void)centerHorizontallyInSuperview {
    if (!self.superview)
        NSLog(@"Trying to move view inside superview before attaching. Expect weird stuff.");
    
    self.x = (int)((self.superview.bounds.size.width - self.frame.size.width) / 2);
}

@end

@implementation UIScrollView ( Frame)

#pragma mark Content Offset

- (CGFloat)contentOffsetX {
    return self.contentOffset.x;
}

- (CGFloat)contentOffsetY {
    return self.contentOffset.y;
}

- (void)setContentOffsetX:(CGFloat)newContentOffsetX {
    self.contentOffset = CGPointMake(newContentOffsetX, self.contentOffsetY);
}

- (void)setContentOffsetY:(CGFloat)newContentOffsetY {
    self.contentOffset = CGPointMake(self.contentOffsetX, newContentOffsetY);
}

#pragma mark Content Size

- (CGFloat)contentSizeWidth {
    return self.contentSize.width;
}

- (CGFloat)contentSizeHeight {
    return self.contentSize.height;
}

- (void)setContentSizeWidth:(CGFloat)newContentSizeWidth {
    self.contentSize = CGSizeMake(newContentSizeWidth, self.contentSizeHeight);
}

- (void)setContentSizeHeight:(CGFloat)newContentSizeHeight {
    self.contentSize = CGSizeMake(self.contentSizeWidth, newContentSizeHeight);
}

- (CGPoint)topContentOffset {
    return CGPointMake(0.0f, -self.contentInset.top);
}

- (CGPoint)bottomContentOffset {
    return CGPointMake(0.0f, self.contentSize.height + self.contentInset.bottom - self.bounds.size.height);
}

- (CGPoint)leftContentOffset {
    return CGPointMake(-self.contentInset.left, 0.0f);
}

- (CGPoint)rightContentOffset {
    return CGPointMake(self.contentSize.width + self.contentInset.right - self.bounds.size.width, 0.0f);
}

#pragma mark Content Inset

- (CGFloat)contentInsetTop {
    return self.contentInset.top;
}

- (CGFloat)contentInsetRight {
    return self.contentInset.right;
}

- (CGFloat)contentInsetBottom {
    return self.contentInset.bottom;
}

- (CGFloat)contentInsetLeft {
    return self.contentInset.left;
}

- (void)setContentInsetTop:(CGFloat)newContentInsetTop {
    UIEdgeInsets newContentInset = self.contentInset;
    newContentInset.top = newContentInsetTop;
    self.contentInset = newContentInset;
}

- (void)setContentInsetRight:(CGFloat)newContentInsetRight {
    UIEdgeInsets newContentInset = self.contentInset;
    newContentInset.right = newContentInsetRight;
    self.contentInset = newContentInset;
}

- (void)setContentInsetBottom:(CGFloat)newContentInsetBottom {
    UIEdgeInsets newContentInset = self.contentInset;
    newContentInset.bottom = newContentInsetBottom;
    self.contentInset = newContentInset;
}

- (void)setContentInsetLeft:(CGFloat)newContentInsetLeft {
    UIEdgeInsets newContentInset = self.contentInset;
    newContentInset.left = newContentInsetLeft;
    self.contentInset = newContentInset;
}

@end
