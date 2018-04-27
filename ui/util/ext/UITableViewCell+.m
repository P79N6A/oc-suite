//
//  UITableViewCell+.m
//  XFAnimations
//
//  Created by fallen.ink on 11/24/15.
//  Copyright © 2015 fallen.ink. All rights reserved.
//

#import "UITableViewCell+.h"

@implementation UITableViewCell (Base)

#pragma mark - Class

+ (NSString *)identifier {
    return NSStringFromClass([self class]);
}

+ (UINib *)nib {
    return [UINib nibWithNibName:[self identifier] bundle:nil];
}

+ (CGFloat)cellHeight {
    return 0.f;
}

+ (CGFloat)cellHeightWithModel:(id)model {
    return 0.f;
}

#pragma mark - Object

- (CGFloat)cellHeight {
    return 0.f;
}

- (void)setup {
    
}

- (void)setdown:(id)data {
    
}

- (void)setModel:(id)obj {
    // do nothing.
}

#pragma mark - On UITableView

+ (void)registerOnNib:(UITableView *)tableView {
    NSAssert(tableView, @"tableView nil");
    
    [tableView registerNib:[self nib]
    forCellReuseIdentifier:[self identifier]];
}

+ (void)registerOnClass:(UITableView *)tableView {
    NSAssert(tableView, @"tableView nil");
    
    [tableView registerClass:[self class]
      forCellReuseIdentifier:[self identifier]];
}

@end
