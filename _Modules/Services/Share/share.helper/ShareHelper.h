//
//  ShareHelper.h
//  consumer
//
//  Created by fallen on 16/10/24.
//
//

#import <Foundation/Foundation.h>

@interface ShareHelper : NSObject

#pragma mark - Url helper

/**
 *  工厂模式该风格！！！！@fallenink
 */
+ (instancetype)withUrl:(NSString *)url;

- (NSString *)getUrlWithChannelled;

#pragma mark - Tools

/**
 *  @重要
 
 *  1.0.0版本，有位置要求：secondId, assistantId, channelId
 */
+ (NSString*)convertUrl:(NSString *)originUrl withChannelId:(NSString *)channelId enabled:(BOOL)enabled;

@end
