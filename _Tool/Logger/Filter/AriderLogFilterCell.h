//
//  AriderLogFilterCell.h
//  LogTest
//
//  Created by 君展 on 13-9-14.
//  Copyright (c) 2013年 Taobao. All rights reserved.
// http://gitlab.alibaba-inc.com/junzhan/ariderlog

#import <UIKit/UIKit.h>

@interface AriderLogFilterCell : UITableViewCell
@property (nonatomic, readonly)BOOL isFilter;

/**
 *	是否过滤
 *
 *	@param 	isFilter 	是否过滤
 */
- (void)updateViewWithFilterStatus:(BOOL)isFilter;


+ (id)cellWithTableView:(UITableView *)tableView;
@end
