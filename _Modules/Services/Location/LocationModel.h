//
//  LocationModel.h
//  component
//
//  Created by 郭晓倩 on 15/10/26.
//  Copyright © 2015年 OpenTeam. All rights reserved.
//

#import "_foundation.h"
#import "_archiver.h"

@interface LocationModel : NSObject <NSCoding>

@prop_assign(double, longitude) // 经度
@prop_assign(double, latitude) // 纬度

@prop_assign(int64_t, cityId)
@prop_assign(int32_t, cityCode)
@prop_strong(NSString *,cityCodeString)//临时设置的用于存储原本的城市code

@prop_strong(NSString *, cityCodes)

@prop_strong(NSString *, address)

@prop_strong(NSString *, cityName)
@prop_strong(NSString *, district) //区，比如浦东新区

//
+ (id)modelWithLongitude:(double)lo latitude:(double)la;
+ (id)modelWithAddress:(NSString *)addr longitude:(double)lon latitude:(double)lat;

// 工具方法
+ (double)kilometerDistanceBetween:(LocationModel *)aLocation and:(LocationModel *)bLocation;
- (double)kilometerDistanceTo:(LocationModel *)thatLocation;
- (BOOL)isValid;

- (BOOL)containValidCity; //是否包含有效的城市信息
- (BOOL)containValidLocation; //是否包含有效的定位信息

@end
