//
//  NSNumber+CalculateChain2.m
//  TestTableView
//
//  Created by Ben on 9/05/2017.
//  Copyright © 2017 Ben. All rights reserved.
//

#import "NSNumber+CalculateChain2.h"

@implementation NSNumber (CalculateChain2)


-(NSNumber*(^)(float))add{
    return ^NSNumber *(float value){
        return [NSNumber numberWithFloat:([self floatValue] + value)];
    };
}


-(NSNumber*(^)(float))minus{
    return ^NSNumber *(float value){
        return [NSNumber numberWithFloat:([self floatValue] - value)];
    };
}


-(NSNumber*(^)(float))multiply{
    return ^NSNumber *(float value){
        return [NSNumber numberWithFloat:([self floatValue] * value)];
    };
}


-(NSNumber*(^)(float))divide{
    return ^NSNumber *(float value){
        return [NSNumber numberWithFloat:([self floatValue] / value)];
    };
}


@end
