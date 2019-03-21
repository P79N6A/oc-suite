//
//  AriderLogDisplayView.h
//  LogTest
//
//  Created by 君展 on 13-8-16.
//  Copyright (c) 2013年 Taobao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AriderLogDisplayView : UIView
@property (strong, nonatomic) IBOutlet UITextView *logTextView;
@property (strong, nonatomic) NSMutableString *saveLogText;
@property (strong, nonatomic) IBOutlet UIButton *logClearButton;

- (void)addText:(NSString *)text textColor:(UIColor *)textColor;

- (void)clearText;
@end
