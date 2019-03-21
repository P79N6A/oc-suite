//
//  AriderLogConfigView.h
//  LogTest
//
//  Created by 君展 on 13-8-16.
//  Copyright (c) 2013年 Taobao. All rights reserved.
// http://gitlab.alibaba-inc.com/junzhan/ariderlog

#import <UIKit/UIKit.h>

@interface AriderLogConfigView : UIView
@property (strong, nonatomic) IBOutlet UISegmentedControl *logLevelSeg;

@property (strong, nonatomic) IBOutlet UIScrollView *logLevelScrollView;
@property (strong, nonatomic) IBOutlet UISwitch *timeSwitch;
//@property (strong, nonatomic) IBOutlet UISwitch *processSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *threadSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *fileNameSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *functionNameSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *lineNumberSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *writeIntoFileSwitch;

@property (strong, nonatomic) IBOutlet UISwitch *remoteAccessSwitch;
@property (strong, nonatomic) IBOutlet UILabel *remoteIPLabel;

@end
