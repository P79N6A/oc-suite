//
//  LocationModel.m
//  component
//
//  Created by 郭晓倩 on 15/10/26.
//  Copyright © 2015年 OpenTeam. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "LocationModel.h"

@implementation LocationModel

+ (id)modelWithLongitude:(double)lo latitude:(double)la {
    return [LocationModel modelWithAddress:@"" longitude:lo latitude:la];
}

+ (id)modelWithAddress:(NSString *)addr longitude:(double)lo latitude:(double)la {
    LocationModel *m = [LocationModel new];
    m.address = addr;
    m.longitude = lo;
    m.latitude = la;
    return m;
}

+ (double)kilometerDistanceBetween:(LocationModel *)aLocation and:(LocationModel *)bLocation {
    //根据经纬度创建两个位置对象
    CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:aLocation.latitude
                                                  longitude:aLocation.longitude];
    CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:bLocation.latitude
                                                  longitude:bLocation.longitude];
    
    //计算两个位置之间的距离
    CLLocationDistance distance = [loc1 distanceFromLocation:loc2];
    return distance/1000;
}

- (id)copyWithZone:(NSZone *)zone {
    LocationModel   *copy = [[[self class] allocWithZone:zone] init];
    
    copy.latitude = self.latitude;
    copy.longitude = self.longitude;
    copy.cityId = self.cityId;
    copy.cityCode = self.cityCode;
    copy.cityCodeString = self.cityCodeString;
    copy.cityName = self.cityName;
    
    return copy;
}

- (double)kilometerDistanceTo:(LocationModel *)thatLocation {
    return [LocationModel kilometerDistanceBetween:self and:thatLocation];
}

- (BOOL)isValid {
    return [self containValidCity] && [self containValidLocation];
}

- (BOOL)containValidCity {
    return (self.cityId >= 0 && [self.cityName length] > 0);
}

- (BOOL)containValidLocation {
    return (self.longitude >= -180 && self.longitude <= 180 && self.latitude >= -90 && self.latitude <= 90);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"地址:%@ 城市ID:%lld 经纬度:(%f,%f)",self.address,self.cityId,self.longitude,self.latitude];
}

@end
