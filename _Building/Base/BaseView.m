//
//  BaseView.m
//  kata
//
//  Created by fallen on 17/3/7.
//  Copyright © 2017年 fallenink. All rights reserved.
//

#import "BaseView.h"

@implementation BaseView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    
    return self;
}

- (instancetype)init {
    if ([super init]) {
        [self setup];
    }
    
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setup {
    
}

@end
