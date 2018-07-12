//
//  ComponentLog.h
// fallen.ink
//
//  Created by fallen.ink on 12/21/15.
//
//

#import "_service.h"

/**
 *  日志模块注意点
 
 0. 日志依赖：（CocoaLumerjack）（未填写）
 1. 日志目的：打印关键模块的日志
 2. 日志配置：config.xml（未实现：文件名等）
 3. 日志数据格式：节点与xml（未实现）
 4. 日志存储：文件、console（未实现：socket、syslog）
 5. 日志上传：uploader
 6. 日志处理的线程安全：（未研究：多线程）
 7. 日志分级
 8. 日志分上下文（上传接口需要什么信息？什么用户：session token 系统version等等。。。。每一条log需要什么信息？谁调用、什么接口）
 9. 日志打点：业务决定触点、围绕着关键接口的交互来。
 10. 日志数据：DomainType, Domain, Reason, params
 
 000. 其他参考日志依赖的第三方库的设计
 
 */

@interface LogService : _Service

@singleton( LogService )

@end
