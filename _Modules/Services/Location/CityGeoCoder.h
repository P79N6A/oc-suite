//
//  CityGeoCoder.h
//  component
//
//  Created by 郭晓倩 on 15/10/26.
//  Copyright © 2015年 OpenTeam. All rights reserved.
//
//  与城市相关的地理编码和逆编码

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationModel.h"

typedef void(^CityGeoCodeCompletionBlock)(LocationModel *location);

@interface CityGeoCoder : NSObject

/**
 *  @brief 具体地址-->相关城市, 城市id可能无效
 */
+ (void)geocodeAddressString:(NSString *)addressString completionHandler:(CityGeoCodeCompletionBlock)completionHandler;

/**
 *  @brief 经纬度-->相关城市, 城市id可能无效
 */
+ (void)reverseGeocodeLocation:(CLLocation *)location completionHandler:(CityGeoCodeCompletionBlock)completionHandler;

@end
