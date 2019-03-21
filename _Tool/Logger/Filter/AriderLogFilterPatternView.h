//
//  AriderLogFilterPatternView.h
//  LogTest
//
//  Created by 君展 on 13-9-15.
//  Copyright (c) 2013年 Taobao. All rights reserved.
// http://gitlab.alibaba-inc.com/junzhan/ariderlog

#import <UIKit/UIKit.h>

@interface AriderLogFilterPatternView : UIView
@property (strong, nonatomic) IBOutlet UITextField *filterTextField;
@property (strong, nonatomic) IBOutlet UISwitch *wordCaseSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *completeMatchSwitch;

@end
