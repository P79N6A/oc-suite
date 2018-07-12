//
//  ComponentMapConfig.h
//  component
//
//  Created by fallen.ink on 3/16/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @knowledge
 
    0. add -ObjC to Other linker flags!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
    1. 高德使用：http://www.cnblogs.com/XYQ-208910/p/6128915.html
    1.1 权限定位：info.plist
        - NSLocationWhenInUseUsageDescription   YES
        - NSLocationAlwaysUsageDescription      YES
 
        Privacy - Location Usage Description 我需要了解您所在的城市。
        Privacy - Location When In Use Usage Description 我需要了解您所在的城市请允许我获得您的地理位置。

    1.2 ATS设置：HTTPS
        - App Transport Security Settings , Allow Arbitary Loads YES
    1.3 Inlucde header files
        - 引入AMapFoundationKit.h和AMapLocationKit.h这两个头文件：
            #import <AMapFoundationKit/AMapFoundationKit.h>
            #import <AMapLocationKit/AMapLocationKit.h>
    1.4 设置期望定位精度
 
     //由于苹果系统的首次定位结果为粗定位，其可能无法满足需要高精度定位的场景。
     //所以，高德提供了 kCLLocationAccuracyBest 参数，设置该参数可以获取到精度在10m左右的定位结果，但是相应的需要付出比较长的时间（10s左右），越高的精度需要持续定位时间越长。
     
     //推荐：kCLLocationAccuracyHundredMeters，一次还不错的定位，偏差在百米左右，超时时间设置在2s-3s左右即可。
     
     //高精度：kCLLocationAccuracyBest，可以获取精度很高的一次定位，偏差在十米左右，超时时间请设置到10s，如果到达10s时没有获取到足够精度的定位结果，会回调当前精度最高的结果。
     //带逆地理信息的一次定位（返回坐标和地址信息）
     [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
     
     //定位超时时间，最低2s，此处设置为2s
     self.locationManager.locationTimeout =2;
     
     //逆地理请求超时时间，最低2s，此处设置为2s
     self.locationManager.reGeocodeTimeout = 2;
     
     //带逆地理信息的一次定位（返回坐标和地址信息）
     [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
     
     //定位超时时间，最低2s，此处设置为10s
     self.locationManager.locationTimeout =10;
     
     //逆地理请求超时时间，最低2s，此处设置为10s
     self.locationManager.reGeocodeTimeout = 10;
 
    2. 高德API，请注册Key，注册地址：http://lbs.amap.com/console/key
        //在调用定位时，需要添加Key，需要注意的是请在 SDK 任何类的初始化以及方法调用之前设置正确的 Key。
        //如果您使用的是定位SDK v2.x版本需要引入基础 SDK AMapLocationKit.framework ，设置apiKey的方式如下：
 
        //iOS 定位SDK v2.x版本设置 Key：
        - [AMapServices sharedServices].apiKey =@"您的key";
        //如果您使用的是定位SDK v1.x版本，请您尽快更新。
 
        //iOS 定位SDK v1.x版本设置 Key：
        - [AMapLocationServices sharedServices].apiKey =@"您的key";
 
    3. apikey 举例
        #define SdkKey_GaoDe_App           @"604cd55b5aa21c47b2907b65ca555d57" // native api
        #define SdkKey_GaoDe_Html5         @"6ac773a2a022262da557dcd4d4793c2c" // js api
        #define SdkKey_Gaode_Web           @"c86d5a251d4eb5af15244cc06946234e" // web api
 
    4. 高德使用方法参考：https://github.com/xiayuanquan/AliMapKit
 */

@interface ComponentMapConfig : NSObject

@property (nonatomic, strong) NSString *apiKey;

@end
