//
//  _mvvm_model.m
//  kata
//
//  Created by fallen on 17/3/15.
//  Copyright © 2017年 fallenink. All rights reserved.
//

#import "_mvvm_model.h"

@implementation _MvvmModel

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    
    return self;
}

- (void)dealloc {
    [self clear];
}

#pragma mark - Override

- (void)setup {
    
}

- (void)clear {
    
}

@end

@implementation _MvvmModel ( Template )

- (void)loadListWithSuccess:(ObjectBlock)successHandler failure:(ErrorBlock)failureHandler {
    
}

- (void)appendListWithSuccess:(ObjectBlock)successHandler failure:(ErrorBlock)failureHandler {
    
}

@end
