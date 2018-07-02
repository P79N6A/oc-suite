//
//  TBAlertController.m
//
//  Created by 杨萧玉 on 15/10/29.
//  Copyright © 2015年 Tencent. All rights reserved.
//

#import "TBAlertController.h"
#import "_building_precompile.h"
#import <objc/runtime.h>

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
@interface UIViewController (TBAlertController)
@property (nonatomic,strong,nullable) TBAlertController *tbAlertController;
@end

@implementation UIViewController (TBAlertController)

@dynamic tbAlertController;

#pragma mark - AssociatedObject

- (TBAlertController *)tbAlertController
{
    return objc_getAssociatedObject(self, @selector(tbAlertController));
}

- (void)setTbAlertController:(TBAlertController *)tbAlertController
{
    objc_setAssociatedObject(self, @selector(tbAlertController), tbAlertController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSelector:@selector(presentViewController:animated:completion:) withAnotherSelector:@selector(tb_presentViewController:animated:completion:)];
    });
}

+ (void)swizzleSelector:(SEL)originalSelector withAnotherSelector:(SEL)swizzledSelector
{
    Class aClass = [self class];
    
    Method originalMethod = class_getInstanceMethod(aClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(aClass,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(aClass,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark - Method Swizzling

- (void)tb_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    if ([viewControllerToPresent isKindOfClass:[TBAlertController class]]) {
        TBAlertController* controller = (TBAlertController *)viewControllerToPresent;
        {
            ((UIAlertController *)controller.adaptiveAlert).view.tintColor = controller.tintColor;
            [self tb_presentViewController:((TBAlertController *)viewControllerToPresent).adaptiveAlert animated:flag completion:completion];
        }
    }
    else {
        [self tb_presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
}

@end

@interface TBAlertAction ()
@property (nullable, nonatomic, readwrite) NSString *title;
@property (nonatomic,readwrite) TBAlertActionStyle style;
@property (nullable,nonatomic,strong,readwrite) void (^handler)(TBAlertAction *);
@end

@implementation TBAlertAction

+ (id)actionWithTitle:(NSString *)title style:(TBAlertActionStyle)style handler:(void (^)(TBAlertAction *))handler
{
    {
        UIAlertActionStyle actionStyle = (NSInteger)style;
        return [UIAlertAction actionWithTitle:title style:actionStyle handler:(void (^)(UIAlertAction *))handler];
    }
}

@end

@interface TBAlertController() <UIActionSheetDelegate, UIAlertViewDelegate>
@property (nonnull,nonatomic,strong,readwrite) id adaptiveAlert;

@property (nonnull,nonatomic, readwrite) NSMutableArray<TBAlertAction *> *mutableActions;
@property (nonnull,nonatomic, readwrite) NSArray<TBAlertAction *> *actions;

@property (nullable, nonatomic, copy, readwrite) NSArray< void (^)(UITextField *textField)> *textFieldHandlers;

@property (nonatomic, readwrite) TBAlertControllerStyle preferredStyle;

@end

@implementation TBAlertController

- (instancetype)init
{
    self = [super init];
    if (self) {
        {
            _adaptiveAlert = [[UIAlertController alloc] init];
        }

        [self addObserver:self forKeyPath:@"view.tintColor" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"view.tintColor"];
}

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(TBAlertControllerStyle)preferredStyle
{
    TBAlertController *controller = [[TBAlertController alloc] init];
    controller.preferredStyle = preferredStyle;
    {
        controller.adaptiveAlert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(NSInteger)preferredStyle];
    }

    return controller;
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    [super dismissViewControllerAnimated:flag completion:completion];
    if ([self.adaptiveAlert isKindOfClass:[UIAlertView class]] || [self.adaptiveAlert isKindOfClass:[UIActionSheet class]]) {
        self.completion = completion;
        [self.adaptiveAlert dismissWithClickedButtonIndex:-1 animated:flag];
    }
    else if ([self.adaptiveAlert isKindOfClass:[UIAlertController class]]) {
        [self.adaptiveAlert dismissViewControllerAnimated:flag completion:completion];
    }
}

#pragma mark - getter&setter

- (NSArray<TBAlertAction *> *)actions
{
    return [self.mutableActions copy];
}

- (NSArray<UITextField *> *)textFields
{
    {
        return ((UIAlertController *)self.adaptiveAlert).textFields;
    }
}

- (NSString *)title
{
    return [self.adaptiveAlert title];
}

- (void)setTitle:(NSString *)title
{
    [self.adaptiveAlert setTitle:title];
}

- (NSString *)message
{
    return [self.adaptiveAlert message];
}

- (void)setMessage:(NSString *)message
{
    [self.adaptiveAlert setMessage:message];
}

- (UIAlertViewStyle)alertViewStyle
{
//    if (!kiOS8Later&&[self.adaptiveAlert isKindOfClass:[UIAlertView class]]) {
//        return [self.adaptiveAlert alertViewStyle];
//    }
    return 0;
}

- (void)setAlertViewStyle:(UIAlertViewStyle)alertViewStyle
{
//    if (!kiOS8Later&&[self.adaptiveAlert isKindOfClass:[UIAlertView class]]) {
//        [self.adaptiveAlert setAlertViewStyle:alertViewStyle];
//    }
}

- (TBAlertAction *)preferredAction
{
    if (system_version_iOS9_or_later) {
        return (TBAlertAction *)[self.adaptiveAlert preferredAction];
    }
    return nil;
}

- (void)setPreferredAction:(TBAlertAction *)preferredAction
{
    if (system_version_iOS9_or_later) {
        [self.adaptiveAlert setPreferredAction:preferredAction];
    }
}

- (void)addAction:(TBAlertAction *)action
{
    {
        [self.adaptiveAlert addAction:(UIAlertAction *)action];
    }
}

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField * _Nonnull))configurationHandler
{
    {
        [self.adaptiveAlert addTextFieldWithConfigurationHandler:configurationHandler];
    }
}

#pragma mark - TBActionSheetDelegate

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet
{
    if (self.completion) {
        self.completion();
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    __weak __typeof(TBAlertAction *)weakAction = self.mutableActions[buttonIndex];
    if (self.mutableActions[buttonIndex].handler) {
        self.mutableActions[buttonIndex].handler(weakAction);
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.completion) {
        self.completion();
    }
    self.ownerController.tbAlertController = nil;
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    self.ownerController.tbAlertController = nil;
}

#pragma mark - UIAlertViewDelegate

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    if (self.completion) {
        self.completion();
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    __weak __typeof(TBAlertAction *)weakAction = self.mutableActions[buttonIndex];
    if (self.mutableActions[buttonIndex].handler) {
        self.mutableActions[buttonIndex].handler(weakAction);
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.completion) {
        self.completion();
    }
    self.ownerController.tbAlertController = nil;
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    self.ownerController.tbAlertController = nil;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"view.tintColor"]) {
        self.tintColor = change[NSKeyValueChangeNewKey];
    }
}
@end
