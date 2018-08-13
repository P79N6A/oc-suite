//
//  ALSNetworkProtocol.h
//  NewStructure
//
//  Created by 7 on 15/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSProtocol.h"
#import "ALSerializationProtocol.h"
#import "ALSNetworkServerProtocol.h"

// 以下由外部库提供定义

// HTTP prot : "http", "https"
// AEDataKit: kAEDKServiceProtocolHttp, kAEDKServiceProtocolHttps

// HTTP method : "GET", "POST", "PUT"
// AEDataKit: kAEDKServiceMethodGet, kAEDKServiceMethodPOST, kAEDKServiceMethodHEAD, kAEDKServiceMethodDELETE

typedef void (^ ALSRequestFinishedBlock)(NSError *error, id responseModel, id extraData);
typedef void (^ ALSRequestBeforeBlock)(void);
typedef void (^ ALSRequestCurrentBlock)(int64_t total, int64_t current);
typedef id (^ ALSRequestAfterBlock)(NSError *error, id responseModel);

// 全局接口监控、截获、处理
typedef id (^ ALSRequestAllParameterFilterBlock)(id origin);
typedef void (^ ALSRequestAllBeforeBlock)(id process);
typedef id (^ ALSRequestAllAfterBlock)(NSError *error, id responseModel);

// 网络协议
@protocol ALSNetworkProtocol <ALSProtocol>

@property (nonatomic, strong) id<ALSNetworkServerProtocol> activeServer;

//////////////////////////////////////////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////

// MARK: - 辅助字段
@property (nonatomic, strong) NSString *dataField;
@property (nonatomic, strong) NSString *errorCodeField;
@property (nonatomic, strong) NSString *errorMessageField;
@property (nonatomic, strong) NSString *extraField;

@property (nonatomic, strong) ALSRequestAllParameterFilterBlock onParameterFilter;
@property (nonatomic, strong) ALSRequestAllBeforeBlock onBeforeHandler;
@property (nonatomic, strong) ALSRequestAllAfterBlock onAfterHandler; // 暂时不使用

// MARK: - 序列化
@property (nonatomic, strong) id<ALSerializationProtocol> serialization;

// MARK: - 接口预注册
/**
 *  @brief 配置 普通服务
 *  @param identifier 标识符
 *  @param prot 协议类型名
 *  @param method 协议方法名
 *  @param domain 域名
 *  @param path 路径
 */
- (void)apiWith:(NSString *)identifier prot:(NSString *)prot method:(NSString *)method domain:(NSString *)domain path:(NSString *)path;

/**
 *  @brief 配置 上传服务, 如果上传二进制流，则filepath为空
 *  @param identifier 标识符
 *  @param prot 协议类型名
 *  @param method 协议方法名
 *  @param domain 域名
 *  @param path 路径
 *  @param filepath 上传源文件名
 */
- (void)apiUploadWith:(NSString *)identifier prot:(NSString *)prot method:(NSString *)method domain:(NSString *)domain path:(NSString *)path filepath:(NSString *)filepath;

/**
 *  @brief 配置 下载服务
 *  @param identifier 标识符
 *  @param prot 协议类型名
 *  @param method 协议方法名
 *  @param domain 域名
 *  @param path 路径
 *  @param filepath 下载目标文件名
 */
- (void)apiDownloadWith:(NSString *)identifier prot:(NSString *)prot method:(NSString *)method domain:(NSString *)domain path:(NSString *)path filepath:(NSString *)filepath;

// MARK: - 普通接口 1
/**
 *  @brief 手动解析 请求 (自行调用序列化方法，将json转化为object)
 *  @param identifier 标识符
 *  @param param 携带参数
 *  @param finishedHandler 结束接收句柄
 */
- (void)requestWith:(NSString *)identifier parameters:(NSDictionary *)param finished:(ALSRequestFinishedBlock)finishedHandler;

/**
 *  @brief 手动解析 请求
 *  @param identifier 标识符
 *  @param param 携带参数
 *  @param beforeHandler 前置截获句柄
 *  @param afterHandler 后置截获句柄
 *  @param finishedHandler 结束接收句柄
 */
- (void)requestWith:(NSString *)identifier parameters:(NSDictionary *)param before:(ALSRequestBeforeBlock)beforeHandler after:(ALSRequestAfterBlock)afterHandler finished:(ALSRequestFinishedBlock)finishedHandler; // 前后切面

@optional

// MARK: - 普通接口 2
/**
 *  @brief 自动解析 请求 (预先配置serilization)
 *  @param identifier 标识符
 *  @param cls 序列化对象类型
 *  @param param 携带参数
 *  @param finishedHandler 结束接收句柄
 */
- (void)requestWith:(NSString *)identifier responseClass:(Class)cls parameters:(NSDictionary *)param  finished:(ALSRequestFinishedBlock)finishedHandler;

/**
 *  @brief 自动解析 请求
 *  @param identifier 标识符
 *  @param cls 序列化对象类型
 *  @param param 携带参数
 *  @param beforeHandler 前置截获句柄
 *  @param afterHandler 后置截获句柄
 *  @param finishedHandler 结束接收句柄
 */
- (void)requestWith:(NSString *)identifier responseClass:(Class)cls parameters:(NSDictionary *)param class:(Class)cls before:(ALSRequestBeforeBlock)beforeHandler after:(ALSRequestAfterBlock)afterHandler finished:(ALSRequestFinishedBlock)finishedHandler;

@required

// MARK: - 上传、下载接口
/**
 *  @brief 下载 请求
 *  @param identifier 标识符
 *  @param currentHandler 进度反馈句柄
 *  @param finishedHandler 结束接收句柄
 */
- (void)downloadWith:(NSString *)identifier current:(ALSRequestCurrentBlock)currentHandler finished:(ALSRequestFinishedBlock)finishedHandler;

/**
 *  @brief 上传 请求
 *  @param identifier 标识符
 *  @param currentHandler 进度反馈句柄
 *  @param finishedHandler 结束接收句柄
 */
- (void)uploadWith:(NSString *)identifier current:(ALSRequestCurrentBlock)currentHandler finished:(ALSRequestFinishedBlock)finishedHandler;

@end
