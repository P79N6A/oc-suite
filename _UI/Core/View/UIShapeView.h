//
//  ShapeView.h
//  hairdresser
//
//  Created by fallen.ink on 9/5/16.
//
//

/**
 *  纯图形View
 
    1. 三角形
    2. 圆形
    3. 两边圆，中间矩形
 */

#import <UIKit/UIKit.h>

@interface ShapeView : UIView

#pragma mark -

- (void)initViews;

@end

#pragma mark - Triangle

typedef NS_ENUM(NSUInteger, DrawTriangleStyle) {
    DrawTriangleStyle_Top,          //箭头在顶部
    DrawTriangleStyle_Bottom,       //箭头在底部
    DrawTriangleStyle_Left,         //箭头在左边
    DrawTriangleStyle_Right,        //箭头在右边
};


//NOTE 在绘制前，应设置好triangleStyle、triangleFillColor、backgroundColor三个属性

@interface TriangleView : ShapeView

@property (assign,nonatomic) DrawTriangleStyle triangleStyle;
@property (strong,nonatomic) UIColor *fillColor;

@end

#pragma mark - Circle

@interface CircleView : ShapeView

/**
 *  通过UIBezierPath对象设置带圆角的作图区域,只有一次rending pass，效率最高
 */

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;

@end

#pragma mark -



