//
//  ReactEventStation.h
//  hairdresser
//
//  Created by fallen.ink on 8/10/16.
//
//  refer http://reactnative.cn/docs/0.28/native-modules-ios.html#content

#import "rn-precompile.h"

#if __has_RCTBridgeModule

@protocol RCTEventHandler;

/**
 *  Usage
 
 *  1. Responding Text or Touchable Control's onPress... callback
 *
 *  var EventStation = require('react-native').NativeModules.theEventStation;
 *  // AppRegistry.registerComponent('hairdresserHomePage', () => hairdresserHomePage);
 *  EventStation.performEvent('event 1', 'hairdresserHomePage');
 
 *  2. Send event to RCT
 
 *  3. Dynamic update or load more views
 */


// https://github.com/hackers-painters/samurai-native/blob/master/README_CN.md，参考这个去设计
@interface RCTEventStation : NSObject <RCTBridgeModule>

@singleton( RCTEventStation )

- (void)addEventObserver:(NSObject<RCTEventHandler> *)observer;

@end

@protocol RCTEventHandler <NSObject>

- (NSString *)moduleName;

/**
 *  event handler
 *
 *  @param name   event name
 *  @param params extra params
 */
- (void)eventHandler:(NSString *)name extraParams:(NSDictionary *)params;

@end

#endif
