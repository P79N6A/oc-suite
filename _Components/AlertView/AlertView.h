//
//  XIAlertView.h
//  XIAlertView
//
//  Created by YXLONG on 16/7/21.
//  Copyright © 2016年 yxlong. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>

/**
 *  1. message 要可以设置 attributed string
 
 *  2. main title，button titles 要可以设置颜色，字体大小
 
 *  3. 要能够自定制，中间的view
 */

extern CGFloat kDefaultCornerRadius;

typedef NS_ENUM(NSInteger, AlertActionStyle) {
    AlertActionStyleDefault = 0,
    AlertActionStyleCancel,
    AlertActionStyleDestructive
};

typedef NS_ENUM(NSInteger, CustomViewPresentationStyle) {
    Default = 0,
    MoveUp,
    MoveDown
};

@class AlertButtonItem;

@interface AlertView : UIView

@property (nonatomic, strong) UIColor *titleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *titleFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *messageColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *messageFont UI_APPEARANCE_SELECTOR;

#pragma mark - Initialize

/**
 *  @param cancelButtonTitle If nil or empty, there's no cancel button.
 */
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle;

- (instancetype)initWithTitle:(NSString *)title
                   titleColor:(UIColor *)titleColor
            attributedMessage:(NSAttributedString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
       cancelButtonTitleColor:(UIColor *)cancelButtonTitleColor;

- (void)addButtonWithTitle:(NSString *)title
                titleColor:(UIColor *)titleColor
                     style:(AlertActionStyle)style
                   handler:(void(^)(AlertView *alertView, AlertButtonItem *buttonItem))handler;

- (void)addButtonWithTitle:(NSString *)title
                     style:(AlertActionStyle)style
                   handler:(void(^)(AlertView *alertView, AlertButtonItem *buttonItem))handler;

- (void)addDefaultStyleButtonWithTitle:(NSString *)title
                               handler:(void(^)(AlertView *alertView, AlertButtonItem *buttonItem))handler;

/**
 *
 */
- (instancetype)initWithCustomView:(UIView *)customView;
- (instancetype)initWithCustomView:(UIView *)customView withPresentationStyle:(CustomViewPresentationStyle)style;

#pragma mark - Control

- (void)show;

- (void)dismiss;

@end

@interface AlertView (Creations)

+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle;

+ (instancetype)alertWithCustomView:(UIView *)customView withPresentationStyle:(CustomViewPresentationStyle)style;

@end

/**
 *  Usage
 
 *  1. 
 XIAlertView *alertView = [[XIAlertView alloc] initWithTitle:title
 message:message
 cancelButtonTitle:@"Cancel"];
 [alertView addDefaultStyleButtonWithTitle:@"Confirm" handler:^(XIAlertView *alertView, XIAlertButtonItem *buttonItem) {
 [alertView dismiss];
 }];
 [alertView show];
 
 *  2.
 XIAlertView *alertView = [[XIAlertView alloc] initWithTitle:message
 message:nil
 cancelButtonTitle:@"Cancel"];
 [alertView addDefaultStyleButtonWithTitle:@"Confirm" handler:^(XIAlertView *alertView, XIAlertButtonItem *buttonItem) {
 [alertView dismiss];
 }];
 [alertView show];
 
 *  3. 
 XIAlertView *alertView = [[XIAlertView alloc] initWithTitle:nil
 message:message
 cancelButtonTitle:@"OK"];
 [alertView show];
 
 *  4. 
 XIAlertView *alertView = [[XIAlertView alloc] initWithTitle:title
 message:message
 cancelButtonTitle:@"Cancel"];
 [alertView addDefaultStyleButtonWithTitle:@"Default" handler:^(XIAlertView *alertView, XIAlertButtonItem *buttonItem) {
 [alertView dismiss];
 }];
 [alertView addButtonWithTitle:@"Destructive" style:XIAlertActionStyleDestructive handler:^(XIAlertView *alertView, XIAlertButtonItem *buttonItem) {
 [alertView dismiss];
 }];
 [alertView show];
 
 *  5.
 message = @"You can define Swift enumerations to store associated values of any given type, and the value types can be different for each case of the enumeration if needed. Enumerations similar to these are known as discriminated unions, tagged unions, or variants in other programming languages.Like C, Swift uses variables to store and refer to values by an identifying name. Swift also makes extensive use of variables whose values cannot be changed.Swift also makes extensive use of variables whose values cannot be changed.Swift also makes extensive use of variables whose values cannot be changed.";
 XIAlertView *alertView = [[XIAlertView alloc] initWithTitle:title
 message:message
 cancelButtonTitle:@"Cancel"];
 [alertView addDefaultStyleButtonWithTitle:@"Confirm" handler:^(XIAlertView *alertView, XIAlertButtonItem *buttonItem) {
 [alertView dismiss];
 }];
 [alertView show];
 
 *  6. 
 XIAlertView *alertView = [[XIAlertView alloc] initWithTitle:title
 message:message
 cancelButtonTitle:@"Cancel"];
 [alertView addDefaultStyleButtonWithTitle:@"Confirm" handler:^(XIAlertView *alertView, XIAlertButtonItem *buttonItem) {
 [alertView dismiss];
 }];
 [alertView addButtonWithTitle:@"I don't agree" style:XIAlertActionStyleDestructive handler:^(XIAlertView *alertView, XIAlertButtonItem *buttonItem) {
 [alertView dismiss];
 }];
 [alertView show];
 
 *  7.
 XIMessageBoardView *customView = [[XIMessageBoardView alloc] initWithFrame:CGRectMake(0, 0, 280, 400) title:@"CustomView" message:@"You can define Swift enumerations to store associated values of any given type, and the value types can be different for each case of the enumeration if needed. "];
 XIAlertView *alert = [XIAlertView alertWithCustomView:customView withPresentationStyle:Default];
 __weak XIAlertView *weak_alert = alert;
 [customView setButtonActionHandler:^{
 [weak_alert dismiss];
 }];
 
 *  8.
 
 */





