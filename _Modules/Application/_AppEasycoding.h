//
//  _app_easycoding.h
//  student
//
//  Created by fallen.ink on 05/10/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

#import "_precompile.h"
#import "UIView+.h"
#import "UITableViewCell+.h"
#import "UICollectionViewCell+.h"
#import "UIViewController+.h"

// ----------------------------------
// MARK: Extension - NSObject (Easy)
// ----------------------------------

@interface NSObject (Easy)

#pragma mark Success / Error / Progress

- (void)showSuccess:(NSString *)message;
- (void)showError:(NSString *)message;
- (void)showInfo:(NSString *)message;

- (void)showProgress;
- (void)showProgressTitle:(NSString *)title;
- (void)increaseProgress:(CGFloat)progress;

#pragma mark - Hud - heads up display

- (void)hideActivityHUD;
- (void)showActivityHUD;

#pragma mark - Toast

- (void)showToastWithText:(NSString *)text;

#pragma mark - AlertView

- (void)showAlertView:(NSString *)title message:(NSString *)message cancelButtonName:(NSString *)name cancelHandler:(Block)cancelHandler;
+ (void)showAlertView:(NSString *)title message:(NSString *)message cancelButtonName:(NSString *)name;
- (void)showAlertView:(NSString*)title message:(NSString*)message :(NSString*)enterStr DEPRECATED;

#pragma mark - Initializer

- (void)initDefault;
- (void)initObserver;
- (void)uinitObserver;

#pragma mark - TableView setup fresh

- (void)setupRefreshWithTarget:(id)target head:(SEL)headerRefreshingHandler foot:(SEL)footerRefreshingHandler;

@end


// ----------------------------------
// MARK: Interface
// ----------------------------------

@interface _AppEasycoding : NSObject

@end

// ----------------------------------
// MARK: Extension - UIViewController ( Handler )
// ----------------------------------

@interface UIViewController ( Handler )

@property (nonatomic, strong, readonly) ErrorBlock failureHandler;

@end

