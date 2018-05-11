//
//  UITableViewCell+Extension.m
//  consumer
//
//  Created by fallen on 16/8/23.
//
//

#import "UITableViewCell+Extension.h"

@implementation UITableViewCell (Extension)

- (void)rotateToHorizontalScrollable {
    self.contentView.transform = CGAffineTransformMakeRotation(M_PI / 2);
}

- (void)disableSelection {
    // Disable select action
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Hide accessory mark
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)enableSelection {
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

@end
