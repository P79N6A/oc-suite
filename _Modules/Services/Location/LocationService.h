//
//  LocationService.h
//  hairdresser
//
//  Created by fallen.ink on 6/6/16.
//
//

#import <CoreLocation/CoreLocation.h>

#import "_service.h"
#import "LocationModel.h"

typedef enum : NSUInteger {
    LocationStatus_NotStart,    //定位未开始
    LocationStatus_Locating,    //正在定位
    LocationStatus_Failed,      //定位失败
    LocationStatus_Success,     //定位成功
} LocationStatus;

@interface LocationService : _Service

@singleton( LocationService )

@prop_assign(LocationStatus, locationStatus)

/**
 *  @brief 立即返回当前的定位结果，定位不到的话为nil, 慎用！！
 */
@prop_strong(LocationModel *, currentLocation)

- (BOOL)available;

/**
 *  @brief 专注定位一百年，失败返回nil，不再返回默认城市或用户注册城市相关信息;优先使用高德逆地理编码，其次使用苹果的
 */
- (void)currentLocationWithBlock:(void(^)(LocationModel* location))handlerBlock;

/**
 *  @brief 只取经纬度
 */
- (void)currentSimpleLocationWithBlock:(void (^)(CLLocation *))handlerBlock;

@end

@namespace( service, location, LocationService )
