//
//  JTSegmentView.h
//  AiXinDemo
//
//  Created by shaofa on 14-2-17.
//  Copyright (c) 2014年 shaofa. All rights reserved.
//

// JTSegment : 箭头 分区控件

// 两种工作模式
// title 固定，image 变换状态
// title 变换状态，image 变换状态

#import "JTSegmentArrowView.h"

@interface JTSegmentView : UIControl

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *images;

@property (nonatomic, assign) int selectedIndex;
@property (nonatomic, assign) JTSegmentArrowStates currentState;

/**
 images:
 @[
    @[@"state normal", @"state selected"],
    @[@"state normal", @"state selected"],
    @[@"state normal", @"state selected 1", @"state selected 2"],
  ]
 */
- (id)initWithFrame:(CGRect)frame titles:(NSArray *)titles images:(NSArray *)images;

@end


/**
 Usage:
 - (void)initJTSegmentView {
     NSArray *items = @[@"智能排序", @"空闲优先", @"价格排序"];
     NSArray *images = @[@[@"pic_place01", @"pic_place02"],
     @[@"pic_place01", @"pic_place02"],
     // 灰                下               上
     @[@"pic_place03", @"pic_place05", @"pic_place04"]];
     
     self.segementView = [[ITTSegement alloc] initWithFrame:CGRectMake(0, 0, [UIUtils screenWidth], kSortSegmentBarHeight) items:items images:images];
     [self.segementView setSelectedIndex:0];
     self.segementView.backgroundColor = [UIColor whiteColor];
     self.segementView.tintColor = [UIColor themeGreenColor];
     [self.segementView addTarget:self action:@selector(didSelectedOnSegment:) forControlEvents:UIControlEventValueChanged];
     
     [self.view addSubview:self.segementView];
 }
 
 
 - (void)didSelectedOnSegment:(ITTSegement *)sg {
     if (sg.selectedIndex == 0 && sg.currentState == SelectedStates) {
         if (self.automaticPullDownView.hidden == YES) {
            [self automaticPullDownViewShow];
         } else {
            [self automaticPullDownViewDismiss];
         }
         return;
     } else if (sg.selectedIndex == 1 && sg.currentState == SelectedStates) {
        [self.thirdListTableView headerBeginRefreshing];
     } else if (sg.selectedIndex == 2 && sg.currentState == DownStates) { // 降序
        [self.thirdListTableView headerBeginRefreshing];
     } else if (sg.selectedIndex == 2 && sg.currentState == UpStates) { // 升序
        [self.thirdListTableView headerBeginRefreshing];
     }
 }
 */
