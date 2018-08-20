#import "_Protocol.h"
#import "_SerializationProtocol.h"
#import "_NetworkServerProtocol.h"

// 以下由外部库提供定义

// HTTP prot : "http", "https"
// AEDataKit: kAEDKServiceProtocolHttp, kAEDKServiceProtocolHttps

// HTTP method : "GET", "POST", "PUT"
// AEDataKit: kAEDKServiceMethodGet, kAEDKServiceMethodPOST, kAEDKServiceMethodHEAD, kAEDKServiceMethodDELETE

typedef void (^ _RequestFinishedBlock)(NSError *error, id responseModel, id extraData);
typedef void (^ _RequestBeforeBlock)(void);
typedef void (^ _RequestCurrentBlock)(int64_t total, int64_t current);
typedef id (^ _RequestAfterBlock)(NSError *error, id responseModel);

// 全局接口监控、截获、处理
typedef id (^ _RequestAllParameterFilterBlock)(id origin);
typedef void (^ _RequestAllBeforeBlock)(id process);
typedef id (^ _RequestAllAfterBlock)(NSError *error, id responseModel);

// 网络协议
@protocol _NetworkProtocol <_Protocol>

@property (nonatomic, strong) id<_NetworkServerProtocol> activeServer;

//////////////////////////////////////////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////

// MARK: - 辅助字段
@property (nonatomic, strong) NSString *dataField;
@property (nonatomic, strong) NSString *errorCodeField;
@property (nonatomic, strong) NSString *errorMessageField;
@property (nonatomic, strong) NSString *extraField;

@property (nonatomic, strong) _RequestAllParameterFilterBlock onParameterFilter;
@property (nonatomic, strong) _RequestAllBeforeBlock onBeforeHandler;
@property (nonatomic, strong) _RequestAllAfterBlock onAfterHandler; // 暂时不使用

// MARK: - 序列化
@property (nonatomic, strong) id<_SerializationProtocol> serialization;

// MARK: - 接口预注册
/**
 *  @brief 配置 普通服务
 *  @param identifier 标识符
 *  @param prot 协议类型名
 *  @param method 协议方法名
 *  @param domain 域名
 *  @param path 路径
 */
- (void)apiWith:(NSString *)identifier
           prot:(NSString *)prot
         method:(NSString *)method
         domain:(NSString *)domain
           path:(NSString *)path;

/**
 *  @brief 配置 上传服务, 如果上传二进制流，则filepath为空
 *  @param identifier 标识符
 *  @param prot 协议类型名
 *  @param method 协议方法名
 *  @param domain 域名
 *  @param path 路径
 *  @param filepath 上传源文件名
 */
- (void)apiUploadWith:(NSString *)identifier
                 prot:(NSString *)prot
               method:(NSString *)method
               domain:(NSString *)domain
                 path:(NSString *)path
             filepath:(NSString *)filepath;

/**
 *  @brief 配置 下载服务
 *  @param identifier 标识符
 *  @param prot 协议类型名
 *  @param method 协议方法名
 *  @param domain 域名
 *  @param path 路径
 *  @param filepath 下载目标文件名
 */
- (void)apiDownloadWith:(NSString *)identifier
                   prot:(NSString *)prot
                 method:(NSString *)method
                 domain:(NSString *)domain
                   path:(NSString *)path
               filepath:(NSString *)filepath;

// MARK: - 普通接口 1
/**
 *  @brief 手动解析 请求 (自行调用序列化方法，将json转化为object)
 *  @param identifier 标识符
 *  @param param 携带参数
 *  @param finishedHandler 结束接收句柄
 */
- (void)requestWith:(NSString *)identifier
         parameters:(NSDictionary *)param
           finished:(_RequestFinishedBlock)finishedHandler;

/**
 *  @brief 手动解析 请求
 *  @param identifier 标识符
 *  @param param 携带参数
 *  @param beforeHandler 前置截获句柄
 *  @param afterHandler 后置截获句柄
 *  @param finishedHandler 结束接收句柄
 */
- (void)requestWith:(NSString *)identifier
         parameters:(NSDictionary *)param
             before:(_RequestBeforeBlock)beforeHandler
              after:(_RequestAfterBlock)afterHandler
           finished:(_RequestFinishedBlock)finishedHandler; // 前后切面

@optional

// MARK: - 普通接口 2
/**
 *  @brief 自动解析 请求 (预先配置serilization)
 *  @param identifier 标识符
 *  @param cls 序列化对象类型
 *  @param param 携带参数
 *  @param finishedHandler 结束接收句柄
 */
- (void)requestWith:(NSString *)identifier
      responseClass:(Class)cls
         parameters:(NSDictionary *)param
           finished:(_RequestFinishedBlock)finishedHandler;

/**
 *  @brief 自动解析 请求
 *  @param identifier 标识符
 *  @param cls 序列化对象类型
 *  @param param 携带参数
 *  @param beforeHandler 前置截获句柄
 *  @param afterHandler 后置截获句柄
 *  @param finishedHandler 结束接收句柄
 */
- (void)requestWith:(NSString *)identifier
      responseClass:(Class)cls
         parameters:(NSDictionary *)param
              class:(Class)cls
             before:(_RequestBeforeBlock)beforeHandler
              after:(_RequestAfterBlock)afterHandler
           finished:(_RequestFinishedBlock)finishedHandler;

@required

// MARK: - 上传、下载接口
/**
 *  @brief 下载 请求
 *  @param identifier 标识符
 *  @param currentHandler 进度反馈句柄
 *  @param finishedHandler 结束接收句柄
 */
- (void)downloadWith:(NSString *)identifier
             current:(_RequestCurrentBlock)currentHandler
            finished:(_RequestFinishedBlock)finishedHandler;

/**
 *  @brief 上传 请求
 *  @param identifier 标识符
 *  @param currentHandler 进度反馈句柄
 *  @param finishedHandler 结束接收句柄
 */
- (void)uploadWith:(NSString *)identifier
           current:(_RequestCurrentBlock)currentHandler
          finished:(_RequestFinishedBlock)finishedHandler;

@end
