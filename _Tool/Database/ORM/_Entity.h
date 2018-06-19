
/**
    1. 类型支持:
    int,long,signed,float,double,NSInteger,CGFloat,BOOL,NSString,NSMutableString,NSNumber,
    NSArray,NSMutableArray,NSDictionary,NSMutableDictionary,NSMapTable,NSHashTable,NSData,
    NSMutableData,UIImage,NSDate,NSURL,NSRange,CGRect,CGSize,CGPoint,自定义对象 等的存储.
 */

#import <Foundation/Foundation.h>

#import "_DBCore.h"

NS_ASSUME_NONNULL_BEGIN

// ----------------------------------
// MARK: 数据库 实体 协议
// ----------------------------------

@protocol _EntityProtocol <NSObject>

@optional

+ (NSString *)_primaryKey;

// 提示：“唯一约束”优先级高于"主键", 但需要自己维护这个字段
+ (NSString *)_uniqueKey;

/**
 *  数组中需要转换的模型类(‘字典转模型’ 或 ’模型转字典‘ 都需要实现该函数)
 *  @return 字典中的key是数组属性名，value是数组中存放模型的Class
 */
+ (NSDictionary *)_objectClassInArray;

/**
 *  如果模型中有自定义类变量,则实现该函数对应进行集合到模型的转换.
 */
+ (NSDictionary *)_objectClassForCustom;

/**
 *  将模型中对应的自定义类变量转换为字典.
 */
+ (NSDictionary *)_dictForCustomClass;

/**
 *  替换变量的功能(及当字典的key和属性名不一样时，进行映射对应起来)
 */
+ (NSDictionary *)db_replacedKeyFromPropertyName;

@end

// ----------------------------------
// MARK: 数据库 实体 实现
// ----------------------------------

@interface _Entity : NSObject <_EntityProtocol>

// 预定义 常用字段

@prop_strong( NSNumber *, id )
@prop_copy( NSString *, createTime )
@prop_copy( NSString *, updateTime )

+ (id)firstObjet;
+ (id)lastObject;

/**
 *  判断这个类的数据表是否已经存在.
 */
+ (BOOL)isExist;

- (BOOL)save;
- (void)saveAsync:(DatabaseSuccessBlock)complete;

/**
 *  同步存储或更新.
 *  当"唯一约束"或"主键"存在时，此接口会更新旧数据,没有则存储新数据.
 *  提示：“唯一约束”优先级高于"主键".
 */
- (BOOL)saveOrUpdate;
- (void)saveOrUpdateAsync:(DatabaseSuccessBlock)complete;

// ??? ignoreKeys 放在协议中去？
+ (BOOL)saveArray:(NSArray *)array ignoreKeys:(NSArray * const)ignoreKeys;
+ (void)saveArray:(NSArray *)array ignoreKeys:(NSArray * const)ignoreKeys complete:(DatabaseSuccessBlock)complete;
+ (void)saveOrUpdateArray:(NSArray *)array ignoreKeys:(NSArray * const)ignoreKeys;
+ (void)saveOrUpdateAsyncArray:(NSArray *)array ignoreKeys:(NSArray * const)ignoreKeys;

- (BOOL)saveIgnoredKeys:(NSArray * const)ignoredKeys;
- (void)saveAsyncIgnoreKeys:(NSArray * const)ignoredKeys complete:(DatabaseSuccessBlock)complete;

/**
 *  同步覆盖存储.
 *  覆盖掉原来的数据,只存储当前的数据.
 */
- (BOOL)cover;
- (void)coverAsync:(DatabaseSuccessBlock)complete;
- (BOOL)coverIgnoredKeys:(NSArray * const)ignoredKeys;
- (void)coverAsyncIgnoredKeys:(NSArray * const)ignoredKeys complete:(DatabaseSuccessBlock)complete;

/**
 *  同步查询所有结果.
 *  温馨提示: 当数据量巨大时,请用范围接口进行分页查询,避免查询出来的数据量过大导致程序崩溃.
 */
+ (NSArray *)findAll;
+ (void)findAllAsync:(DatabaseCompleteBlcok)complete;

/**
 * 同步查询所有结果.
 * @limit 每次查询限制的条数,0则无限制.
 * @desc YES:降序，NO:升序.
 */
+ (NSArray *)findAllWithLimit:(NSInteger)limit orderBy:( nullable NSString * )orderBy desc:(BOOL)desc;
+ (void)findAllAsyncWithLimit:(NSInteger)limit orderBy:(NSString *)orderBy desc:(BOOL)desc complete:(DatabaseCompleteBlcok)complete;

/**
 *  同步查询所有结果.
 *  @range 查询的范围(从location开始的后面length条).
 *  @desc YES:降序，NO:升序.
 */
+ (NSArray *)findAllWithRange:(NSRange)range orderBy:( nullable NSString * )orderBy desc:(BOOL)desc;
+ (void)findAllAsyncWithRange:(NSRange)range orderBy:(NSString *)orderBy desc:(BOOL)desc complete:(DatabaseCompleteBlcok)complete;

/**
 *  同步条件查询所有结果.
 
 *  @param where 条件数组，形式@[@"name",@"=",@"标哥",@"age",@"=>",@(25)],即查询name=标哥,age=>25的数据;
 *  可以为nil,为nil时查询所有数据;
 
 *  目前不支持keypath的key,即嵌套的自定义类, 形式如@[@"user.name",@"=",@"习大大"]暂不支持 (有专门的keyPath查询接口).
 */
+ (NSArray *)findWhere:(NSArray *)where;
+ (void)findWhere:(NSArray *)where complete:(DatabaseCompleteBlcok)complete;

/**
 *  @param format 传入sql条件参数,语句来进行查询,方便开发者自由扩展.
 *  使用规则请看demo或如下事例:
 *  支持keyPath.
 
 *  1.查询name等于爸爸和age等于45,或者name等于马哥的数据.  此接口是为了方便开发者自由扩展更深层次的查询条件逻辑.
 NSArray* arrayConds1 = [People findFormatSqlConditions:@"where %@=%@ and %@=%@ or %@=%@",bg_sqlKey(@"age"),bg_sqlValue(@(45)),bg_sqlKey(@"name"),bg_sqlValue(@"爸爸"),bg_sqlKey(@"name"),bg_sqlValue(@"马哥")];
 
 *  2.查询user.student.human.body等于小芳 和 user1.name中包含fuck这个字符串的数据.
 [People bg_findFormatSqlConditions:@"where %@",bg_keyPathValues(@[@"user.student.human.body",bg_equal,@"小芳",@"user1.name",bg_contains,@"fuck"])];
 
 *  3.查询user.student.human.body等于小芳,user1.name中包含fuck这个字符串 和 name等于爸爸的数据.
 NSArray* arrayConds3 = [People bg_findFormatSqlConditions:@"where %@ and %@=%@",bg_keyPathValues(@[@"user.student.human.body",bg_equal,@"小芳",@"user1.name",bg_contains,@"fuck"]),bg_sqlKey(@"name"),bg_sqlValue(@"爸爸")];
 */
+ (NSArray *)findFormatSqlConditions:(NSString *)format,... NS_FORMAT_FUNCTION(1,2);

/**
 keyPath查询
 同步查询所有keyPath条件结果.
 @keyPathValues数组,形式@[@"user.student.name",bg_equal,@"小芳",@"user.student.conten",bg_contains,@"书"]
 即查询user.student.name=@"小芳" 和 user.student.content中包含@“书”这个字符串的对象.
 */
+ (NSArray *)findForKeyPathAndValues:(NSArray *)keyPathValues;
+ (void)findAsyncForKeyPathAndValues:(NSArray *)keyPathValues complete:(DatabaseCompleteBlcok)complete;

/**
 查询某一时间段的数据.(存入时间或更新时间)
 @dateTime 参数格式：
 2017 即查询2017年的数据
 2017-07 即查询2017年7月的数据
 2017-07-19 即查询2017年7月19日的数据
 2017-07-19 16 即查询2017年7月19日16时的数据
 2017-07-19 16:17 即查询2017年7月19日16时17分的数据
 2017-07-19 16:17:53 即查询2017年7月19日16时17分53秒的数据
 */
+ (NSArray *)findWithType:(bg_dataTimeType)type dateTime:(NSString *)dateTime;

/**
 同步更新数据.
 @where 条件数组，形式@[@"name",@"=",@"标哥",@"age",@"=>",@(25)],即更新name=标哥,age=>25的数据;
 可以为nil,nil时更新所有数据;
 不支持keypath的key,即嵌套的自定义类, 形式如@[@"user.name",@"=",@"习大大"]暂不支持.
 */
- (BOOL)updateWhere:(NSArray *)where;

/**
 同步更新数据.
 @where 条件数组，形式@[@"name",@"=",@"标哥",@"age",@"=>",@(25)],即更新name=标哥,age=>25的数据.
 可以为nil,nil时更新所有数据;
 @ignoreKeys 忽略哪些key不用更新.
 不支持keypath的key,即嵌套的自定义类, 形式如@[@"user.name",@"=",@"习大大"]暂不支持(有专门的keyPath更新接口).
 */
- (BOOL)updateWhere:(NSArray *)where ignoreKeys:(NSArray * const)ignoreKeys;

/**
 异步更新.
 @where 条件数组，形式@[@"name",@"=",@"标哥",@"age",@"=>",@(25)],即更新name=标哥,age=>25的数据;
 可以为nil,nil时更新所有数据;
 不支持keypath的key,即嵌套的自定义类, 形式如@[@"user.name",@"=",@"习大大"]暂不支持.
 */
- (void)updateAsync:(NSArray *)where complete:(DatabaseSuccessBlock)complete;

/**
 @format 传入sql条件参数,语句来进行更新,方便开发者自由扩展.
 此接口不支持keyPath.
 使用规则请看demo或如下事例:
 1.将People类中name等于"马云爸爸"的数据的name更新为"马化腾"
 [People bg_updateFormatSqlConditions:@"set %@=%@ where %@=%@",bg_sqlKey(@"name"),bg_sqlValue(@"马化腾"),bg_sqlKey(@"name"),bg_sqlValue(@"马云爸爸")];
 */
+ (BOOL)updateFormatSqlConditions:(NSString *)format,... NS_FORMAT_FUNCTION(1,2);
/**
 @format 传入sql条件参数,语句来进行更新,方便开发者自由扩展.
 支持keyPath.
 使用规则请看demo或如下事例:
 1.将People类数据中user.student.human.body等于"小芳"的数据更新为当前对象的数据.
 [p bg_updateFormatSqlConditions:@"where %@",bg_keyPathValues(@[@"user.student.human.body",bg_equal,@"小芳"])];
 2.将People类中name等于"马云爸爸"的数据更新为当前对象的数据.
 [p bg_updateFormatSqlConditions:@"where %@=%@",bg_sqlKey(@"name"),bg_sqlValue(@"马云爸爸")];
 */
- (BOOL)updateFormatSqlConditions:(NSString *)format,... NS_FORMAT_FUNCTION(1,2);

/**
 @format 传入sql条件参数,语句来进行更新,方便开发者自由扩展.
 支持keyPath.
 使用规则请看demo或如下事例:
 1.将People类数据中user.student.human.body等于"小芳"的数据更新为当前对象的数据(忽略name不要更新).
 NSString* conditions = [NSString stringWithFormat:@"where %@",bg_keyPathValues(@[@"user.student.human.body",bg_equal,@"小芳"])];
 [p bg_updateFormatSqlConditions:conditions IgnoreKeys:@[@"name"]];
 2.将People类中name等于"马云爸爸"的数据更新为当前对象的数据.
 NSString* conditions = [NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"name"),bg_sqlValue(@"马云爸爸")])];
 [p bg_updateFormatSqlConditions:conditions IgnoreKeys:nil];
 @ignoreKeys 忽略哪些key不用更新.
 */
- (BOOL)updateFormatSqlConditions:(NSString *)conditions ignoreKeys:(NSArray * const)ignoreKeys;

/**
 根据keypath更新数据.
 同步更新.
 @keyPathValues数组,形式@[@"user.student.name",bg_equal,@"小芳",@"user.student.conten",bg_contains,@"书"]
 即更新user.student.name=@"小芳" 和 user.student.content中包含@“书”这个字符串的对象.
 */
- (BOOL)updateForKeyPathAndValues:(NSArray *)keyPathValues;
- (void)updateAsyncForKeyPathAndValues:(NSArray *)keyPathValues complete:(DatabaseSuccessBlock)complete;

/**
 *  删除数据.
 *  @where 条件数组，形式@[@"name",@"=",@"标哥",@"age",@"=>",@(25)],即删除name=标哥,age=>25的数据.
 不可以为nil;
 *  不支持keypath的key,即嵌套的自定义类, 形式如@[@"user.name",@"=",@"习大大"]暂不支持
 */
+ (BOOL)deleteWhere:(NSArray *)where;
+ (void)deleteAsync:(NSArray *)where complete:(DatabaseSuccessBlock)complete;

/**
 @format 传入sql条件参数,语句来进行更新,方便开发者自由扩展.
 支持keyPath.
 使用规则请看demo或如下事例:
 1.删除People类中name等于"美国队长"的数据
 [People bg_deleteFormatSqlConditions:@"where %@=%@",bg_sqlKey(@"name"),bg_sqlValue(@"美国队长")];
 2.删除People类中user.student.human.body等于"小芳"的数据
 [People bg_deleteFormatSqlConditions:@"where %@",bg_keyPathValues(@[@"user.student.human.body",bg_equal,@"小芳"])];
 3.删除People类中name等于"美国队长" 和 user.student.human.body等于"小芳"的数据
 [People bg_deleteFormatSqlConditions:@"where %@=%@ and %@",bg_sqlKey(@"name"),bg_sqlValue(@"美国队长"),bg_keyPathValues(@[@"user.student.human.body",bg_equal,@"小芳"])];
 */
+ (BOOL)deleteFormatSqlConditions:(NSString *)format,... NS_FORMAT_FUNCTION(1,2);

/**
 *  根据keypath删除数据.
 *  同步删除.
 *  @keyPathValues数组,形式@[@"user.student.name",bg_equal,@"小芳",@"user.student.conten",bg_contains,@"书"]
 *  即删除user.student.name=@"小芳" 和 user.student.content中包含@“书”这个字符串的对象.
 */
+ (BOOL)deleteForKeyPathAndValues:(NSArray *)keyPathValues;
+ (void)deleteAsyncForKeyPathAndValues:(NSArray *)keyPathValues complete:(DatabaseSuccessBlock)complete;

+ (BOOL)deleteRow:(NSInteger)row; // 删除某一行数据row 从第0行开始算起.
+ (BOOL)deleteFirstObject;
+ (BOOL)deleteLastObject;

/**
 *  @brief 清理数据，不删表
 */
+ (BOOL)clear;
+ (void)clear:(DatabaseSuccessBlock)complete;

+ (BOOL)drop;
+ (void)drop:(DatabaseSuccessBlock)complete;

/**
 查询该表中有多少条数据
 @where 条件数组，形式@[@"name",@"=",@"标哥",@"age",@"=>",@(25)],即name=标哥,age=>25的数据有多少条,为nil时返回全部数据的条数.
 不支持keypath的key,即嵌套的自定义类, 形式如@[@"user.name",@"=",@"习大大"]暂不支持(有专门的keyPath查询条数接口).
 */
+ (NSInteger)countWhere:(NSArray *)where;

/**
 @format 传入sql条件参数,语句来查询数据条数,方便开发者自由扩展.
 支持keyPath.
 使用规则请看demo或如下事例:
 1.查询People类中name等于"美国队长"的数据条数.
 [People bg_countFormatSqlConditions:@"where %@=%@",bg_sqlKey(@"name"),bg_sqlValue(@"美国队长")];
 2.查询People类中user.student.human.body等于"小芳"的数据条数.
 [People bg_countFormatSqlConditions:@"where %@",bg_keyPathValues(@[@"user.student.human.body",bg_equal,@"小芳"])];
 3.查询People类中name等于"美国队长" 和 user.student.human.body等于"小芳"的数据条数.
 [People bg_countFormatSqlConditions:@"where %@=%@ and %@",bg_sqlKey(@"name"),bg_sqlValue(@"美国队长"),bg_keyPathValues(@[@"user.student.human.body",bg_equal,@"小芳"])];
 */
+ (NSInteger)countFormatSqlConditions:(NSString *)format,... NS_FORMAT_FUNCTION(1,2);
/**
 keyPath查询该表中有多少条数据
 @keyPathValues数组,形式@[@"user.student.name",bg_equal,@"小芳",@"user.student.conten",bg_contains,@"书"]
 即查询user.student.name=@"小芳" 和 user.student.content中包含@“书”这个字符串的对象的条数.
 */
+ (NSInteger)countForKeyPathAndValues:(NSArray *)keyPathValues;

/**
 直接调用sqliteb的原生函数计算sun,min,max,avg等.
 用法：NSInteger num = [People bg_sqliteMethodWithType:bg_sum key:@"age"];
 提示: @param key -> 不支持keyPath , @param where -> 支持keyPath
 */
+ (NSInteger)sqliteMethodWithType:(bg_sqliteMethodType)methodType key:(NSString *)key where:(NSString *)where,...;

/**
 获取本类数据表当前版本号.
 */
+ (NSInteger)version;

/**
 刷新,当类"唯一约束"改变时,调用此接口刷新一下.
 同步刷新.
 @param version 版本号,从1开始,依次往后递增.
 说明: 本次更新版本号不得 低于或等于 上次的版本号,否则不会更新.
 */
+ (DatabaseDealState)updateVersion:(NSInteger)version;

/**
 刷新,当类"唯一约束"改变时,调用此接口刷新一下.
 异步刷新.
 @version 版本号,从1开始,依次往后递增.
 说明: 本次更新版本号不得 低于或等于 上次的版本号,否则不会更新.
 */
+ (void)updateVersionAsync:(NSInteger)version complete:(DatabaseDealStateBlock)complete;

/**
 刷新,当类"唯一约束"改变时,调用此接口刷新一下.
 同步刷新.
 @version 版本号,从1开始,依次往后递增.
 @keyDict 拷贝的对应key集合,形式@{@"新Key1":@"旧Key1",@"新Key2":@"旧Key2"},即将本类以前的变量 “旧Key1” 的数据拷贝给现在本类的变量“新Key1”，其他依此推类.
 (特别提示: 这里只要写那些改变了的变量名就可以了,没有改变的不要写)，比如A以前有3个变量,分别为a,b,c；现在变成了a,b,d；那只要写@{@"d":@"c"}就可以了，即只写变化了的变量名映射集合.
 说明: 本次更新版本号不得 低于或等于 上次的版本号,否则不会更新.
 */
+ (DatabaseDealState)updateVersion:(NSInteger)version keyDict:(NSDictionary* const)keydict;

/**
 刷新,当类"唯一约束"改变时,调用此接口刷新一下.
 异步刷新.
 @version 版本号,从1开始,依次往后递增.
 @keyDict 拷贝的对应key集合,形式@{@"新Key1":@"旧Key1",@"新Key2":@"旧Key2"},即将本类以前的变量 “旧Key1” 的数据拷贝给现在本类的变量“新Key1”，其他依此推类.
 (特别提示: 这里只要写那些改变了的变量名就可以了,没有改变的不要写)，比如A以前有3个变量,分别为a,b,c；现在变成了a,b,d；那只要写@{@"d":@"c"}就可以了，即只写变化了的变量名映射集合.
 说明: 本次更新版本号不得 低于或等于 上次的版本号,否则不会更新.
 */
+ (void)updateVersionAsync:(NSInteger)version keyDict:(NSDictionary * const)keydict complete:(DatabaseDealStateBlock)complete;

/**
 将某表的数据拷贝给另一个表
 同步复制.
 @destCla 目标类.
 @keyDict 拷贝的对应key集合,形式@{@"srcKey1":@"destKey1",@"srcKey2":@"destKey2"},即将源类srcCla中的变量值拷贝给目标类destCla中的变量destKey1，srcKey2和destKey2同理对应,依此推类.
 @append YES: 不会覆盖destCla的原数据,在其末尾继续添加；NO: 覆盖掉destCla原数据,即将原数据删掉,然后将新数据拷贝过来.
 */
+ (DatabaseDealState)copyToClass:(__unsafe_unretained Class)destCla keyDict:(NSDictionary * const)keydict append:(BOOL)append;
/**
 将某表的数据拷贝给另一个表
 异步复制.
 @destCla 目标类.
 @keyDict 拷贝的对应key集合,形式@{@"srcKey1":@"destKey1",@"srcKey2":@"destKey2"},即将源类srcCla中的变量值拷贝给目标类destCla中的变量destKey1，srcKey2和destKey2同理对应,依此推类.
 @append YES: 不会覆盖destCla的原数据,在其末尾继续添加；NO: 覆盖掉destCla原数据,即将原数据删掉,然后将新数据拷贝过来.
 */
+ (void)copyAsyncToClass:(__unsafe_unretained Class)destCla keyDict:(NSDictionary * const)keydict append:(BOOL)append complete:(DatabaseDealStateBlock)complete;

#pragma mark 下面附加字典转模型API,简单好用,在只需要字典转模型功能的情况下,可以不必要再引入MJExtension那么多文件,造成代码冗余,缩减安装包.
/**
 字典转模型.
 @keyValues 字典(NSDictionary)或json格式字符.
 说明:如果模型中有数组且存放的是自定义的类(NSString等系统自带的类型就不必要了),那就实现objectClassInArray这个函数返回一个字典,key是数组名称,value是自定的类Class,用法跟MJExtension一样.
 */
+ (id)objectWithKeyValues:(id const)keyValues;
+ (id)objectWithDictionary:(NSDictionary * const)dictionary;
/**
 直接传数组批量处理;
 注:array中的元素是字典,否则出错.
 */
+ (NSArray *)objectArrayWithKeyValuesArray:(NSArray * const)array;

/**
 模型转字典.
 @ignoredKeys 忽略掉模型中的哪些key(即模型变量)不要转,nil时全部转成字典.
 */
- (NSMutableDictionary *)keyValuesIgnoredKeys:(NSArray *)ignoredKeys;

@end

NS_ASSUME_NONNULL_END
