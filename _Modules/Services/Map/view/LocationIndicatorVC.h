//
//  GDMapVC.h
//  yzsee
//
//  Created by 三炮 on 15/10/22.
//
//  用途：到目的地址的距离和路线规划
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

/**
 *  params: 
 *  LocationAddress 地址
 *  LocationCoordinate CLLocation
 */
@interface LocationIndicatorVC : BaseViewController

@property (nonatomic, strong) NSString  *destnationName;

@property (nonatomic, strong) CLLocation        *destnationLocation;

@end
