//
//  AESMissionListener.m
//  wesg
//
//  Created by Altair on 8/25/16.
//  Copyright © 2016 AliSports. All rights reserved.
//

#import "_MissionListener.h"

NSString *const kMissionCompletedNotification = @"kMissionCompletedNotification";

typedef void(^AESMissionListenerNotifyBlock)();

@interface _MissionListener ()

@property (nonatomic, copy) AESMissionListenerNotifyBlock notifyBlock;

@property (nonatomic, strong) NSDate *lastSignaledDate;

- (void)missionCompletionSignaled;

@end

@implementation _MissionListener

+ (instancetype)listener {
    static _MissionListener *missionListener = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        missionListener = [[_MissionListener alloc] init];
    });
    return missionListener;
}

- (void)startListeningWithNotifyBlock:(void (^)())notify {
    self.notifyBlock = notify;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(missionCompletionSignaled) name:kMissionCompletedNotification object:nil];
}

- (void)stopListening {
    self.notifyBlock = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMissionCompletedNotification object:nil];
}

- (void)missionCompletionSignaled {
    @synchronized (self) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastSignaledDate];
        if (timeInterval < 3) {
            return;
        }
        self.lastSignaledDate = [NSDate date];
        if (self.notifyBlock) {
            self.notifyBlock();
        }
    }
}

@end
