//
//  BaseViewModel.m
// fallen.ink
//
//  Created by 李杰 on 6/6/15.
//
//

#import "BaseViewModel.h"
#import "BaseDataSource.h"

@implementation BaseViewModel

- (instancetype)initWithParams:(NSDictionary *)params {
    if (self = [super init]) {
        
        [self setup];
    }
    
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        
        [self setup];
    }
    
    return self;
}

- (void)recover {
    
}

- (void)prepare:(id)data {
    
}

- (void)setup {
    [self recover];
}

- (void)setdown:(id)data {
    
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
