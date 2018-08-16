//
//  NSNumber+CalculateChain2.h
//  TestTableView
//
//  Created by Ben on 9/05/2017.
//  Copyright © 2017 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (CalculateChain2)

-(NSNumber*(^)(float))add;
-(NSNumber*(^)(float))minus;
-(NSNumber*(^)(float))multiply;
-(NSNumber*(^)(float))divide;

@end
