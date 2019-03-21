//
//  AETextInputViewController.h
//  PingYuJiaYuan
//
//  Created by Qian Ye on 16/6/2.
//  Copyright © 2016年 Alisports. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <_Building/_Building.h>

/**
 *  判断输入内容是否合法
 *
 *  @param content 输入内容
 *
 *  @return nil则合法，否则非法，并弹出toast提示信息。信息默认为@“输入的内容不合法”，亦可将自定义信息加到userinfo中，key为kErrMsgKey
 */
typedef NSError *(^ValidationBlock)(NSString *content);

typedef void(^FinishBlock)(NSString *content);

@interface TextInputViewController : BaseViewController

@property (nonatomic, copy) NSString *showingTitle;

@property (nonatomic, copy) NSString *placeholderString;

@property (nonatomic, copy) NSString *info;

@property (nonatomic, assign) NSUInteger maxLength;

@property (nonatomic, copy) ValidationBlock validation;

@property (nonatomic, copy) FinishBlock finish;

@end
