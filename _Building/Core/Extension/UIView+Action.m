//
//  UIView+Action.m
// fallen.ink
//
//  Created by 李杰 on 3/24/15.
//
//

#import "UIView+Action.h"
#import "_precompile.h"
#import "_pragma_push.h"

@interface UIView ()

@property (nonatomic, assign) BOOL ignoreSingleTapEvent;
@property (nonatomic, assign) NSTimeInterval acceptEventInterval;

@property (nonatomic, strong) NSString *singleTapActionHandlerSelector;
@property (nonatomic, strong, readonly) NSString *singleTapSwizzleActionHandlerSelector;

@end

@implementation UIView (Action)

#pragma mark -

- (void)addTapGestureWithTarget:(id)target action:(SEL)action {
    UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    recog.numberOfTapsRequired = 1;
    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:recog];
}

- (void)addTapGestureWithTarget:(id)target action:(SEL)action acceptEventInterval:(NSTimeInterval)interval {
    // 第一个参数：给哪个类添加方法
    // 第二个参数：添加方法的方法编号
    // 第三个参数：添加方法的函数实现（函数地址）
    // 第四个参数：函数的类型，(返回值+参数类型) v:void @:对象->self :表示SEL->_cmd
    class_addMethod(((NSObject *)target).class, NSSelectorFromString(self.singleTapSwizzleActionHandlerSelector), (IMP)onSingleTap, "v@:@");
    
    UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc] initWithTarget:target action:NSSelectorFromString(self.singleTapSwizzleActionHandlerSelector)];
    recog.numberOfTapsRequired = 1;
    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:recog];
    
    // Back up real selector
    self.singleTapActionHandlerSelector = NSStringFromSelector(action);
}

- (void)addDoubleTapGestureWithTarget:(id)target action:(SEL)action {
    UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    recog.numberOfTapsRequired = 2;
    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:recog];
}

- (void)addPanGestureWithTarget:(id)target action:(SEL)action {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:action];
    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:pan];
}

- (void)addLongPressGestureWithTarget:(id)target action:(SEL)action {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:action];
    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:longPress];
}

#pragma mark -

void onSingleTap(id self, SEL sel, UITapGestureRecognizer *recognizer) {
    UIView *view = recognizer.view;
    
    if (view.ignoreSingleTapEvent) {
        LOG(@"ignoreSingleTapEvent triggered!");
        
        return;
    }
    
    view.ignoreSingleTapEvent = YES;
    [view performSelector:@selector(setIgnoreSingleTapEvent:) withObject:@(NO) afterDelay:1.f];
    
    [self performSelector:NSSelectorFromString(view.singleTapActionHandlerSelector) withObject:recognizer];
}

#pragma mark -

- (BOOL)ignoreSingleTapEvent {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setIgnoreSingleTapEvent:(BOOL)ignoreSingleTapEvent {
    objc_setAssociatedObject(self, @selector(ignoreSingleTapEvent), @(ignoreSingleTapEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)acceptEventInterval {
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}

- (void)setAcceptEventInterval:(NSTimeInterval)acceptEventInterval {
    objc_setAssociatedObject(self, @selector(acceptEventInterval), @(acceptEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)singleTapSwizzleActionHandlerSelector {
    return @"onSingleTapActionHandler:";
}

- (NSString *)singleTapActionHandlerSelector {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSingleTapActionHandlerSelector:(NSString *)singleTapActionHandlerSelector {
    objc_setAssociatedObject(self, @selector(singleTapActionHandlerSelector), singleTapActionHandlerSelector, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

- (void)addTapActionWithBlock:(UIGestureActionBlock)block {
    self.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *gesture = objc_getAssociatedObject(self, @selector(addTapActionWithBlock:));
    if (!gesture) {
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleActionForTapGesture:)];
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, @selector(addTapActionWithBlock:), gesture, OBJC_ASSOCIATION_RETAIN);
    }
    
    objc_setAssociatedObject(self, @selector(handleActionForTapGesture:), block, OBJC_ASSOCIATION_COPY);
}

- (void)handleActionForTapGesture:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        UIGestureActionBlock block = objc_getAssociatedObject(self, @selector(handleActionForTapGesture:));
        if (block) {
            block(gesture);
        }
    }
}

- (void)addLongPressActionWithBlock:(UIGestureActionBlock)block {
    self.userInteractionEnabled = YES;
    
    UILongPressGestureRecognizer *gesture = objc_getAssociatedObject(self, @selector(addLongPressActionWithBlock:));
    if (!gesture) {
        gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleActionForLongPressGesture:)];
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, @selector(addLongPressActionWithBlock:), gesture, OBJC_ASSOCIATION_RETAIN);
    }
    
    objc_setAssociatedObject(self, @selector(handleActionForLongPressGesture:), block, OBJC_ASSOCIATION_COPY);
}

- (void)handleActionForLongPressGesture:(UITapGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        UIGestureActionBlock block = objc_getAssociatedObject(self, @selector(handleActionForLongPressGesture:));
        
        if (block) {
            block(gesture);
        }
    }
}

@end

#import "_pragma_pop.h"
