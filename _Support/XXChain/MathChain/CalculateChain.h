//
//  CalculateChain.h
//  TestTableView
//
//  Created by Ben on 9/05/2017.
//  Copyright © 2017 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CalculateChain : NSObject

@property (nonatomic) float result;

-(CalculateChain*(^)(float))add;
-(CalculateChain*(^)(float))minus;
-(CalculateChain*(^)(float))multiply;
-(CalculateChain*(^)(float))divide;
    
@end
