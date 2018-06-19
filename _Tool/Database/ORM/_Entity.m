
#import <objc/message.h>
#import <UIKit/UIKit.h>
#import "_Entity.h"
#import "_DBCore.h"
#import "_DBTool.h"

// ----------------------------------
// MARK: 数据库 实体 实现
// ----------------------------------

@implementation _Entity

@def_prop_cate_strong( NSNumber *, id, setId)
@def_prop_cate_strong( NSString *, createTime, setCreateTime)
@def_prop_cate_strong( NSString *, updateTime, setUpdateTime)

+ (id)firstObjet {
    NSArray *array = [self findAllWithLimit:1 orderBy:nil desc:NO];
    return array.count ? array.firstObject : nil;
}

+ (id)lastObject {
    NSArray *array = [self findAllWithLimit:1 orderBy:self._primaryKey desc:YES];
    return array.count ? array.firstObject : nil;
}

// ----------------------------------
// MARK: 数据库 实体 协议 -
// ----------------------------------

+ (NSString *)_primaryKey {
    return @"id";
}

+ (NSString *)_uniqueKey {
    return nil;
}

+ (NSDictionary *)_objectClassInArray {
    return nil;
}

+ (NSDictionary *)_objectClassForCustom {
    return nil;
}

+ (NSDictionary *)_dictForCustomClass {
    return nil;
}

+ (NSDictionary *)db_replacedKeyFromPropertyName {
    return nil;
}

// ----------------------------------
// MARK: -
// ----------------------------------

+ (BOOL)isExist {
    __block BOOL result;
    [[_Database sharedInstance] isExistWithTableName:NSStringFromClass([self class]) complete:^(BOOL isSuccess) {
        result  = isSuccess;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}

- (BOOL)save {
    __block BOOL result;
    [[_Database sharedInstance] saveObject:self ignoredKeys:nil complete:^(BOOL isSuccess) {
        result = isSuccess;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}

- (void)saveAsync:(DatabaseSuccessBlock)complete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        BOOL flag = [self save];
        bg_completeBlock(flag);
    });
}

- (BOOL)saveOrUpdate {
    NSString *uniqueKey = [self.class _uniqueKey];
    if (uniqueKey) {
        id uniqueKeyVlaue = [self valueForKey:uniqueKey];
        NSInteger count = [[self class] countWhere:@[uniqueKey,@"=",uniqueKeyVlaue]];
        if (count) { //有数据存在就更新.
            return [self updateWhere:@[uniqueKey,@"=",uniqueKeyVlaue]];
        } else { //没有就存储.
            return [self save];
        }
    } else {
        if (self.id == nil) {
            return [self save];
        } else {
            return [self updateWhere:@[stringify(id),@"=",self.id]];
        }
    }
}

- (void)saveOrUpdateAsync:(DatabaseSuccessBlock)complete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        BOOL result = [self saveOrUpdate];
        bg_completeBlock(result);
    });
}

+ (BOOL)saveArray:(NSArray *)array ignoreKeys:(NSArray * const)ignoreKeys {
    NSAssert(array||array.count,@"数组没有元素!");
    __block BOOL result = YES;
        [[_Database sharedInstance] saveObjects:array ignoredKeys:ignoreKeys complete:^(BOOL isSuccess) {
            result = isSuccess;
        }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}

+ (void)saveArray:(NSArray*)array ignoreKeys:(NSArray * const)ignoreKeys complete:(DatabaseSuccessBlock)complete{
    NSAssert(array||array.count,@"数组没有元素!");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        BOOL flag = [self saveArray:array ignoreKeys:ignoreKeys];
        bg_completeBlock(flag);
    });
}

+ (void)saveOrUpdateArray:(NSArray*)array ignoreKeys:(NSArray * const)ignoreKeys {
    NSAssert(array||array.count,@"数组没有元素!");
    NSString* uniqueKey = [self _uniqueKey];
    if (uniqueKey) {
        id uniqueKeyVlaue = [array.lastObject valueForKey:uniqueKey];
        NSInteger count = [[array.lastObject class] countWhere:@[uniqueKey,@"=",uniqueKeyVlaue]];
        if (count){//有数据存在就更新.
            //此处更新数据.
            [[_Database sharedInstance] updateObjects:array ignoredKeys:ignoreKeys complete:nil];
        }else{//没有就存储.
            [self saveArray:array ignoreKeys:ignoreKeys];
        }
    }else{
        [self saveArray:array ignoreKeys:ignoreKeys];
    }
}

+ (void)saveOrUpdateAsyncArray:(NSArray*)array ignoreKeys:(NSArray* const)ignoreKeys {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        [self saveOrUpdateArray:array ignoreKeys:ignoreKeys];
    });
}

- (BOOL)saveIgnoredKeys:(NSArray * const)ignoredKeys {
    __block BOOL result;
    [[_Database sharedInstance] saveObject:self ignoredKeys:ignoredKeys complete:^(BOOL isSuccess) {
        result = isSuccess;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}

- (void)saveAsyncIgnoreKeys:(NSArray* const _Nonnull)ignoredKeys complete:(DatabaseSuccessBlock)complete{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        BOOL flag = [self saveIgnoredKeys:ignoredKeys];
        bg_completeBlock(flag);
    });

}

#pragma mark -

- (BOOL)cover  {
    __block BOOL result;
    [[_Database sharedInstance] clearWithClass:[self class] complete:^(BOOL isSuccess) {
        if(isSuccess)
            [[_Database sharedInstance] saveObject:self ignoredKeys:nil complete:^(BOOL isSuccess) {
                result = isSuccess;
            }];
        else
            result = NO;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}

- (void)coverAsync:(DatabaseSuccessBlock)complete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        BOOL flag = [self cover];
        bg_completeBlock(flag);
    });
    
}

- (BOOL)coverIgnoredKeys:(NSArray* const _Nonnull)ignoredKeys {
    __block BOOL result;
    [[_Database sharedInstance] clearWithClass:[self class] complete:^(BOOL isSuccess) {
        if(isSuccess)
            [[_Database sharedInstance] saveObject:self ignoredKeys:ignoredKeys complete:^(BOOL isSuccess) {
                result = isSuccess;
            }];
        else
            result = NO;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}

- (void)coverAsyncIgnoredKeys:(NSArray* const _Nonnull)ignoredKeys complete:(DatabaseSuccessBlock)complete{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        BOOL flag = [self coverIgnoredKeys:ignoredKeys];
        bg_completeBlock(flag);
    });
}

+ (NSArray*)findAll {
    __block NSArray* results;
    [[_Database sharedInstance] queryObjectWithClass:[self class] where:nil param:nil complete:^(NSArray * _Nullable array) {
        results = array;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return results;
}

+ (void)findAllAsync:(DatabaseCompleteBlcok)complete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSArray* array = [self findAll];
        bg_completeBlock(array);
    });
}

+ (id)objectWithRow:(NSInteger)row {
    NSArray *array = [self findAllWithRange:NSMakeRange(row, 1) orderBy:nil desc:NO];
    
    return (array && array.count) ? array.firstObject : nil;
}

+ (NSArray *)findAllWithLimit:(NSInteger)limit orderBy:(NSString *)orderBy desc:(BOOL)desc {
    NSMutableString* param = [NSMutableString string];
    !(orderBy&&desc)?:[param appendFormat:@"order by %@%@ desc",BG,orderBy];
    !param.length?:[param appendString:@" "];
    !limit?:[param appendFormat:@"limit %@",@(limit)];
    param = param.length?param:nil;
    __block NSArray* results;
     [[_Database sharedInstance] queryObjectWithClass:[self class] where:nil param:param complete:^(NSArray * _Nullable array) {
         results = array;
     }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return results;
}

+ (void)findAllAsyncWithLimit:(NSInteger)limit orderBy:(NSString*)orderBy desc:(BOOL)desc complete:(DatabaseCompleteBlcok)complete{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSArray* results = [self findAllWithLimit:limit orderBy:orderBy desc:desc];
        bg_completeBlock(results);
    });
}

+ (NSArray *)findAllWithRange:(NSRange)range orderBy:(NSString *)orderBy desc:(BOOL)desc {
    NSMutableString* param = [NSMutableString string];
    !(orderBy&&desc)?:[param appendFormat:@"order by %@%@ desc ",BG,orderBy];
    NSAssert((range.location>=0)&&(range.length>0),@"range参数错误,location应该大于或等于零,length应该大于零");
    [param appendFormat:@"limit %@,%@",@(range.location),@(range.length)];
    __block NSArray* results;
    [[_Database sharedInstance] queryObjectWithClass:[self class] where:nil param:param complete:^(NSArray * _Nullable array) {
        results = array;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return results;
}

+ (void)findAllAsyncWithRange:(NSRange)range orderBy:(NSString *)orderBy desc:(BOOL)desc complete:(DatabaseCompleteBlcok)complete{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSArray* results = [self findAllWithRange:range orderBy:orderBy desc:desc];
        bg_completeBlock(results);
    });
}

+ (NSArray *)findWhere:(NSArray *)where {
    __block NSArray* results;
    [[_Database sharedInstance] queryObjectWithClass:[self class] keys:nil where:where complete:^(NSArray * _Nullable array) {
        results = array;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return results;
}

+ (void)findWhere:(NSArray *)where complete:(DatabaseCompleteBlcok)complete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSArray* array = [self findWhere:where];
        bg_completeBlock(array);
    });
}

+ (NSArray *)findFormatSqlConditions:(NSString *)format,... NS_FORMAT_FUNCTION(1,2){
    va_list ap;
    va_start (ap, format);
    NSString *conditions = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end (ap);
    NSString* tableName = NSStringFromClass([self class]);
    __block NSArray* results;
    [[_Database sharedInstance] queryWithTableName:tableName conditions:conditions complete:^(NSArray * _Nullable array) {
        results = [_DBTool tansformDataFromSqlDataWithTableName:tableName array:array];
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return results;
}

+ (NSArray *)findForKeyPathAndValues:(NSArray *)keyPathValues {
    __block NSArray *results;
    [[_Database sharedInstance] queryObjectWithClass:[self class] forKeyPathAndValues:keyPathValues complete:^(NSArray * _Nullable array) {
        results = array;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return results;
}

+ (void)findAsyncForKeyPathAndValues:(NSArray *)keyPathValues complete:(DatabaseCompleteBlcok)complete{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSArray* array = [self findForKeyPathAndValues:keyPathValues];
        bg_completeBlock(array);
    });
}

+ (NSArray *)findWithType:(bg_dataTimeType)type dateTime:(nonnull NSString *)dateTime {
    NSMutableString* like = [NSMutableString string];
    [like appendFormat:@"'%@",dateTime];
    [like appendString:@"%'"];
    if(type == bg_createTime){
        return [self findFormatSqlConditions:@"where %@ like %@",bg_sqlKey(stringify(createTime)),like];
    } else {
        return [self findFormatSqlConditions:@"where %@ like %@",bg_sqlKey(stringify(updateTime)),like];
    }
}

- (BOOL)updateWhere:(NSArray *)where {
    __block BOOL result;
    [[_Database sharedInstance] updateWithObject:self where:where ignoreKeys:nil complete:^(BOOL isSuccess) {
        result = isSuccess;
    }];
    
    // 关闭数据库
    [[_Database sharedInstance] closeDB];
    
    return result;
}

- (BOOL)updateWhere:(NSArray *)where ignoreKeys:(NSArray * const)ignoreKeys {
    __block BOOL result;
    [[_Database sharedInstance] updateWithObject:self where:where ignoreKeys:ignoreKeys complete:^(BOOL isSuccess) {
        result = isSuccess;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}

- (void)updateAsync:(NSArray *)where complete:(DatabaseSuccessBlock)complete{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        BOOL flag = [self updateWhere:where];
        bg_completeBlock(flag);
    });
}

+ (BOOL)updateFormatSqlConditions:(NSString*)format,... NS_FORMAT_FUNCTION(1,2){
    va_list ap;
    va_start (ap, format);
    NSString *conditions = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end (ap);
    NSAssert([conditions hasPrefix:@"set"],@"更新条件要以set开头!");
    NSString* setAppend = [NSString stringWithFormat:@"set %@=%@,",bg_sqlKey(stringify(updateTime)),bg_sqlValue([_DBTool stringWithDate:[NSDate new]])];
    conditions = [conditions stringByReplacingOccurrencesOfString:@"set" withString:setAppend];
    NSString* tableName = NSStringFromClass([self class]);
    //加入更新时间字段值.
    __block BOOL result;
    [[_Database sharedInstance] updateWithTableName:tableName valueDict:nil conditions:conditions complete:^(BOOL isSuccess) {
        result = isSuccess;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}

- (BOOL)updateFormatSqlConditions:(NSString*)format,... NS_FORMAT_FUNCTION(1,2){
    va_list ap;
    va_start (ap, format);
    NSString *conditions = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end (ap);
    NSString* tableName = NSStringFromClass([self class]);
    NSDictionary* valueDict = [_DBTool getDictWithObject:self ignoredKeys:nil isUpdate:YES];
    __block BOOL result;
    [[_Database sharedInstance] updateWithTableName:tableName valueDict:valueDict conditions:conditions complete:^(BOOL isSuccess) {
        result = isSuccess;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}

- (BOOL)updateFormatSqlConditions:(NSString*)conditions ignoreKeys:(NSArray * const)ignoreKeys{
    __block BOOL result;
    [[_Database sharedInstance] updateObject:self ignoreKeys:ignoreKeys conditions:conditions complete:^(BOOL isSuccess) {
        result = isSuccess;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}

- (BOOL)updateForKeyPathAndValues:(NSArray *)keyPathValues {
    __block BOOL result;
    [[_Database sharedInstance] updateWithObject:self forKeyPathAndValues:keyPathValues ignoreKeys:nil complete:^(BOOL isSuccess) {
        result = isSuccess;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}

- (BOOL)updateForKeyPathAndValues:(NSArray *)keyPathValues ignoreKeys:(NSArray * const)ignoreKeys{
    __block BOOL result;
    [[_Database sharedInstance] updateWithObject:self forKeyPathAndValues:keyPathValues ignoreKeys:ignoreKeys complete:^(BOOL isSuccess) {
        result = isSuccess;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}

- (void)updateAsyncForKeyPathAndValues:(NSArray *)keyPathValues complete:(DatabaseSuccessBlock)complete{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        BOOL flag = [self updateForKeyPathAndValues:keyPathValues];
        bg_completeBlock(flag);
    });
}

+ (BOOL)deleteWhere:(NSArray *)where {
    __block BOOL result;
    [[_Database sharedInstance] deleteWithClass:[self class] where:where complete:^(BOOL isSuccess) {
        result = isSuccess;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}

+ (void)deleteAsync:(NSArray* _Nonnull)where complete:(DatabaseSuccessBlock)complete{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        BOOL flag = [self deleteWhere:where];
        bg_completeBlock(flag);
    });
}

+ (BOOL)deleteFormatSqlConditions:(NSString *)format,... NS_FORMAT_FUNCTION(1,2) {
    va_list ap;
    va_start (ap, format);
    NSString *conditions = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end (ap);
    NSString* tableName = NSStringFromClass([self class]);
    __block BOOL result;
    [[_Database sharedInstance] deleteWithTableName:tableName conditions:conditions complete:^(BOOL isSuccess) {
        result = isSuccess;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}

+ (BOOL)deleteForKeyPathAndValues:(NSArray * _Nonnull)keyPathValues {
    __block BOOL result;
    [[_Database sharedInstance] deleteWithTableName:NSStringFromClass([self class]) forKeyPathAndValues:keyPathValues complete:^(BOOL isSuccess) {
        result = isSuccess;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}

+ (void)deleteAsyncForKeyPathAndValues:(NSArray *)keyPathValues complete:(DatabaseSuccessBlock)complete{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        BOOL flag = [self deleteForKeyPathAndValues:keyPathValues];
        bg_completeBlock(flag);
    });
}

+ (BOOL)deleteRow:(NSInteger)row {
    return [self deleteFormatSqlConditions:@"where %@ in(select %@ from %@  limit %@,1)",bg_sqlKey(stringify(id)),bg_sqlKey(stringify(id)),NSStringFromClass([self class]),@(row)];
}

+(BOOL)deleteFirstObject{
    return [self deleteFormatSqlConditions:@"where %@ in(select %@ from %@  limit 0,1)",bg_sqlKey(stringify(id)),bg_sqlKey(stringify(id)),NSStringFromClass([self class])];
}

+ (BOOL)deleteLastObject {
    return [self deleteFormatSqlConditions:@"where %@ in(select %@ from %@ order by %@ desc limit 0,1)",bg_sqlKey(stringify(id)),bg_sqlKey(stringify(id)),NSStringFromClass([self class]),bg_sqlKey(stringify(id))];
}

+ (BOOL)clear {
    __block BOOL result;
    [[_Database sharedInstance] clearWithClass:[self class] complete:^(BOOL isSuccess){
        result = isSuccess;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}

+ (void)clear:(DatabaseSuccessBlock)complete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        BOOL flag = [self clear];
        bg_completeBlock(flag);
    });
}

+ (BOOL)drop {
    __block BOOL result;
    [[_Database sharedInstance] dropWithClass:[self class] complete:^(BOOL isSuccess) {
        result = isSuccess;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}

+ (void)drop:(DatabaseSuccessBlock)complete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        BOOL flag = [self drop];
        bg_completeBlock(flag);
    });
}

+ (NSInteger)countWhere:(NSArray *)where {
    NSUInteger count = [[_Database sharedInstance] countForTable:NSStringFromClass([self class]) where:where];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return count;
}

+ (NSInteger)countFormatSqlConditions:(NSString*)format,... NS_FORMAT_FUNCTION(1,2){
    va_list ap;
    va_start (ap, format);
    NSString *conditions = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end (ap);
    NSInteger count = [[_Database sharedInstance] countForTable:NSStringFromClass([self class]) conditions:conditions];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return count;
}

+ (NSInteger)countForKeyPathAndValues:(NSArray* _Nonnull)keyPathValues{
    NSInteger count = [[_Database sharedInstance] countForTable:NSStringFromClass([self class]) forKeyPathAndValues:keyPathValues];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return count;
}

+ (NSInteger)sqliteMethodWithType:(bg_sqliteMethodType)methodType key:(NSString *)key where:(NSString *)where,...{
    va_list ap;
    va_start (ap,where);
    NSString *conditions = where?[[NSString alloc] initWithFormat:where arguments:ap]:nil;
    va_end (ap);
    NSInteger num = [[_Database sharedInstance] sqliteMethodForTable:NSStringFromClass([self class]) type:methodType key:key where:conditions];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return num;
}

+ (NSInteger)version {
    return [_DBTool getIntegerWithKey:NSStringFromClass([self class])];
}

+ (DatabaseDealState)updateVersion:(NSInteger)version{
    NSString* tableName = NSStringFromClass([self class]);
    NSInteger oldVersion = [_DBTool getIntegerWithKey:tableName];
    if(version > oldVersion){
        [_DBTool setIntegerWithKey:tableName value:version];
        __block DatabaseDealState state;
        [[_Database sharedInstance] refreshTable:tableName keys:[_DBTool getClassIvarList:[self class] onlyKey:NO] complete:^(DatabaseDealState result) {
            state = result;
        }];
        //关闭数据库
        [[_Database sharedInstance] closeDB];
        return state;
    }else{
        return  DatabaseDealStateError;
    }
}

+ (void)updateVersionAsync:(NSInteger)version complete:(DatabaseDealStateBlock)complete{
        NSString* tableName = NSStringFromClass([self class]);
        NSInteger oldVersion = [_DBTool getIntegerWithKey:tableName];
        if(version > oldVersion){
            [_DBTool setIntegerWithKey:tableName value:version];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                DatabaseDealState state = [self updateVersion:version];
                bg_completeBlock(state);
                });
        }else{
            bg_completeBlock(DatabaseDealStateError);;
        }
}

+ (DatabaseDealState)updateVersion:(NSInteger)version keyDict:(NSDictionary* const _Nonnull)keydict{
    NSString* tableName = NSStringFromClass([self class]);
    NSInteger oldVersion = [_DBTool getIntegerWithKey:tableName];
    if(version > oldVersion){
        [_DBTool setIntegerWithKey:tableName value:version];
        __block DatabaseDealState state;
        [[_Database sharedInstance] refreshTable:tableName keyDict:keydict complete:^(DatabaseDealState result) {
            state = result;
        }];
        //关闭数据库
        [[_Database sharedInstance] closeDB];
        return state;
    }else{
        return DatabaseDealStateError;
    }

}

+ (void)updateVersionAsync:(NSInteger)version keyDict:(NSDictionary* const _Nonnull)keydict complete:(DatabaseDealStateBlock)complete{
    NSString* tableName = NSStringFromClass([self class]);
    NSInteger oldVersion = [_DBTool getIntegerWithKey:tableName];
    if(version > oldVersion){
        [_DBTool setIntegerWithKey:tableName value:version];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            DatabaseDealState state = [self updateVersion:version keyDict:keydict];
            bg_completeBlock(state);
        });
    }else{
        bg_completeBlock(DatabaseDealStateError);;
    }
}

+ (DatabaseDealState)copyToClass:(__unsafe_unretained _Nonnull Class)destCla keyDict:(NSDictionary* const _Nonnull)keydict append:(BOOL)append{
    __block DatabaseDealState state;
    [[_Database sharedInstance] copyClass:[self class] to:destCla keyDict:keydict append:append complete:^(DatabaseDealState result) {
        state = result;
    }];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return state;
}

+ (void)copyAsyncToClass:(__unsafe_unretained Class)destCla keyDict:(NSDictionary * const)keydict append:(BOOL)append complete:(DatabaseDealStateBlock)complete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        DatabaseDealState state = [self copyToClass:destCla keyDict:keydict append:append];
        bg_completeBlock(state);
    });
}

id _executeSql(NSString* _Nonnull sql,NSString* _Nullable className) {
    id result = [[_Database sharedInstance] bg_executeSql:sql className:className];
    //关闭数据库
    [[_Database sharedInstance] closeDB];
    return result;
}

#pragma mark 下面附加字典转模型API,简单好用,在只需要字典转模型功能的情况下,可以不必要再引入MJExtension那么多文件,造成代码冗余,缩减安装包.
/**
 字典转模型.
 @keyValues 字典(NSDictionary)或json格式字符.
 说明:如果模型中有数组且存放的是自定义的类(NSString等系统自带的类型就不必要了),那就实现objectClassInArray这个函数返回一个字典,key是数组名称,value是自定的类Class,用法跟MJExtension一样.
 */
+ (id)objectWithKeyValues:(id)keyValues {
    return [_DBTool bg_objectWithClass:[self class] value:keyValues];
}

+ (id)objectWithDictionary:(NSDictionary *)dictionary {
    return [_DBTool bg_objectWithClass:[self class] value:dictionary];
}
/**
 直接传数组批量处理;
 注:array中的元素是字典,否则出错.
 */
+ (NSArray *)objectArrayWithKeyValuesArray:(NSArray* const _Nonnull)array {
    NSMutableArray* results = [NSMutableArray array];
    for (id value in array) {
        id obj = [_DBTool bg_objectWithClass:[self class] value:value];
        [results addObject:obj];
    }
    return results;
}

/**
 模型转字典.
 @ignoredKeys 忽略掉模型中的哪些key(即模型变量)不要转,nil时全部转成字典.
 */
- (NSMutableDictionary *)keyValuesIgnoredKeys:(NSArray *)ignoredKeys {
    return [_DBTool bg_keyValuesWithObject:self ignoredKeys:ignoredKeys];
}

@end

