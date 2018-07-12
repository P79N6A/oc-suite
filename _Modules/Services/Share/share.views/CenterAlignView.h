//
//  CenterAlignView.h
// fallen.ink
//
//  Created by 王涛 on 15/12/7.
//
//

#import <UIKit/UIKit.h>

@class CenterAlignView;
@protocol CenterAlignViewDelegate <NSObject>
- (void)didClickOnCenterAlignViewTitle:(NSString *)title;
@end

@interface CenterAlignView : UIView
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) float spacing;//image和title的间距
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, weak) id<CenterAlignViewDelegate>delegate;
//第一次必须使用该方法设置图片文字，以正确添加约束
- (void)setValueWithImage:(UIImage *)image AndTitle:(NSString *)title AndSpacing:(float)spacing;

@end
