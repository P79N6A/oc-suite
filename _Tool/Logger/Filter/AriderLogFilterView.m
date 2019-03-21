//
//  AriderLogFilterView.m
//  LogTest
//
//  Created by 君展 on 13-8-16.
//  Copyright (c) 2013年 Taobao. All rights reserved.
//

#import "AriderLogFilterView.h"
#import "AriderTool.h"
@implementation AriderLogFilterView

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
    
    [self setupContentView];
}

- (void)setFrameWhenAwake{
    self.frame = CGRectMake(0, 0, [AriderTool screenWidth], ALOG_SUB_COMPONET_VIEW_HEIGHT);
    self.contentView.frame = CGRectMake(0, ALOG_SEGMENT_HEIGHT, self.bounds.size.width, self.bounds.size.height-ALOG_SEGMENT_HEIGHT);
    
    for(int i = 0; i < self.filterSegmentControl.numberOfSegments; ++i){//解决ios8默认不可点击的
        [self.filterSegmentControl setEnabled:YES forSegmentAtIndex:i];
    }
}

- (void)setupContentView{
    self.filterPatternView = [[[NSBundle mainBundle] loadNibNamed:@"AriderLogFilterPatternView" owner:self options:nil] objectAtIndex:0];
    self.filterFileView = [[AriderLogFilterFileView alloc] initWithFrame:self.contentView.bounds];
    self.filterMethodView = [[AriderLogFilterMethodView alloc] initWithFrame:self.contentView.bounds];
    
    _filterViewArray = [[NSMutableArray alloc] initWithObjects:self.filterPatternView, self.filterFileView, self.filterMethodView, nil];
//    self.contentView.layer.borderColor = [UIColor blackColor].CGColor;
//    self.contentView.layer.borderWidth = 1;
    [self.contentView addSubview:self.self.filterPatternView];
}



- (IBAction)filterSegmentValueChange:(UISegmentedControl *)sender {
    for (UIView *sub in _filterViewArray) {
        [sub removeFromSuperview];
    }
    [self.contentView addSubview:[_filterViewArray objectAtIndex:sender.selectedSegmentIndex]];
}

@end
