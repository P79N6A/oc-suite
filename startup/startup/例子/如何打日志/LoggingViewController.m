//
//  LoggingViewController.m
//  gege
//
//  Created by fallen.ink on 2019/3/14.
//  Copyright © 2019 laoshi. All rights reserved.
//

#import "LoggingViewController.h"
#import "AppDelegate.h"

@interface LoggingViewController ()

@end

@implementation LoggingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    VERBOSE(@"这是挑食信息")
    
    INFO(@"这是一般信息")
    
    ERROR(@"这是错误信息")
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
