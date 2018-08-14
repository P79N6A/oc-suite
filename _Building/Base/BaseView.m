//
//  BaseView.m
//  kata
//
//  Created by fallen on 17/3/7.
//  Copyright © 2017年 fallenink. All rights reserved.
//

#import "BaseView.h"
#import "_pragma_push.h"

@implementation UIView (ConstraintsControl)

- (void)applyConstraints {
    // Do nothing...
}

@end

@implementation UIView (Template)

+ (NSString *)identifier {
    return NSStringFromClass(self);
}

+ (UINib *)nib {
    return [UINib nibWithNibName:[self identifier] bundle:nil];
}

@end

@implementation UIView (Nib)

- (instancetype) _initWithNib {
    return [self.class _loadViewWithNibNamed:NSStringFromClass([self class])];
}

+ (instancetype)_loadViewWithNibNamed:(NSString *)name {
    return [[[NSBundle mainBundle] loadNibNamed:name owner:self options:nil] objectAtIndex:0];
}

#pragma mark -

+ (UINib *)loadNib {
    return [self loadNibNamed:NSStringFromClass([self class])];
}

+ (UINib *)loadNibNamed:(NSString*)nibName {
    return [self loadNibNamed:nibName bundle:[NSBundle mainBundle]];
}

+ (UINib *)loadNibNamed:(NSString*)nibName bundle:(NSBundle *)bundle {
    return [UINib nibWithNibName:nibName bundle:bundle];
}

+ (instancetype)loadInstanceFromNib {
    return [self loadInstanceFromNibWithName:NSStringFromClass([self class])];
}

+ (instancetype)loadInstanceFromNibWithName:(NSString *)nibName {
    return [self loadInstanceFromNibWithName:nibName owner:nil];
}

+ (instancetype)loadInstanceFromNibWithName:(NSString *)nibName owner:(id)owner {
    return [self loadInstanceFromNibWithName:nibName owner:owner bundle:[NSBundle mainBundle]];
}

+ (instancetype)loadInstanceFromNibWithName:(NSString *)nibName owner:(id)owner bundle:(NSBundle *)bundle {
    UIView *result = nil;
    NSArray* elements = [bundle loadNibNamed:nibName owner:owner options:nil];
    for (id object in elements) {
        if ([object isKindOfClass:[self class]]) {
            result = object;
            break;
        }
    }
    return result;
}

@end

#pragma mark -

@implementation UIView ( Bind )

- (void)bindWithViewModel:(id)viewModel {
    
}

@end

#import "_pragma_pop.h"

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
