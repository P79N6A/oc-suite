//
//  AriderLogDisplayView.m
//  LogTest
//
//  Created by 君展 on 13-8-16.
//  Copyright (c) 2013年 Taobao. All rights reserved.
//

#import "AriderLogDisplayView.h"
#import "AriderLogManager.h"
#import "AriderTool.h"
#define EPS 1e-8
#define MAX_LOG_LENGTH 1024*100
@implementation AriderLogDisplayView


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//打开时显示,并滑动到最底边
- (void)showLogComponetView:(NSNotification *)notification{
    [self updateTextView];
    [self scrollToBottom];
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setFrameWhenAwake];
    
    self.logTextView.editable = NO;
    self.saveLogText = [[NSMutableString alloc] initWithCapacity:MAX_LOG_LENGTH];//1MB
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLogComponetView:) name:(NSString *)kAriderLogShowLogComponetView object:nil];
}

- (void)setFrameWhenAwake{
    self.frame = CGRectMake(0, 0, [AriderTool screenWidth], ALOG_SUB_COMPONET_VIEW_HEIGHT);
    self.logTextView.frame = self.bounds;
    self.logClearButton.frame = CGRectMake(self.bounds.size.width-self.logClearButton.bounds.size.width-20, self.logClearButton.frame.origin.y, self.logClearButton.frame.size.width, self.logClearButton.frame.size.height);
}

- (void)addText:(NSString *)text textColor:(UIColor *)textColor{
    if(!text){
        return ;
    }
    if(self.saveLogText.length > MAX_LOG_LENGTH){//避免太大
        [self clearText];
    }
    [self.saveLogText appendString:@"\n"];//换行
    [self.saveLogText appendString:text];
    if([AriderLogManager sharedManager].isShowLogView){//只有被显示时
        [self updateTextView];
    }
}

- (void)updateTextView{
    BOOL isBottomNearby = NO;
    if (self.logTextView.contentOffset.y + self.logTextView.bounds.size.height
        >= self.logTextView.contentSize.height - self.logTextView.bounds.size.height) {
        isBottomNearby = YES;
    }
    
    self.logTextView.text = self.saveLogText;
    [self.logTextView setNeedsDisplay];
    if(isBottomNearby){
//        [self performSelector:@selector(scrollToBottom) withObject:nil afterDelay:1];
        [self scrollToBottom];
        
    }
}

- (void)clearText{
    [self.saveLogText setString:@""];
    self.logTextView.text = @"";
    [self updateTextView];
}
- (IBAction)clearButtonPress:(id)sender {
    [self clearText];
}

- (void)scrollToBottom{
    if(self.logTextView.text.length > 0){
//        NSRange range = NSMakeRange(self.logTextView.text.length-1, 1);//length-1，若length为0会导致溢出，低概率crash.
//        [self.logTextView scrollRangeToVisible:range];//有概率出现异常:-[NSString rangeOfComposedCharacterSequenceAtIndex:] + 88. 可能是某些特殊字符导致text.legnth与Character长度有差别
    
        CGFloat y = self.logTextView.contentSize.height-self.logTextView.frame.size.height;
        if(y < 0){
            y = 0;
        }
        [self.logTextView scrollRectToVisible:CGRectMake(0, y, self.logTextView.frame.size.width, self.logTextView.frame.size.height) animated:NO];
        
        [self.logTextView flashScrollIndicators];//显示条
    }
}

- (NSString *)htmlColorFromUIColor:(UIColor *)color{
    CGFloat r=0, g=0, b=0;
    
    BOOL res =  [color getRed:&r green:&g blue:&b alpha:0];
    if(!res){
        CGColorRef cgColor = [color CGColor];
        size_t numComponents = CGColorGetNumberOfComponents(cgColor);
        if (numComponents == 4)
        {
            const CGFloat *components = CGColorGetComponents(cgColor);
            r = components[0];
            g = components[1];
            b = components[2];
        }
    }
    return [NSString stringWithFormat:@"#%02x%02x%02x", (int)(r*255), (int)(g*255), (int)(b*255)];
}

@end
