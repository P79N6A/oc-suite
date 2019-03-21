//
//  AriderLogConfigView.m
//  LogTest
//
//  Created by 君展 on 13-8-16.
//  Copyright (c) 2013年 Taobao. All rights reserved.
//

#import "AriderLogConfigView.h"
#import "AriderLogManager.h"
#import "AriderTool.h"
@implementation AriderLogConfigView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)awakeFromNib{
    [super awakeFromNib];
    [self setFrameWhenAwake];
    
    [self setupInitStatus];
}

- (void)setFrameWhenAwake{
    self.frame = CGRectMake(0, 0, [AriderTool screenWidth], ALOG_SUB_COMPONET_VIEW_HEIGHT);
    self.logLevelScrollView.frame = CGRectMake(0, 0, self.bounds.size.width, ALOG_SEGMENT_HEIGHT);
    self.logLevelSeg.frame = CGRectMake(-10, 0, 10+[AriderTool screenWidth]+10, self.logLevelSeg.bounds.size.height);
}

- (void)setupInitStatus{
    self.logLevelSeg.selectedSegmentIndex = [self segmentIndex];
    
    for(int i = 0; i < self.logLevelSeg.numberOfSegments; ++i){//解决ios8默认不可点击的
        [self.logLevelSeg setEnabled:YES forSegmentAtIndex:i];
    }
    
    self.logLevelScrollView.contentSize = CGSizeMake(self.logLevelSeg.bounds.size.width+40, self.logLevelScrollView.bounds.size.height);
    
    self.fileNameSwitch.on = [AriderLogManager sharedManager].isShowFileName;
    self.functionNameSwitch.on = [AriderLogManager sharedManager].isShowFunctionName;
    self.lineNumberSwitch.on = [AriderLogManager sharedManager].isShowLineNumber;
    self.timeSwitch.on = [AriderLogManager sharedManager].isShowTime;
    self.threadSwitch.on = [AriderLogManager sharedManager].isShowThead;
//    self.processSwitch.on = [AriderLogManager sharedManager].isShowProcess;
    self.writeIntoFileSwitch.on = [AriderLogManager sharedManager].isWriteLogIntoFile;
    self.remoteAccessSwitch.on = [AriderLogManager sharedManager].isRemoteAccess;
}

#pragma mark Segment
//此算法必须与定义level的方式相符
- (NSInteger)segmentIndex{
    NSInteger level = log2([AriderLogManager sharedManager].logLevel+1) + 0.5;
    level = self.logLevelSeg.numberOfSegments-1 - level;
    return level;
}
//此算法必须与定义level的方式相符
- (IBAction)logLevelSegmentChange:(UISegmentedControl *)sender{
    [AriderLogManager sharedManager].logLevel = (1<<(self.logLevelSeg.numberOfSegments-1-self.logLevelSeg.selectedSegmentIndex)) - 1;
}


#pragma mark Switch

- (IBAction)fileNameSwitchChange:(UISwitch *)sender {
    [AriderLogManager sharedManager].isShowFileName = sender.on;
}
- (IBAction)functionNameSwitchChange:(UISwitch *)sender {
    [AriderLogManager sharedManager].isShowFunctionName = sender.on;
}
- (IBAction)lineNumberSwitchChange:(UISwitch *)sender {
    [AriderLogManager sharedManager].isShowLineNumber = sender.on;
}
- (IBAction)timeSwitchChange:(UISwitch *)sender {
    [AriderLogManager sharedManager].isShowTime = sender.on;
}
- (IBAction)threadSwitchChange:(UISwitch *)sender {//准确的应该是线程池名称
    [AriderLogManager sharedManager].isShowThead = sender.on;
}
- (IBAction)writeIntoFileSwitchChange:(UISwitch *)sender {
    [AriderLogManager sharedManager].isWriteLogIntoFile = sender.on;
}
- (IBAction)remoteAccessSwitchChange:(UISwitch *)sender {
    [AriderLogManager sharedManager].isRemoteAccess = sender.on;
    if(sender.on){
        self.remoteIPLabel.text = [NSString stringWithFormat:@"浏览器访问%@可查看app内文件", [AriderLogManager sharedManager].remoteAccessIPAddress];
    }else{
        self.remoteIPLabel.text = @"";
    }
}
//- (IBAction)processSwitchChange:(UISwitch *)sender {
//    [AriderLogManager sharedManager].isShowProcess = sender.on;
//}

@end
