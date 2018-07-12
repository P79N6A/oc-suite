//
//  LocationViewController.h
//  QQing
//
//  Created by 李杰 on 1/27/15.
//
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "BaseViewController.h"

typedef enum : NSUInteger {
    SelectAddressType_Default,
} SelectAddressType;

@class LocationModel;

@interface LocationViewController : BaseViewController

/**
 *  如果设置，则后面筛选会默认加上该城市
 */
@prop_class(NSString *, currentCityName)

/**
 *  选择地址
 *  @param type  使用情景类型
 *  @param block 回调LocationModel, 地区信息 与 详细信息地址中，使用逗号分隔
 */
- (instancetype)initWithSelectAddressType:(SelectAddressType)type completionBlock:(ObjectBlock)block;

@end
