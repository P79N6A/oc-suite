//
//  EICheckBox.h
//  EInsure
//
//  Created by ivan on 13-7-9.
//  Copyright (c) 2013年 ivan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CheckBoxDelegate;

@interface CheckBox : UIButton {
    __weak id<CheckBoxDelegate> _delegate;
    BOOL _checked;
    id _userInfo;
}

@property (nonatomic, weak) id<CheckBoxDelegate> delegate;
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, strong) id userInfo;

// @required
- (id)initWithDelegate:(id)delegate;
// @required
- (void)initWithImage:(NSString *)normal selected:(NSString *)selected;

@end

@protocol CheckBoxDelegate <NSObject>

@optional

- (void)didSelectedCheckBox:(CheckBox *)checkbox checked:(BOOL)checked;

@end
