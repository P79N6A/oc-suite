//
//  CalculateChain.m
//  TestTableView
//
//  Created by Ben on 9/05/2017.
//  Copyright © 2017 Ben. All rights reserved.
//

#import "CalculateChain.h"

@implementation CalculateChain

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.result = 0;
    return self;
}


-(CalculateChain*(^)(float))add{
    return ^CalculateChain *(float value){
        _result += value;
        return self;
    };
}


-(CalculateChain*(^)(float))minus{
    return ^CalculateChain *(float value){
        _result -= value;
        return self;
    };
}


-(CalculateChain*(^)(float))multiply{
    return ^CalculateChain *(float value){
        _result *= value;
        return self;
    };
}


-(CalculateChain*(^)(float))divide{
    return ^CalculateChain *(float value){
        if(value!=0)
            _result /= value;
            
        return self;
    };
}

@end
