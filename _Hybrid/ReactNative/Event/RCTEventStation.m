//
//  ReactEventStation.m
//  hairdresser
//
//  Created by fallen.ink on 8/10/16.
//
//

#import "RCTEventStation.h"

#if __has_RCTBridgeModule
@interface RCTEventStation ()

@property (nonatomic, strong) NSMapTable *eventHandlers;

@end

@implementation RCTEventStation

RCT_EXPORT_MODULE(theEventStation);

RCT_EXPORT_METHOD(performEvent:(NSString *)eventName module:(NSString *)moduleName extraParams:(NSDictionary *)params) {
    LOG(@"[React] receive event (%@) from module(%@) with extra params(%@)", eventName, moduleName, params);
    
    [[RCTEventStation sharedInstance] dispatchEvent:eventName module:moduleName extraParams:params];
}

RCT_EXPORT_METHOD(performEvent:(NSString *)eventName module:(NSString *)moduleName) {
    LOG(@"[React] receive event (%@) from module(%@)", eventName, moduleName);
    
    [[RCTEventStation sharedInstance] dispatchEvent:eventName module:moduleName extraParams:nil];
}

#pragma mark -

@def_singleton( RCTEventStation )

- (instancetype)init {
    if (self = [super init]) {
        self.eventHandlers = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
    }
    
    return self;
}

#pragma mark - Event manage

- (void)addEventObserver:(NSObject<RCTEventHandler> *)observer {
    NSAssert(observer, @"observer should be nil setting");
    NSAssert(is_method_implemented(observer, moduleName), @"event observer should implement @moduleName");
    NSAssert(is_method_implemented(observer, eventHandler:extraParams:), @"event observer should implement @eventHandler:extraParams:");
    
    NSString *key = [observer moduleName];
    NSAssert(key, @"observer's @moduleName shouldn't return nil");
    
    [self.eventHandlers setObject:observer forKey:key];
}

- (void)dispatchEvent:(NSString *)eventname module:(NSString *)modulename extraParams:(NSDictionary *)params {
    if ([modulename length]) {
        NSObject<RCTEventHandler> *handler = [self.eventHandlers objectForKey:modulename];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [handler eventHandler:eventname extraParams:params];
        });
        
    } else {
        LOG(@"module name shouldn't be nil");
    }
}

@end
#endif
