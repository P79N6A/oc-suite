//
//  CacheViewController.m
//  gege
//
//  Created by fallen.ink on 2019/3/18.
//  Copyright © 2019 laoshi. All rights reserved.
//

#import "AppDelegate.h"
#import "CacheViewController.h"

@interface CacheViewController ()

@end

@implementation CacheViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    cacheInst[@"name"] = @"老湿";
    NSString *name = cacheInst[@"name"];
    
    INFO(@"name = %@", name);
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
