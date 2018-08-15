//
//  AESMissionListener.h
//  wesg
//
//  Created by Altair on 8/25/16.
//  Copyright © 2016 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kMissionCompletedNotification;

@interface _MissionListener : NSObject

+ (instancetype)listener;

- (void)startListeningWithNotifyBlock:(void(^)())notify;

- (void)stopListening;

@end
