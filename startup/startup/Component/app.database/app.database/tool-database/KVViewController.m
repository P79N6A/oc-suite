//
//  ViewController.m
//  PBKeyValueDB
//
//  Created by Bennett on 2016/12/7.
//  Copyright © 2016年 PB-Tech. All rights reserved.
//

#import "ViewController.h"
#import "PBKeyValueDB.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *json = @"{code:0,msg:,data:{userId:0,uname:tom,gender:1,isOldMember:true}}";
    NSString *midJson = @"{code:0,msg:,data:{userId:0,uname:bennett,gender:0,isOldMember:true}}";
    NSString *specJson = @"{code:0,msg:,data:{userId:0,uname:bennett,gender:1,isOldMember:true}}";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        

        
        void (^error)(BOOL success, id object, NSError *error) = ^(BOOL success, id object, NSError *error) {
//            if (!success) {
//                NSLog(@"%s--->%@" ,__func__ ,error);
//            } else {
//                NSLog(@"\n\n");
//                NSLog(@"%@" ,object);
//            }
        };
        
        
        __block NSDate *start = [NSDate date];
        
        NSString *(^interval)(void) = ^() {
            NSDate *now = [NSDate date];
            NSTimeInterval timeInterval = [now timeIntervalSinceDate:start];
            start = now;
            return [NSString stringWithFormat:@"%0.6f" ,timeInterval * 1000];
        };
        
        NSInteger count = 999;
        NSInteger mid = count/2;
        for (NSInteger i = 0; i < count; i++) {
            if (mid != i) {
                [[PBKeyValueDB shareInstance] setValue:error value:json key:[@(i) stringValue] table:nil];
            } else {
                [[PBKeyValueDB shareInstance] setValue:error value:midJson key:[@(i) stringValue] table:nil];
            }
        }
        [[PBKeyValueDB shareInstance] setValue:error value:specJson key:[@(999) stringValue] table:nil];
        
        void (^wrap)() = ^ {
            NSLog(@"\n\n\n\n");
        };
        
        NSLog(@"set %@ cost %@ ms" ,[@(count + 1) stringValue] ,interval());
        wrap();
        
        [[PBKeyValueDB shareInstance] value:error key:[@(count/2) stringValue] table:nil];
        
        NSLog(@"find a record by mid match id cost %@ ms" ,interval());
        wrap();
        
        [[PBKeyValueDB shareInstance] values:error table:nil valueMatch:@{@"uname" : @"bennett"}];
        
        NSLog(@"find records by mid match args cost %@ ms" ,interval());
        wrap();
        
        [[PBKeyValueDB shareInstance] values:error table:nil valueMatch:@{@"uname" : @"bennett" ,@"gender":@"1"}];
        
        NSLog(@"find records by mid match args cost %@ ms" ,interval());
        wrap();
        
        [[PBKeyValueDB shareInstance] remove:error key:[@(count/2) stringValue] table:nil];
        
        NSLog(@"remove records by mid id args cost %@ ms" ,interval());
        wrap();
        
        [[PBKeyValueDB shareInstance] removeBatch:error key:@[@"200" ,@"300" ,@"400" ,@"500" ,@"600"] table:nil];
        
        NSLog(@"remove records by batch cost %@ ms" ,interval());
        wrap();
        
        [[PBKeyValueDB shareInstance] removeAll:error table:nil];
        
        NSLog(@"remove all records cost %@ ms" ,interval());
        wrap();
    });
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
