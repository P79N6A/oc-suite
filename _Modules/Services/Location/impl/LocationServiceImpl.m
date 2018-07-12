//
//  LocationServiceImpl.m
//  student
//
//  Created by fallen.ink on 10/06/2017.
//  Copyright © 2017 alliance. All rights reserved.
//

//新增Key: NSLocationAlwaysUsageDescription 和 NSLocationWhenInUseUsageDescription ，这两个Key的值将分别用于描述应用程序始终使用和使用期间使用定位的说明，这些说明将显示在用户设置中。

#import "LocationServiceImpl.h"
#import "_building_precompile.h"

@interface LocationServiceImpl () <CLLocationManagerDelegate>

@prop_strong(CLLocationManager *, locationManager)

@end

@implementation LocationServiceImpl

#pragma mark - Life cycle

- (void)prepare {
    if([CLLocationManager locationServicesEnabled]){
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 200;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;//kCLLocationAccuracyBest;
        if (system_version_greater_than_or_equal_to(@"8.0")) {
            //使用期间
            [self.locationManager requestWhenInUseAuthorization];
            //始终
            //or [self.locationManage requestAlwaysAuthorization]
        }
    }
}

- (void)start {
    
}

- (void)stop {
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
            break;
        default:
            break;
    }
    
}

@end
