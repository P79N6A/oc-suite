//
//  AriderLogFilterFileView.m
//  LogTest
//
//  Created by 君展 on 13-9-14.
//  Copyright (c) 2013年 Taobao. All rights reserved.
//

#import "AriderLogFilterFileView.h"
#import "AriderLogFilterCell.h"
#import "AriderLogManager.h"
@implementation AriderLogFilterFileView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findNewFileNameNotification:) name:(NSString *)kAriderLogFindNewFileNameNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark super

- (void)didMoveToSuperview{
    [self updateViewWithFileNameSet:[AriderLogManager sharedManager].saveFileNameSet];
}

- (void)findNewFileNameNotification:(NSNotification *)notification{
    [self updateViewWithFileNameSet:[AriderLogManager sharedManager].saveFileNameSet];
}

#pragma mark setup
- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
        _tableView.tableHeaderView = [self tableHeaderView];
    }
    return _tableView;
}

- (UIView *)tableHeaderView{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 25)];
    label.text = @"可以勾选行,被勾选的行对应的文件代码内所产生的日志将会被忽略";
    label.adjustsFontSizeToFitWidth = YES;
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (void)updateViewWithFileNameSet:(NSSet *)fileNameSet{
    self.fileNameArray = [[fileNameSet allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    [self.tableView reloadData];
}

- (BOOL)isFilterAtIndexPath:(NSIndexPath *)indexPath{
    NSString *currentFileName = [self fileNameAtIndexPath:indexPath];
    if([[AriderLogManager sharedManager].filterFileNameSet containsObject:currentFileName]){//如果被过滤
        return YES;
    }else{
        return NO;
    }
}

- (NSString *)fileNameAtIndexPath:(NSIndexPath *)indexPath{
    NSString *currentFileName = [self.fileNameArray objectAtIndex:indexPath.row];
    return currentFileName;
}

#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fileNameArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AriderLogFilterCell *cell = [AriderLogFilterCell cellWithTableView:tableView];
    //如果过滤该行则打钩
    [cell updateViewWithFilterStatus:[self isFilterAtIndexPath:indexPath]];
    cell.textLabel.text = [self fileNameAtIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AriderLogFilterCell *cell = (AriderLogFilterCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    BOOL isFilter = !cell.isFilter;
    
    if(isFilter){//过滤该行
        [[AriderLogManager sharedManager].filterFileNameSet addObject:[self fileNameAtIndexPath:indexPath]];
    }else{
        [[AriderLogManager sharedManager].filterFileNameSet removeObject:[self fileNameAtIndexPath:indexPath]];
    }
    //更新视图
    [cell updateViewWithFilterStatus:isFilter];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
