//
//  UIView+Action.h
// fallen.ink
//
//  Created by 李杰 on 3/24/15.
//
//

#import <UIKit/UIKit.h>

typedef void (^UIGestureActionBlock)(UIGestureRecognizer *gestureRecoginzer);

@interface UIView (Action)

/**
 *  onXXXXXX: (UITapGestureRecognizer *)rec
 */
- (void)addTapGestureWithTarget:(id)target action:(SEL)action;

- (void)addTapGestureWithTarget:(id)target action:(SEL)action acceptEventInterval:(NSTimeInterval)interval;

/**
 *  onXXXXXX: (UITapGestureRecognizer *)rec
 */
- (void)addDoubleTapGestureWithTarget:(id)target action:(SEL)action;

/**
 *  onXXXXXX: (UIPanGestureRecognizer *)rec
 */
- (void)addPanGestureWithTarget:(id)target action:(SEL)action;

/**
 *  onXXXXXX: (UILongPressGestureRecognizer *)rec
 *
 *  rec.state, UIGestureRecognizerStateBegan, UIGestureRecognizerStateChanged, UIGestureRecognizerStateEnded
 */
- (void)addLongPressGestureWithTarget:(id)target action:(SEL)action;

/**
 *  @brief  添加tap手势
 *
 *  @param block 代码块
 */
- (void)addTapActionWithBlock:(UIGestureActionBlock)block;

/**
 *  @brief  添加长按手势
 *
 *  @param block 代码块
 */
- (void)addLongPressActionWithBlock:(UIGestureActionBlock)block;

@end

