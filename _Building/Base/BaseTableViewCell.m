//
//  BaseTableViewCell.m
//  consumer
//
//  Created by fallen on 16/9/23.
//
//

#import "BaseTableViewCell.h"
#import "UITableViewCell+.h"

@interface BaseTableViewCell ()

@property (nonatomic, assign) BOOL isInit;

@end

@implementation BaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (!self.isInit) {
        [self setup];
        
        self.isInit = YES;
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        if (!self.isInit) {
            [self setup];
            
            self.isInit = YES;
        }
    }
    
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        if (!self.isInit) {
            [self setup];
            
            self.isInit = YES;
        }
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
