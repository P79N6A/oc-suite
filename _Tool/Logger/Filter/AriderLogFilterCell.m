//
//  AriderLogFilterCell.m
//  LogTest
//
//  Created by 君展 on 13-9-14.
//  Copyright (c) 2013年 Taobao. All rights reserved.
//

#import "AriderLogFilterCell.h"

@implementation AriderLogFilterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textLabel.font = [UIFont systemFontOfSize:14];
        self.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateViewWithFilterStatus:(BOOL)isFilter{
    _isFilter = isFilter;
    if(isFilter){
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

+ (id)cellWithTableView:(UITableView *)tableView
{
    static NSString *ident = nil;
    ident = NSStringFromClass([self class]);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if(cell == nil){
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
    }
    return cell;
}
@end
