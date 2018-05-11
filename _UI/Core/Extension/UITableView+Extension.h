//
//  UITableView+Extension.h
//  component
//
//  Created by fallen.ink on 4/13/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "_precompile.h"
#import "UITableViewCell+Extension.h"

#pragma mark -

@class TBTableUpdate;

@interface UITableView (Extension)
- (void)performUpdate:(TBTableUpdate *)update;
- (void)performUpdate:(TBTableUpdate *)update deleteAnimation:(UITableViewRowAnimation)deleteAnimation insertAnimation:(UITableViewRowAnimation)insertAnimation;

- (void)insertRow:(NSUInteger)row inSection:(NSUInteger)section;
- (void)reloadRow:(NSUInteger)row inSection:(NSUInteger)section;
- (void)deleteRow:(NSUInteger)row inSection:(NSUInteger)section;
- (void)insertSection:(NSUInteger)section;
- (void)reloadSection:(NSUInteger)section;

// Scroll to top include tableHeaderView
- (void)autoScrollToTop;

- (void)autoScrollToTopWithoutTableHeaderView;

@end

@interface TBTableUpdate : NSObject

+ (instancetype)firstSectionInsert:(NSIndexSet *)insert delete:(NSIndexSet *)remove moveFrom:(NSIndexSet *)from moveTo:(NSIndexSet *)to reload:(NSIndexSet *)reload;
+ (instancetype)updateInsert:(NSArray *)insert delete:(NSArray *)remove moveFrom:(NSArray *)from moveTo:(NSArray *)to reload:(NSArray *)reload;
+ (instancetype)updateFromDataSource:(NSArray *)initial toDataSource:(NSArray *)final;

@property (nonatomic, readonly) NSArray *insert;
@property (nonatomic, readonly) NSArray *remove;
@property (nonatomic, readonly) NSArray *move;
@property (nonatomic, readonly) NSArray *reload;

@end

#pragma mark - 

@interface UITableView ( Config )

- (void)normally; // 自以为是的常规管理配置

- (void)setFixedRowHeight:(CGFloat)height; // 如果你展示在每个cell的高度是固定的，那么heightForRow是不建议让代理去实现的，而是通过tableView的rowHeight属性来代替

// 详细配置

- (void)trimBlankCells; // 去除多余的横线

- (void)noneSeparator; // 去除分割线

- (void)noneScrollIndicator;

/**
 *  使用该方法
    1. 不能使用自动约束
    2. UITableView 要代码创建
 
 *  Usage:
 
    1. UITableView 设置
 
        CGRect tableViewRect = CGRectMake(0, 0, OrderTimeSelectCellHeight, screen_width);
        self.tableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStylePlain];
        [self.contentView addSubview:self.tableView];

        [self.tableView normally];

        self.tableView.frame = CGRectMake(0, 0, OrderTimeSelectCellHeight, screen_width);
        self.tableView.center = CGPointMake(screen_width / 2, OrderTimeSelectCellHeight / 2);
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

        [self.tableView rotateToHorizontalScrollable];

        [self.tableView noneSeparator];
        [self.tableView setFixedRowHeight:83.f];

        [self.tableView registerNib:[TimeSelectCell nib] forCellReuseIdentifier:[TimeSelectCell identifier]];
 
    2. UITableView 的delegate、dataSource
 
        - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
            return 1;
        }

        - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
            return 14;
        }

        - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
            TimeSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:[TimeSelectCell identifier] forIndexPath:indexPath];
            [cell noneSelection];

            [cell setModel:nil];

            return cell;
        }

        - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
            [self.delegate onSelectDate:@"20160910:1400"];
        }
 
    3. UITableViewCell 设置
 
        3.1 UITableViewCell 代码创建
            - (UITableViewCell *)tableView :( UITableView *)aTableView cellForRowAtIndexPath :(NSIndexPath *)indexPath {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier"];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier@"identifier"];
         
                // cell顺时针旋转90度
                [cell rotateToHorizontalScrollable]; // 注意！！！
            }
         
            return cell;
            }
     
        3.2 UITableViewCell Xib创建
     
            - (void)awakeFromNib {
                [super awakeFromNib];

                [self rotateToHorizontalScrollable];
            }
         
            - (void)layoutSubviews {
                [super layoutSubviews];

                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, cell宽度, cell高度); // http://www.360doc.com/content/13/0930/15/8772388_318187088.shtml
            }
 */
- (void)rotateToHorizontalScrollable; // 旋转，可用于实现横向选择列表，对应Cell也需要rote，如：

/**
 *  Usage
 
 -(void)viewDidLayoutSubviews
 {
 if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
 [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
 }
 
 if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
 [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
 }
 }
 -(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
 [cell setSeparatorInset:UIEdgeInsetsZero];
 }
 if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
 [cell setLayoutMargins:UIEdgeInsetsZero];
 }
 }
 */
- (void)noneSeparatorHeadingMarginSpace; // 分割线磨人开头空15像素点，改为0

/**
 *  Usage 
 * 
 *  这两行代码必须配合约束来使用
 *
 */
- (void)autoEstimateRowHeightWithPrefered:(CGFloat)height;

- (void)updateTableViewWithIndexPath:(NSIndexPath *)indexPath handlingBlock:(ObjectBlock)handlingBlock;

- (void)updateTableViewWithHandlingBlock:(Block)handlingBlock;

@end

#pragma mark - 

@interface UITableView ( Instance )

+ (instancetype)instanceWithDelegate:(id<UITableViewDelegate>)delegate dataSource:(id<UITableViewDataSource>)dataSource background:(UIColor *)background;

@end


