//
//  ReactViewController.h
//  hairdresser
//
//  Created by fallen.ink on 7/21/16.
//
//
#import "rn-precompile.h"

#import "RCTEventStation.h"

#if __has_RCTRootView
/**
 *  1. 支持分享，当前 ReactNative 还没用上 Network！！！只有 UI 逻辑
 
 *  "supportShare" NSNumber boolValue
 *  "shareBlock"   BLock (void)
 
 */
@interface ReactViewController : UIViewController

@property (nonatomic, strong) void (^ eventHandler)(NSString *eventName, NSDictionary *params);

@end
#endif
