//
//  AriderLogFilterMethodView.h
//  LogTest
//
//  Created by 君展 on 13-9-14.
//  Copyright (c) 2013年 Taobao. All rights reserved.
// http://gitlab.alibaba-inc.com/junzhan/ariderlog

#import <UIKit/UIKit.h>
#import "AriderLogDefine.h"
@interface AriderLogFilterMethodView : UIView<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain)UITableView *tableView;
@property (nonatomic, retain)NSArray *methodNameArray;
@end
