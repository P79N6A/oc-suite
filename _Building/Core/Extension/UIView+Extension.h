//
//  UIView+Extension.h
//  hairdresser
//
//  Created by fallen.ink on 6/8/16.
//
//

#import <UIKit/UIKit.h>

#pragma mark - 视图关系

@interface UIView ( Hierarchy )

- (NSUInteger)getSubviewIndex;

- (void)bringToFront;
- (void)sendToBack;

- (void)bringOneLevelUp;
- (void)sendOneLevelDown;

- (BOOL)isInFront;
- (BOOL)isAtBack;
- (BOOL)isDisplayedInScreen;

- (void)swapDepthsWithView:(UIView*)swapView;

- (UIView *)subviewWithTag:(NSUInteger)tag;
- (void)removeAllSubviews;
- (void)removeSubViewByTag:(NSUInteger)tag;
- (void)removeSubViewWithClassType:(Class)classt;
- (void)removeSubViews:(NSArray *)views;

- (BOOL)containsSubView:(UIView *)subView;
- (BOOL)containsSubViewOfClassType:(Class)classt;

- (UIView *)firstSubviewOfClass:(Class)classObj; // 按类型取第一个子视图（所有层次，深度优先，不包含自身）
- (NSMutableArray *)allViewOfClass:(Class)viewClass; // 按类型过滤所有视图（所有层次，深度优先，包含自身）

- (UIViewController *)firstTopViewController;

#pragma mark - 

- (id)findSuperViewWithSuperViewClass:(Class)clazz; // 找到指定类名的SuperView对象
- (BOOL)findAndResignFirstResponder; // 找到并且resign第一响应者
- (UIView *)findFirstResponder; // 找到第一响应者
@property (readonly) UIViewController *viewController; //找到当前view所在的viewcontroler

@end

#pragma mark - 构造器

@interface UIView ( Construct )

+ (instancetype)viewWithBackgroundColor:(UIColor *)color;

@end

#pragma mark - 图片

@interface UIView ( Image )

/**
 *  生成UIView的UIImage
 *
 *  @return UIImage
 */
- (UIImage *)imageRepresentation;

- (UIImage *)image;

- (UIImage *)imageWithRect:(CGRect)rect;

- (UIImageOrientation)imageOrientationWithScreenOrientation;

@end

#pragma mark - 配置

@interface UIView (Layer)

// 设置边框
- (void)setBorderWidth:(CGFloat)width;

- (void)setBorderColor:(UIColor *)color;

- (void)setBorderWidth:(CGFloat)width withColor:(UIColor *)color;

// 圆角
- (void)circular:(CGFloat)radius;
- (void)circularWithoutCrop:(CGFloat)radius;

/**
 *  四个边角分别加远角
 *
 *  @param radius 半径
 *  @param type UIRectCornerTopLeft|UIRectCornerTopRight
 */
- (void)circular:(CGFloat)radius rectCorner:(UIRectCorner)type;

// 圆角 : 默认 4 像素
- (void)circularCorner;

// 圆形 : 默认使用当前高度计算
// +able, 因为可能是圆的，也可能需要根据实时计算
- (void)circulable;

// 阴影 : 默认 4 像素
- (void)shadowable;

- (void)shadeBottomWithOffset:(CGFloat)offset;

- (void)shadeTop;
- (void)shadeBottom;

- (void)shadeAround; // 四周加阴影
- (void)shadeAroundwithColor:(UIColor *)color depth:(CGFloat)depth;

@end

#pragma mark - 视图递归操作

typedef void (^SubviewBlock) (UIView *view);
typedef void (^SuperviewBlock) (UIView *superview);

@interface UIView (ViewRecursion)

- (void)runBlockOnAllSubviews:(SubviewBlock)block;
- (void)runBlockOnAllSuperviews:(SuperviewBlock)block;
- (void)enableAllControlsInViewHierarchy;
- (void)disableAllControlsInViewHierarchy;

@end

#pragma mark - 加特技

typedef NS_ENUM(NSUInteger, EdgeStyle) {
    kEdgeStyleTop       = 1,
    kEdgeStyleLeft      = 2,
    kEdgeStyleBottom    = 4,
    kEdgeStyleRight     = 8,
};

@interface UIView ( Decorated )

// 结合masonry自动布局，给UIView加边缘（单色，不支持渐变）
- (void)mas_addRectEdgeWithStyle:(NSUInteger)style
                       thickness:(CGFloat)thickness
                           color:(UIColor *)color;

/**
 * lineView:       需要绘制成虚线的view
 * lineLength:     虚线的宽度
 * lineSpacing:    虚线的间距
 * lineColor:      虚线的颜色
 */
- (void)drawDashLineWithLength:(CGFloat)lineLength height:(CGFloat)lineHeight spacing:(CGFloat)lineSpacing color:(UIColor *)lineColor;

/**
 *  在view上画线
 *
 *  @param start     起始点
 *  @param end       结束点
 *  @param width     宽度
 *  @param gap       虚线的间隔
 *  @param length    长度
 *  @param color     颜色
 *  @param isVirtual 是否虚线
 */
- (void)drawLineWithStartPoint:(CGPoint)start endPoint:(CGPoint)end lineWidth:(CGFloat)width gap:(CGFloat)gap sectionLength:(CGFloat)length color:(UIColor *)color isVirtual:(BOOL)isVirtual;
/**
 *  为view渲染渐变色背景
 *
 *  @param frame     显示的区域
 *  @param start     渐变起始点
 *  @param end       渐变结束点
 *  @param colors    颜色
 *  @param locations 渐变关键点
 */
- (void)renderGradientWithDisplayFrame:(CGRect)frame startPoint:(CGPoint)start endPoint:(CGPoint)end colors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations;

@end

#pragma mark - 

@interface UIView ( Cookie )

@property (nonatomic, strong) id cookie;

@end

