//
//  _network_private.h
//  component
//
//  Created by fallen.ink on 5/27/16.
//  Copyright © 2016 OpenTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol _NetModelProtocol;

@interface _NetRequest ()

/**
 *  Retry mechanism
 */
@property (nonatomic, assign) NSInteger retryCount; // 重试次数 默认为0
@property (nonatomic, assign) NSInteger retryIndex; // 正在重试第几次

/**
 *  Session task
 
 *  NSURLSessionTask
 *  NSURLSessionDataTask
 *  NSURLSessionUploadTask
 *  NSURLSessionDownloadTask
 */
@property (nonatomic, strong) NSURLSessionTask *sessionTask;

/**
 *  NSOperation
 *
 *  Used when customed NSURLReqeust
 */
@property (nonatomic, strong) NSOperation *operation;

/**
 *  http 应答数据
 
 *  responseObject 为 二进制 裸数据
 */
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) id responseObject;

/**
 *  HTTP 应答处理
 */
- (void)onStart;
- (void)onProgress:(NSProgress *)progress;
- (void)onSuccess:(NSHTTPURLResponse *)response :(id)responseObject;
- (void)onFailure:(NSHTTPURLResponse *)response :(NSError *)error;

/**
 *  清理工作
 */
- (void)clear;

@end