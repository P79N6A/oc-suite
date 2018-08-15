//
//  AEDatePickerViewController.h
//  PingYuJiaYuan
//
//  Created by Qian Ye on 16/6/5.
//  Copyright © 2016年 Alisports. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FinishPickingBlock)(NSDate *pickedDate);

@interface AEDatePickerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (nonatomic, copy) FinishPickingBlock finishBlock;

+ (instancetype)showFromViewControler:(UIViewController *)controller;

@end
