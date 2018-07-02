
#import "_building_precompile.h"

typedef enum : NSUInteger {
    PopViewControllerAnimateType_Default,
    PopViewControllerAnimateType_3D,
} PopViewControllerAnimateType;

@interface PopViewController : UIViewController


/**
 *  self.view 是整屏幕大小
 *
 *  一般会加载backgroundView为衬景，如带透明度的涂层
 */

#pragma mark - 显示，消失

/**
 *  显示浮层
 *
 *  @param animateType  动画类型
 *  @param startHandler 在动画前的状态初始化
 *  @param endHandler   在动画目标的状态
 */
- (void)showWithAnimateType:(PopViewControllerAnimateType)animateType animateStartBlock:(Block)startHandler animateEndBlock:(Block)endHandler;

/**
 *  浮层消失
 *
 *  @param startHandler 在动画前的状态初始化
 *  @param endHandler   在动画目标的状态
 */
- (void)dismissWithAnimateStartBlock:(Block)startHandler animateEndBlock:(Block)endHandler animateCompleteBlock:(Block)completeHandler;

#pragma mark - 3D

- (UIView *)viewShouldDisplay3D;

- (UIView *)viewShouldDisplayMask;

@end
