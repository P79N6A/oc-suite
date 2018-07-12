

#import "LocationService.h"
#import "CityGeoCoder.h"
#import "LocationServiceImpl.h"
#import "GaoDeLocationServiceImpl.h"
#import <AMapLocationKit/AMapLocationKit.h>

const int kUpdateLocationInterval = 1*60;//每1分钟刷新定位

@interface LocationService () <CLLocationManagerDelegate> {
    
}

@prop_strong(AMapLocationManager *, locationManager)

@prop_strong(CLLocation *, currrentSimLocation)

//@prop_strong(RACDisposable *, dispose) // FIXME: 需要修改

@end

@implementation LocationService

@def_singleton( LocationService )

- (void)powerOn {
    self.locationStatus = LocationStatus_NotStart;
    
#if !TARGET_OS_SIMULATOR
    // 高德定位服务
    self.locationManager = [AMapLocationManager new];
    
    // 首次获取定位
    [self currentLocationWithBlock:^(LocationModel *location) {
        // 开启定时自动更新定位
        self.dispose = [[[RACSignal interval:kUpdateLocationInterval onScheduler:[RACScheduler mainThreadScheduler]] delay:kUpdateLocationInterval]subscribeNext:^(id x) {
            [self updateLocationWithBlock:nil];
        }];
    }];
#endif
}

- (void)powerOff {
    // 关闭定时自动定位
//    [self.dispose dispose]; // FIXME: 需要修改
//    self.dispose = nil; // FIXME: 需要修改
    
    // 切换状态
    self.locationStatus = LocationStatus_Failed;
    
    // 释放定位manager
    self.locationManager = nil;
}

#pragma mark - 获取定位接口

- (BOOL)available {
#if TARGET_IPHONE_SIMULATOR
    WARN(@"定位服务.模拟器环境下定位不可用");
    return NO;
#else
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied
        || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        WARN(@"定位服务.未开启定位服务");
        return NO;
    }
    return YES;
#endif
}

- (void)currentLocationWithBlock:(void(^)(LocationModel* location))handlerBlock {
    NSAssert(handlerBlock != nil, @"定位服务.未提供回调block");
    
    if (self.currentLocation) {
        if (handlerBlock) handlerBlock(self.currentLocation);
    } else if(![self available]) {
        self.locationStatus = LocationStatus_Failed;
        if (handlerBlock) handlerBlock(nil);
    } else {
        [self updateLocationWithBlock:handlerBlock];
    }
}

- (void)updateLocationWithBlock:(void(^)(LocationModel* location))handlerBlock {
    self.locationStatus = LocationStatus_Locating;
    //偏差在100米以内，耗时在2-3s
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    @weakify(self);
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        @strongify(self);
        if(location == nil && regeocode == nil){
            if (error) {
                ERROR(@"定位服务.定位失败,error:{%ld - %@}", (long)error.code, error.localizedDescription);
                
            } else {
                ERROR(@"定位服务.定位失败");
                
            }
            self.locationStatus = LocationStatus_Failed;
            if (handlerBlock) handlerBlock(nil);
            return;
        } else if(location) {
            self.currrentSimLocation = location;
            
            if (regeocode) {
                LocationModel* locationResult = [LocationModel new];
                int cityID = regeocode.citycode.intValue;
                
                if (cityID) {
                    locationResult.latitude = location.coordinate.latitude;
                    locationResult.longitude = location.coordinate.longitude;
                    locationResult.cityId = cityID;
                    locationResult.cityCodeString = regeocode.citycode;
                    locationResult.cityCode = cityID;
                    locationResult.address = regeocode.formattedAddress;
                    locationResult.district = regeocode.district;
                    locationResult.cityName = regeocode.city ? regeocode.city : regeocode.province;
                    
                    self.currentLocation = locationResult;
                    self.locationStatus = LocationStatus_Success;
                    
                    if (handlerBlock) handlerBlock(locationResult);
                    return ;
                }
            }
            
            [CityGeoCoder reverseGeocodeLocation:location completionHandler:^(LocationModel *locationResult) {
                if (locationResult) {
                    self.currentLocation = locationResult;
                    
                    self.locationStatus = LocationStatus_Success;
                } else {
                    
                    self.locationStatus = LocationStatus_Failed;
                }
                
                if (handlerBlock) handlerBlock(locationResult);
                return;
            }];
        } else {
            ERROR(@"定位服务.定位失败");
            self.locationStatus = LocationStatus_Failed;
            if (handlerBlock) handlerBlock(nil);
            return;
        }
    }];
}

#pragma mark - 只定位经纬度

- (void)currentSimpleLocationWithBlock:(void (^)(CLLocation *))handlerBlock {
    NSAssert(handlerBlock != nil, @"定位服务.未提供回调block");
    
    if (self.currrentSimLocation) {
        handlerBlock(self.currrentSimLocation);
    } else if(![self available]) {
        handlerBlock(nil);
    } else {
        [self updateSimpleLocationWithBlock:handlerBlock];
    }
}

- (void)updateSimpleLocationWithBlock:(void(^)(CLLocation* location))handlerBlock {
    //偏差在100米以内，耗时在2-3s
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    @weakify(self);
    [self.locationManager requestLocationWithReGeocode:NO completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        @strongify(self);
        
        if(location == nil) {
            if (error) {
                ERROR(@"定位服务.简单定位失败,error:{%ld - %@}", (long)error.code, error.localizedDescription);
                
            } else {
                ERROR(@"定位服务.简单定位失败");
            }
            
            handlerBlock(nil);
            
            return;
        } else if(location) {
            self.currrentSimLocation = location;
            handlerBlock(location);
            return;
        } else {
            
            ERROR(@"定位服务.简单定位失败");
            
            handlerBlock(nil);
            
            return;
        }
    }];
}

@end

@def_namespace( service, location, LocationService )
