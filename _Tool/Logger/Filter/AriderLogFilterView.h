//
//  AriderLogFilterView.h
//  LogTest
//
//  Created by 君展 on 13-8-16.
//  Copyright (c) 2013年 Taobao. All rights reserved.
// http://gitlab.alibaba-inc.com/junzhan/ariderlog

#import <UIKit/UIKit.h>
#import "AriderLogFilterFileView.h"
#import "AriderLogFilterMethodView.h"
#import "AriderLogFilterPatternView.h"
@interface AriderLogFilterView : UIView<UITextFieldDelegate>
{
    NSMutableArray *_filterViewArray;
}
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) AriderLogFilterPatternView *filterPatternView;
@property (strong, nonatomic) AriderLogFilterFileView *filterFileView;
@property (strong, nonatomic) AriderLogFilterMethodView *filterMethodView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *filterSegmentControl;
@end
