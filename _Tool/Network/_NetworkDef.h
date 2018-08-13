//
//  _networkdef.h
//  hairdresser
//
//  Created by fallen.ink on 7/13/16.
//
//

/**
 *  HTTP 方法
 */
typedef enum : NSUInteger {
    NetRequestMethod_Get    = 0,
    NetRequestMethod_Post,
    NetRequestMethod_Head,
    NetRequestMethod_Put,
    NetRequestMethod_Delete,
    NetRequestMethod_Patch
} NetRequestMethod;

/**
 *  序列化方法
 */
typedef enum : NSUInteger {
    RequestSerializerType_HTTP  = 0,
    RequestSerializerType_JSON
} RequestSerializerType;

/**
 *  自定义NSURLRequest，可以设置优先级
 */
typedef enum : NSInteger {
    NetRequestPriority_Low = -4L,
    NetRequestPriority_Default = 0,
    NetRequestPriority_High = 4,
} NetRequestPriority;