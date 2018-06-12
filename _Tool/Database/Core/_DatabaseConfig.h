
#import <Foundation/Foundation.h>

// ----------------------------------
// MARK: 声明
// ----------------------------------

#import "_typedef.h"

#define BG @"BG_"

//keyPath查询用的关系，bg_equal:等于的关系；bg_contains：包含的关系.
#define bg_equal @"Relation_Equal"
#define bg_contains @"Relation_Contains"

typedef enum : NSUInteger {
    DatabaseOperationInsert,    // 插入
    DatabaseOperationUpdate,    // 更新
    DatabaseOperationDelete,    // 删除
    DatabaseOperationDrop       // 删表
} DatabaseOperation;

typedef enum : NSUInteger {
    DatabaseDealStateError = -1,        // 处理失败
    DatabaseDealStateIncomplete = 0,    // 处理不完整
    DatabaseDealStateComplete = 1,      // 处理完整
} DatabaseDealState;

typedef BOOLBlock DatabaseSuccessBlock;
typedef ArrayBlock DatabaseCompleteBlcok;
typedef void(^ DatabaseDealStateBlock)(DatabaseDealState result);
typedef void(^ DatabaseOperationBlock)(DatabaseOperation result);

typedef NS_ENUM(NSInteger,bg_sqliteMethodType){//sqlite数据库原生方法枚举
    bg_min,//求最小值
    bg_max,//求最大值
    bg_sum,//求总和值
    bg_avg//求平均值
};

typedef NS_ENUM(NSInteger,bg_dataTimeType){
    bg_createTime,//存储时间
    bg_updateTime,//更新时间
};

/**
 封装处理传入数据库的key和value.
 */
extern NSString* _Nonnull bg_sqlKey(NSString* _Nonnull key);
extern NSString* _Nonnull bg_sqlValue(id _Nonnull value);
/**
 根据keyPath和Value的数组, 封装成数据库语句，来操作库.
 */
extern NSString* _Nonnull bg_keyPathValues(NSArray* _Nonnull keyPathValues);
/**
 直接执行sql语句;
 @className 要操作的类名.(如果不传入，那返回的结果是一个字典，里面包含了数据库字段名和字段值)
 提示：字段名要增加BG_前缀
 */
extern id _Nullable bg_executeSql(NSString* _Nonnull sql,NSString* _Nullable className);
/**
 自定义数据库名称.
 */
extern void bg_setSqliteName(NSString*_Nonnull sqliteName);
/**
 删除数据库文件
 */
extern BOOL bg_deleteSqlite(NSString*_Nonnull sqliteName);
/**
 设置操作过程中不可关闭数据库(即closeDB函数无效).
 默认是NO.
 */
extern void bg_setDisableCloseDB(BOOL disableCloseDB);

/**
 事务操作.
 @param block return 返回YES提交事务, 返回NO回滚事务.
 */
extern void bg_inTransaction(BOOL (^ _Nonnull block)());

/**
 清除缓存
 */
extern void bg_cleanCache();

// ----------------------------------
// MARK: 数据库 配置
// ----------------------------------

@interface _DatabaseConfig : NSObject

@end
