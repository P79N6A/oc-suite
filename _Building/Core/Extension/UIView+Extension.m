//
//  UIView+Extension.m
//  hairdresser
//
//  Created by fallen.ink on 6/8/16.
//
//

#import <OpenGLES/ES1/glext.h>
#import "_precompile.h"
#import "_geometry.h"
#import "_frame.h"
#import "_foundation.h"
#import "UIView+Extension.h"

#pragma mark - 视图关系

@implementation UIView ( Hierarchy )

- (NSUInteger)getSubviewIndex {
    return [self.superview.subviews indexOfObject:self];
}

- (void)bringToFront {
    [self.superview bringSubviewToFront:self];
}

- (void)sendToBack {
    [self.superview sendSubviewToBack:self];
}

- (void)bringOneLevelUp {
    NSUInteger currentIndex = [self getSubviewIndex];
    [self.superview exchangeSubviewAtIndex:currentIndex withSubviewAtIndex:currentIndex+1];
}

- (void)sendOneLevelDown {
    NSUInteger currentIndex = [self getSubviewIndex];
    [self.superview exchangeSubviewAtIndex:currentIndex withSubviewAtIndex:currentIndex-1];
}

- (BOOL)isInFront {
    return ([self.superview.subviews lastObject]==self);
}

- (BOOL)isAtBack {
    return ([self.superview.subviews objectAtIndex:0]==self);
}

- (BOOL)isDisplayedInScreen {
    if (self == nil) {
        return NO;
    }
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    // 转换view对应window的Rect
    CGRect rect = [self convertRect:self.frame fromView:nil];
    if (CGRectIsEmpty(rect) || CGRectIsNull(rect)) {
        return NO;
    }
    
    // 若 view 隐藏
    if (self.hidden) {
        return NO;
    }
    
    // 若没有 superview
    if (self.superview == nil) {
        return NO;
    }
    
    // 若size为CGrectZero
    if (CGSizeEqualToSize(rect.size, CGSizeZero)) {
        return  NO;
    }
    
    // 获取 该view与window 交叉的 Rect
    CGRect intersectionRect = CGRectIntersection(rect, screenRect);
    if (CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect)) {
        return NO;
    }
    
    return YES;
}

- (void)swapDepthsWithView:(UIView*)swapView {
    [self.superview exchangeSubviewAtIndex:[self getSubviewIndex] withSubviewAtIndex:[swapView getSubviewIndex]];
}

- (void)removeAllSubviews {
    // Normally.
    //    for(UIView *view in [self subviews]) {
    //        [view removeFromSuperview];
    //    }
    
    // But others.
    //    [self setSubviews:[NSArray array]]; // If subviews can be written.
    
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (UIView *)subviewWithTag:(NSUInteger)tag {
    __block UIView *v = nil;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ((v = [obj viewWithTag:tag])) {
            
            
            *stop = true;
        }
    }];
    
    return v;
}

- (void)removeSubViewByTag:(NSUInteger)tag {
    UIView *v = nil;
    if ((v = [self viewWithTag:tag])) {
        [v removeFromSuperview];
    }
}

- (void)removeSubViewWithClassType:(Class)classt {
    NSArray *allSubviews = [self subviews];
    
    for (UIView *view in allSubviews) {
        if ([view isMemberOfClass:classt]) {
            [view removeFromSuperview];
        }
    }
}

- (void)removeSubViews:(NSArray *)views {
    if (views && [views count]) {
        [views makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
}

- (BOOL)containsSubView:(UIView *)subView {
    for (UIView *view in [self subviews]) {
        if ([view isEqual:subView]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)containsSubViewOfClassType:(Class)classt {
    for (UIView *view in [self subviews]) {
        if ([view isMemberOfClass:classt]) {
            return YES;
        }
    }
    return NO;
}

- (UIView*)firstSubviewOfClass:(Class)classObj {
    NSMutableArray* allViews = [self allViewOfClass:classObj];
    [allViews removeObject:self];
    return allViews.count == 0 ? nil : allViews[0];
}

// 递归查找所有子视图（包含自身）
- (void)findAllViewWithRootView:(UIView *)rootView resultArray:(NSMutableArray*)resultArray {
    if (rootView == nil) {
        return;
    }
    [resultArray addObject:rootView];
    for (UIView *aview in [rootView subviews]){
        [self findAllViewWithRootView:aview resultArray:resultArray];
    }
}

- (NSMutableArray*)allViewOfClass:(Class)viewClass {
    NSMutableArray* resultArray = [NSMutableArray new];
    [self findAllViewWithRootView:self resultArray:resultArray];
    if (viewClass) {
        NSMutableArray* filteredArray = [NSMutableArray new];
        for (UIView* view in resultArray) {
            if ([view isMemberOfClass:viewClass]) {
                [filteredArray addObject:view];
            }
        }
        return filteredArray;
    } else {
        return resultArray;
    }
}

- (UIViewController*)firstTopViewController {
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    for (UIResponder* responder = self.nextResponder; responder != window; responder = responder.nextResponder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)responder;
        }
    }
    return nil;
}

#pragma mark - 

- (id)findSubViewWithSubViewClass:(Class)clazz {
    for (id subView in self.subviews) {
        if ([subView isKindOfClass:clazz]) {
            return subView;
        }
    }
    
    return nil;
}

- (id)findSuperViewWithSuperViewClass:(Class)clazz {
    if (self == nil) {
        return nil;
    } else if (self.superview == nil) {
        return nil;
    } else if ([self.superview isKindOfClass:clazz]) {
        return self.superview;
    } else {
        return [self.superview findSuperViewWithSuperViewClass:clazz];
    }
}

- (BOOL)findAndResignFirstResponder {
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;
    }
    
    for (UIView *v in self.subviews) {
        if ([v findAndResignFirstResponder]) {
            return YES;
        }
    }
    
    return NO;
}

- (UIView *)findFirstResponder {
    if (([self isKindOfClass:[UITextField class]] || [self isKindOfClass:[UITextView class]])
        && (self.isFirstResponder)) {
        return self;
    }
    
    for (UIView *v in self.subviews) {
        UIView *fv = [v findFirstResponder];
        if (fv) {
            return fv;
        }
    }
    
    return nil;
}

- (UIViewController *)viewController {
    UIResponder *responder = self.nextResponder;
    do {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = responder.nextResponder;
    } while (responder);
    return nil;
}


@end

#pragma mark - 构造器

@implementation UIView ( Construct )

+ (instancetype)viewWithBackgroundColor:(UIColor *)color {
    UIView *view = [UIView new];
    view.backgroundColor = color;
    return view;
}

@end

#pragma mark - 图片

@implementation UIView ( Image )

- (UIImage *)imageRepresentation {
    int width = CGRectGetWidth([self bounds]);
    int height = CGRectGetHeight([self bounds]);
    
    NSInteger myDataLength = width * height * 4;
    
    // allocate array and read pixels into it.
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
    // gl renders "upside down" so swap top to bottom into new array.
    // there's gotta be a better way, but this works.
    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
    for(int y = 0; y <height; y++) {
        for(int x = 0; x <width * 4; x++) {
            buffer2[(height - 1 - y) * width * 4 + x] = buffer[y * 4 * width + x];
        }
    }
    
    // make data provider with data.
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
    
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    // then make the uiimage from that
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    return myImage;
}

- (UIImage *)image {
    CGSize  layerSize = self.layer.frame.size;
    CGFloat scale     = screen_scale;
    CGFloat opaque    = NO;
    UIGraphicsBeginImageContextWithOptions(layerSize, opaque, scale);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return screenshot;
}

- (UIImage *)imageWithRect:(CGRect)rect {
    CGFloat scale = screen_scale;
    UIImage *screenshot = [self image];
    rect = CGRectMakeScale(rect, scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([screenshot CGImage], rect);
    UIImage *croppedScreenshot = [UIImage imageWithCGImage:imageRef
                                                     scale:screenshot.scale
                                               orientation:screenshot.imageOrientation];
    CGImageRelease(imageRef);
    
    UIImageOrientation imageOrientation = [self imageOrientationWithScreenOrientation];
    return [[UIImage alloc] initWithCGImage:croppedScreenshot.CGImage
                                      scale:croppedScreenshot.scale
                                orientation:imageOrientation];
}

- (UIImageOrientation)imageOrientationWithScreenOrientation {
    UIInterfaceOrientation orientation = status_bar_orientation;
    UIImageOrientation imageOrientation = UIImageOrientationUp;
    
    switch (orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            imageOrientation = UIImageOrientationDown;
            break;
        case UIDeviceOrientationLandscapeRight:
            imageOrientation = UIImageOrientationRight;
            break;
        case UIDeviceOrientationLandscapeLeft:
            imageOrientation = UIImageOrientationLeft;
            break;
        default:
            break;
    }
    return imageOrientation;
}

@end

#pragma mark - 配置

@implementation UIView (Layer)

- (void)setBorderWidth:(CGFloat)width {
    if (width) {
        self.layer.borderWidth  = width;
    }
}

- (void)setBorderColor:(UIColor *)color {
    if (color) {
        self.layer.borderColor = [color CGColor];
    }
}

- (void)setBorderWidth:(CGFloat)width withColor:(UIColor *)color {
    [self setBorderWidth:width];
    [self setBorderColor:color];
}

// 圆角
- (void)circular:(CGFloat)radius {
    [[self layer] setCornerRadius:radius];
    [[self layer] setMasksToBounds:YES];
}

- (void)circularWithoutCrop:(CGFloat)radius {
    [self.layer setCornerRadius:radius];
}

- (void)circular:(CGFloat)radius rectCorner:(UIRectCorner)type {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                               byRoundingCorners:type
                                                     cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = path.CGPath;
    self.layer.mask = maskLayer;
    
    [self setNeedsDisplay];
}

// 主题圆角：4.0
- (void)circularCorner {
    [self circular:PIXEL_4];
}

- (void)circulable {
    [self circular:MIN(self.width, self.height) / 2];
}

- (void)shadeBottomWithOffset:(CGFloat)offset {
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0, offset);
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowRadius = 1;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
}

- (void)shadowable {
//    TODO("该接口有问题")
    [self shadeBottomWithOffset:4];
}

- (void)shadeTop {
    self.layer.masksToBounds = NO;
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    self.layer.shadowOpacity = 0.75;
    self.layer.shadowRadius = 2.0f;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shouldRasterize = YES; // 设置缓存
    self.layer.rasterizationScale = [UIScreen mainScreen].scale; // 设置抗锯齿边缘
    
    CGSize size = self.frame.size;
    UIBezierPath* path = [UIBezierPath bezierPath];
    
    // top line
    [path moveToPoint:CGPointZero];
    [path addLineToPoint:CGPointMake(size.width, 0.0f)];
    [path closePath];
    
    self.layer.shadowPath = path.CGPath;
}

- (void)shadeBottom {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.masksToBounds = NO;
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    self.layer.shadowOpacity = 0.75;
    self.layer.shadowRadius = 2.0f;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shouldRasterize = YES; // 设置缓存
    self.layer.rasterizationScale = [UIScreen mainScreen].scale; // 设置抗锯齿边缘
    
    CGSize size = self.frame.size;
    UIBezierPath* path = [UIBezierPath bezierPath];
    
    // bottom line
    [path moveToPoint:CGPointMake(0, size.height)];
    [path addLineToPoint:CGPointMake(size.width, size.height)];
    [path closePath];
    
    self.layer.shadowPath = path.CGPath;
}

- (void)shadeAround {
    [self shadeAroundwithColor:[UIColor blackColor] depth:2.0f];
}

- (void)shadeAroundwithColor:(UIColor *)color depth:(CGFloat)depth {
    self.layer.shadowColor = color.CGColor;
    self.layer.masksToBounds = NO;
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    self.layer.shadowOpacity = 0.1;
    self.layer.shadowRadius = depth;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shouldRasterize = YES; // 设置缓存
    self.layer.rasterizationScale = [UIScreen mainScreen].scale; // 设置抗锯齿边缘
    
    //    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath; // UICollectionViewCell 加上这段，有问题
}

@end

#pragma mark - 视图递归操作

@implementation UIView (ViewRecursion)

- (void)runBlockOnAllSubviews:(SubviewBlock)block {
    block(self);
    for (UIView *view in [self subviews]) {
        [view runBlockOnAllSubviews:block];
    }
}

- (void)runBlockOnAllSuperviews:(SuperviewBlock)block {
    block(self);
    if (self.superview) {
        [self.superview runBlockOnAllSuperviews:block];
    }
}

- (void)enableAllControlsInViewHierarchy {
    [self runBlockOnAllSubviews:^(UIView *view) {
        if ([view isKindOfClass:[UIControl class]]) {
            [(UIControl *)view setEnabled:YES];
        } else if ([view isKindOfClass:[UITextView class]]) {
            [(UITextView *)view setEditable:YES];
        }
    }];
}

- (void)disableAllControlsInViewHierarchy  {
    [self runBlockOnAllSubviews:^(UIView *view) {
        if ([view isKindOfClass:[UIControl class]]) {
            [(UIControl *)view setEnabled:NO];
        } else if ([view isKindOfClass:[UITextView class]]) {
            [(UITextView *)view setEditable:NO];
        }
    }];
}

@end

#pragma mark - 

#import "Masonry.h"

@implementation UIView ( Decorated )

- (void)mas_addRectEdgeWithStyle:(NSUInteger)style
                       thickness:(CGFloat)thickness
                           color:(UIColor *)color {
    if (style & kEdgeStyleTop) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, thickness)];
        line.backgroundColor = color;
        [self addSubview:line];
        [line bringToFront];
        
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).with.offset(0.f);
            make.leading.equalTo(self.mas_leading).with.offset(0.f);
            make.trailing.equalTo(self.mas_trailing).with.offset(0.f);
            make.height.mas_equalTo(thickness);
        }];
    }
    
    if (style & kEdgeStyleLeft) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, thickness, self.height)];
        line.backgroundColor = color;
        [self addSubview:line];
        [line bringToFront];
        
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).with.offset(0.f);
            make.leading.equalTo(self.mas_leading).with.offset(0.f);
            make.bottom.equalTo(self.mas_bottom).with.offset(0.f);
            make.width.mas_equalTo(thickness);
        }];
    }
    
    if (style & kEdgeStyleBottom) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-1, self.width, thickness)];
        line.backgroundColor = color;
        [self addSubview:line];
        [line bringToFront];
        
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom).with.offset(0.f);
            make.leading.equalTo(self.mas_leading).with.offset(0.f);
            make.trailing.equalTo(self.mas_trailing).with.offset(0.f);
            make.height.mas_equalTo(thickness);
        }];
    }
    
    if (style & kEdgeStyleRight) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(self.width-1, 0, thickness, self.height)];
        line.backgroundColor = color;
        [self addSubview:line];
        [line bringToFront];
        
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).with.offset(0.f);
            make.bottom.equalTo(self.mas_bottom).with.offset(0.f);
            make.trailing.equalTo(self.mas_trailing).with.offset(0.f);
            make.width.mas_equalTo(thickness);
        }];
    }
}

- (void)drawDashLineWithLength:(CGFloat)lineLength height:(CGFloat)lineHeight spacing:(CGFloat)lineSpacing color:(UIColor *)lineColor {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CGRect actualLineRect = CGRectMake(self.bounds.origin.x,
                                       self.bounds.origin.y,
                                       self.bounds.size.width,
                                       lineHeight);
    
    [shapeLayer setBounds:actualLineRect];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame))];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    [shapeLayer setStrokeColor:lineColor.CGColor]; // 设置虚线颜色为blackColor
    [shapeLayer setLineWidth:CGRectGetHeight(self.frame)]; // 设置虚线宽度
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]]; // 设置线宽，线间距
    
    CGMutablePathRef path = CGPathCreateMutable(); // 设置路径
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL,CGRectGetWidth(self.frame), 0);
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    [self.layer addSublayer:shapeLayer]; // 把绘制好的虚线添加上来
}

- (void)drawLineWithStartPoint:(CGPoint)start endPoint:(CGPoint)end lineWidth:(CGFloat)width gap:(CGFloat)gap sectionLength:(CGFloat)length color:(UIColor *)color isVirtual:(BOOL)isVirtual {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:self.bounds];
    [shapeLayer setPosition:self.center];
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:color.CGColor];
    [shapeLayer setLineWidth:width];
    [shapeLayer setLineJoin:kCALineJoinRound];
    if (isVirtual) { // 如果是虚线
        [shapeLayer setLineDashPattern: [NSArray arrayWithObjects:[NSNumber numberWithFloat:length], [NSNumber numberWithFloat:gap], nil]];
    }
    // Setup the path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, start.x, start.y);
    CGPathAddLineToPoint(path, NULL, end.x, end.y);
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    [self.layer addSublayer:shapeLayer];
}

- (void)renderGradientWithDisplayFrame:(CGRect)frame startPoint:(CGPoint)start endPoint:(CGPoint)end colors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = frame;
    gradient.startPoint = start;
    gradient.endPoint = end;
    if (colors) {
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        for (UIColor *color in colors) {
            [temp addObject:(id)(color.CGColor)];
        }
        gradient.colors = temp;
    }
    gradient.locations = locations;
    [self.layer insertSublayer:gradient atIndex:0];
}

@end

#pragma mark - 

@implementation UIView ( Cookie )

- (id)cookie {
    return [self getAssociatedObjectForKey:"cookie"];
}

- (void)setCookie:(id)cookie {
    [self assignAssociatedObject:cookie forKey:"cookie"];
}

@end
