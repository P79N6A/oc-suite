//
//  AppVersioner.h
//  consumer
//
//  Created by fallen.ink on 18/10/2016.
//
//

#import <_Foundation/_Foundation.h>

@interface AppVersioner : NSObject

@property (nonatomic, weak) UIWindow *window; // to show exit animation, as AppDelegate.window.

@property (nonatomic, strong) NSString *appLookupUrl;
@property (nonatomic, strong) NSString *appId; // need to config

- (void)checkUpdate;

/**
 *  比较版本号大小
 *
 *  @param firstVersion  第一个版本号
 *  @param secondVersion 第二个版本号
 *
 *  @return 返回第一个比第二个的结果
            -1 firstVersion < secondVersion
            0 firstVersion = secondVersion
            1 firstVersion > secondVersion
 */
+ (int)compareVersion:(NSString *)firstVersion version:(NSString *)secondVersion;

@end
