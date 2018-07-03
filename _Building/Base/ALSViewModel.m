//
//  ALSViewModel.m
//  wesg
//
//  Created by 7 on 24/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import "ALSViewModel.h"

#pragma mark -

@implementation ALSViewModel

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    
}

- (void)setdown:(id)data {
    
}

+ (instancetype)with:(id)data {
    ALSViewModel *viewModel = [[self alloc] init];
    
    [viewModel setdown:data];
    
    return viewModel;
}

// MARK: - 数据源

- (int32_t)numberOfSections {
    return 0;
}

- (int32_t)numberOfRowsInSection:(int32_t)section {
    return 0;
}

- (id)modelForRowAtSection:(int32_t)section row:(int32_t)row {
    return nil;
}

@end

#pragma mark -

@implementation UIViewController ( ViewModel )

- (void)bind {
    
}

@end

