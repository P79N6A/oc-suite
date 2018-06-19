#import <Foundation/Foundation.h>
#import "_Foundation.h"

typedef enum : NSUInteger {
    _DBPerfType_Read = 1 << 0,            // 读为主
    _DBPerfType_Write = 1 << 1,           // 写为主
    _DBPerfType_ReadWrite = 1 << 2,       // 读写并发
} _DBPerfType;


// sqlite支持内存库???
// WAL
//sqlite 并发不行的， sqlite 的事务就是锁表，你无论开几个线程，只要访问的是同一张表，最后在 sqlite 那里都会被锁，实际上最后都是顺序执行的。-------------- 正解是队列
// 错误恢复

@interface _DBPerf : NSObject

@singleton( _DBPerf )

@end
