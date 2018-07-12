//
//  ComponentMap.m
//  component
//
//  Created by fallen.ink on 3/16/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

//  高德地图SDK：http://lbs.amap.com/api/ios-sdk/summary

#import "ComponentMap.h"
#import "ComponentMapConfig.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

@implementation ComponentMap

@def_singleton( ComponentMap )

@def_prop_instance(ComponentMapConfig, config)

- (void)initGDAPIKey { // 高德 MapKit configure.
    if ([self.config.apiKey length] == 0) {
#define kMALogTitle @"提示"
#define kMALogContent @"apiKey为空，请检查key是否正确设置"
        
        NSLog(@"%@", [NSString stringWithFormat:@"[MAMapKit] %@", kMALogContent]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kMALogTitle message:kMALogContent delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];
        });
    }
    
//    [AMapLocationServices]
    [MAMapServices sharedServices].apiKey = self.config.apiKey;
    [AMapSearchServices sharedServices].apiKey = self.config.apiKey;
    [AMapLocationServices sharedServices].apiKey = self.config.apiKey;
    
    LOG(@"GaoDe map version: %@", [[MAMapServices sharedServices] SDKVersion]);
}

@end
