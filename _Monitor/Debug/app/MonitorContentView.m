//
//  UIContent.m
//  monitor
//
//  Created by 7 on 21/08/2017.
//  Copyright © 2017 7. All rights reserved.
//

#import "MonitorContentView.h"
#import "Monitor.h"

@interface MonitorContentView ()

@end

@implementation MonitorContentView

#pragma mark - initialize

+ (UINavigationController *)withNavigation {
    return [[UINavigationController alloc]initWithRootViewController:[MonitorContentView new]];
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"调试器";
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(onClose)];
    
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    {
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
                                       
#pragma mark -

- (void)onClose {
    [[Monitor sharedInstance] dismissMonitorView];
}

#pragma mark - Table view data source & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [Monitor sharedInstance].config.sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return [Monitor sharedInstance].config.featureTitles.count;
    } else if (section == 1) {
        return [Monitor sharedInstance].config.customTitles.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat height = [self tableView:self.tableView heightForHeaderInSection:0];
    UILabel *sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 54.f, height)];
    
    NSString *sectionTitle = [Monitor sharedInstance].config.sectionTitles[section];
    
    sectionTitleLabel.text = [NSString stringWithFormat:@"  %@", sectionTitle];
    sectionTitleLabel.font = [UIFont boldSystemFontOfSize:14.f];
    sectionTitleLabel.textColor = [UIColor grayColor];
    
    return sectionTitleLabel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class) forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = [Monitor sharedInstance].config.featureTitles[indexPath.row];
    } else if (indexPath.section == 1) {
        cell.textLabel.text = [Monitor sharedInstance].config.customTitles[indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MonitorHandler *handler = nil;
    if (indexPath.section == 0) {
        handler = [Monitor sharedInstance].config.featureViewControllers[indexPath.row];
    } else if (indexPath.section == 1) {
        handler = [Monitor sharedInstance].config.customViewControllers[indexPath.row];
    }
    
    [self run:handler];
}

@end
