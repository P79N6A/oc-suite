//
//  _net_request_protocol.h
//  hairdresser
//
//  Created by fallen.ink on 7/13/16.
//
//

#import "_precompile.h"
#import "_networkdef.h"

#pragma mark - 

#undef  impl_net_request
#define impl_net_request( _apiname_, _request_method_, _responsename_string_, _serializer_type_) \
    - (NSString *)requestUrl {\
        return _apiname_;\
    }\
\
    - (NetRequestMethod)requestMethod {\
        return _request_method_;\
    }\
\
    - (NSString *)responseClassname {\
        return _responsename_string_;\
    }\
\
    - (RequestSerializerType)requestSerializerType {\
    return _serializer_type_;\
    }

#undef  impl_net_request_sim // Just apiname, responsename
#define impl_net_request_sim( _apiname_, _responsename_string_) impl_net_request(_apiname_, NetRequestMethod_Post, _responsename_string_, RequestSerializerType_JSON)

#pragma mark -

/**
 *  请求（request）、应答（response）的数据模型，都继承_Model，同时实现MTLJSONSerializing、_NetModelProtocol接口
 */
@protocol _NetModelProtocol <NSObject>

#pragma mark - this

@required

- (id<_NetModelProtocol>)this; // 委托，返回protocol的真正实体, 默认 不指定

#pragma mark - 基本请求参数

@required

- (NSString *)requestUrl; // 接口名 字符串, 默认 nil

- (NetRequestMethod)requestMethod; // HTTP 请求方法, 默认 POST

- (NSString *)responseClassname; // 用于反射, 默认 nil

- (RequestSerializerType)requestSerializerType; // 序列化方法, 默认 

#pragma mark - Cdn

@optional

- (BOOL)useCDN;

- (NSString *)cdnUrl;

#pragma mark - base url / build Url

- (NSString *)baseUrl;

/**
 *  The whole url provided by client
 */
- (NSString *)buildUrl;

#pragma mark - Header param fields and data

/**
 *  获取头部参数
 *
 *  @return NSDictionary
 */
- (NSDictionary *)requestHeaderFieldValueDictionary;

#pragma mark - Cache

@optional



/**
 *  使用缓存
 *  当前，只针对特定接口，使用缓存
 */
- (BOOL)useCache;

#pragma mark - Upload & Download


/**
 *  断点下载
 */

- (NSString *)resumableDownloadPath;

#pragma mark - 高级配置

/**
 *  自定义请求，可以配置优先级
 */
- (NetRequestPriority)requestPriority;

- (NSURLRequest *)customUrlRequest;

- (NSArray *)requestAuthorizationHeaderFieldArray;

#pragma mark - tool 序列化

- (NSDictionary *)requestParams; // 序列化器

- (id)modelableFromResponseData:(NSDictionary *)responseData error:(NSError **)error; // 反序列化器

@end

