//
//  AriderLogFilterPatternView.m
//  LogTest
//
//  Created by 君展 on 13-9-15.
//  Copyright (c) 2013年 Taobao. All rights reserved.
//

#import "AriderLogFilterPatternView.h"
#import "AriderLogManager.h"
#import "AriderTool.h"
@implementation AriderLogFilterPatternView

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
    
    self.wordCaseSwitch.on = [AriderLogManager sharedManager].isCaseInsensitive;
    self.completeMatchSwitch.on = [AriderLogManager sharedManager].isCompelteMatch;
}

- (void)setFrameWhenAwake{
    self.frame = CGRectMake(0, 0, [AriderTool screenWidth], [AriderTool screenHeight]-ALOG_STATUS_BAR_HEIGHT-ALOG_SEGMENT_HEIGHT*2);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self filterWithPattern:self.filterTextField.text];
    [self.filterTextField resignFirstResponder];
    return NO;
}

- (IBAction)confirmFilterButtonPress:(id)sender {
    [self filterWithPattern:self.filterTextField.text];
    [self.filterTextField resignFirstResponder];
    
    NSRegularExpressionOptions option = 0;
    if([AriderLogManager sharedManager].isCaseInsensitive){//大小写
        option = NSRegularExpressionCaseInsensitive;
    }
    
    if(self.filterTextField.text.length > 0){
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.filterTextField.text options:option error:&error];
        if(!regex){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"过滤模式串不符合正则规范" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

- (void)filterWithPattern:(NSString *)pattern{
    [AriderLogManager sharedManager].filterPattern = pattern;
}
- (IBAction)ignoreCaseChange:(UISwitch *)sender {
    [AriderLogManager sharedManager].isCaseInsensitive = sender.on;
}
- (IBAction)compeleteMatchChange:(UISwitch *)sender {
    [AriderLogManager sharedManager].isCompelteMatch = sender.on;
}
- (IBAction)filterNSLogChange:(UISwitch *)sender {
    [AriderLogManager sharedManager].isFilterSystemLog = sender.on;
}

- (IBAction)closeNSLogChange:(UISwitch *)sender {
    [AriderLogManager sharedManager].isCloseSystemLog = sender.on;
}

@end
