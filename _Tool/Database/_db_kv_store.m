//
//  PBKeyValueDB.m
//  PBKeyValueDB
//
//  Created by Bennett on 2016/12/7.
//  Copyright © 2016年 PB-Tech. All rights reserved.
//

#import "FMDB.h"
#import "_db_kv_store.h"
#import <sqlite3.h>

#define DEFAULT_TABLE   @"_table_"
#define DATABASE_FILE   @"pb_kv.db"

#define CREATE_TABLE    @"CREATE TABLE IF NOT EXISTS %@ (Key TEXT NOT NULL ,Value TEXT,PRIMARY KEY(Key));"
#define FIND_ONE_VALUE  @"SELECT Value FROM %@ WHERE Key = '%@' LIMIT 1;"
#define FIND_All        @"SELECT Key,Value FROM %@;"
#define SET_VALUE       @"REPLACE INTO %@ (Key ,Value) VALUES ('%@' ,'%@');"
#define DELETE_VALUE    @"DELETE FROM %@ WHERE Key = '%@';"
#define DELETE_ALL      @"DELETE FROM %@"


static inline NSString *safeTable(NSString *name) {
    return name.length ? name : DEFAULT_TABLE;
}


/**
 SELECT Value FROM TABLE %@ WHERE in (? ,? ,?);

 @param table table name
 @param keys keys
 @return sql query
 */
static inline NSString *FIND_ALL_SQL(NSString * table ,NSArray *keys) {
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT Value FROM %@ WHERE Key in " ,table];
    [sql appendString:@"( "];
    [keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [sql appendString:@"?"];
        if (idx < keys.count) {
            [sql appendString:@" ,"];
        }
    }];
    [sql appendString:@" );"];
    return sql;
}

static inline NSString *FIND_ALL_VALUE_MULTI_MATCH_SQL(NSString *table ,NSDictionary *args) {
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT Value FROM %@ WHERE "
                            ,table];
    NSInteger count = args.count;
    NSArray *keys = [args allKeys];
    [keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       [sql appendFormat:@" Value LIKE '%%%@:%@%%' " ,obj ,args[obj]];
        if (idx < count - 1) {
            [sql appendString:@" AND "];
        }
    }];
    [sql appendString:@";"];
    NSLog(@"%s--->%@" ,__func__ ,sql);
    return sql;
}

@interface PBKeyValueDB ()

@property (nonatomic,strong) FMDatabaseQueue *dbQueue;

@end

@implementation PBKeyValueDB

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static PBKeyValueDB *keyValueDB;
    dispatch_once(&onceToken, ^{
        keyValueDB = [[PBKeyValueDB alloc] init];
    });
    return keyValueDB;
}

- (NSString*)dbPath {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    path = [path stringByAppendingPathComponent:NSStringFromClass([self class])];
    BOOL isDirectory = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSLog(@"%s--->%@" ,__func__ ,path);
    return path;
}

- (void)optimizeStatement {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeStatements:@"\
         PRAGMA auto_vacuum=FULL;\
         PRAGMA SQLITE_THREADSAFE=2;\
         PRAGMA mmap_size=268435456;\
         "];
    
        void (^debugSwitch)(BOOL enable) = ^(BOOL enable) {
            db.traceExecution = enable;
            db.crashOnErrors = enable;
            db.logsErrors = enable;
        };
        
#if DEBUG
        debugSwitch(NO);
#else
        debugSwitch(NO);
#endif
    }];
}

- (instancetype)init {
    if (self = [super init]) {
        sqlite3_config(SQLITE_CONFIG_MEMSTATUS, 0);
        NSString *fullPath = [[self dbPath] stringByAppendingPathComponent:DATABASE_FILE];
        _dbQueue = [[FMDatabaseQueue alloc] initWithPath:fullPath];
        [self optimizeStatement];
        [self createTable:^(BOOL success, id object, NSError *error) {
            if (!success) NSLog(@"%@" ,error);
        } name:DEFAULT_TABLE];
    }
    return self;
}

#pragma mark - add & modify
- (void)createTable:(PBKeyValueDBResult)result name:(NSString *)table {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:CREATE_TABLE ,safeTable(table)];
        BOOL success = [db executeUpdate:sql];
        if (result) result(success ,nil ,success ? nil : db.lastError);
    }];
}

- (void)setValues:(PBKeyValueDBResult)result values:(NSDictionary*)values table:(NSString*)table {
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        __block BOOL success = YES ; __block NSError *err;
        [values enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *sql = [NSString stringWithFormat:SET_VALUE ,safeTable(table) ,key ,obj];
            BOOL sccess = [db executeUpdate:sql];
            if (!sccess) {
                success = NO;
                err = db.lastError;
                *rollback = YES;
                *stop = YES;
            }
        }];
        if (result) result(success ,nil ,err);
    }];
}

- (void)setValue:(PBKeyValueDBResult)result value:(NSString *)value key:(NSString *)key table:(NSString *)table {
    if (!key.length || !value.length ) return;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:SET_VALUE ,safeTable(table) ,key ,value];
        BOOL success = [db executeUpdate:sql];
        if (result) result(success ,nil ,success ? nil : db.lastError);
    }];
}


#pragma mark - delete

- (void)remove:(PBKeyValueDBResult)result key:(NSString*)key table:(NSString*)table {
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:DELETE_VALUE ,safeTable(table) ,key];
        BOOL success = [db executeUpdate:sql];
        if (result) result(success ,nil ,success ? nil : db.lastError);
    }];
}

- (void)removeBatch:(PBKeyValueDBResult)result key:(NSArray*)keys table:(NSString*)table {
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        __block BOOL success = YES ; __block NSError *err;
       [keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           NSString *sql = [NSString stringWithFormat:DELETE_VALUE ,safeTable(table) ,obj];
           BOOL success = [db executeUpdate:sql];
           if (!success) {
               success = NO;
               err = db.lastError;
               *rollback = YES;
               *stop = YES;
           }
       }];
        if (result) result(success ,nil ,err);
    }];
}
- (void)removeAll:(PBKeyValueDBResult)result table:(NSString*)table {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:DELETE_ALL ,safeTable(table)];
        BOOL success = [db executeUpdate:sql];
        if (result) result(success ,nil ,success ? nil : db.lastError);
    }];
}

#pragma mark - find
- (void)value:(PBKeyValueDBResult)result key:(NSString*)key table:(NSString*)table {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:FIND_ONE_VALUE ,safeTable(table) ,key];
        FMResultSet *res = [db executeQuery:sql];
        NSString *value = [res next] ? [res stringForColumnIndex:0] : nil;
        if (result) result(res ? YES : NO ,value ,nil);
        [res close];
    }];
}

- (void)values:(PBKeyValueDBResult)result keys:(NSArray *)keys table:(NSString *)table {
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *set = [db executeQuery:FIND_ALL_SQL(safeTable(table), keys) withArgumentsInArray:keys];
        NSMutableArray *array = [NSMutableArray array];
        while (set.next) {
            NSString *value = [set stringForColumnIndex:0];
            [array addObject:value ?: @""];
        }
        [set close];
        if (result) result(set ? YES : NO ,array ,set ? nil : db.lastError);
    }];
}


- (void)values:(PBKeyValueDBResult)result table:(NSString*)table valueMatch:(NSDictionary*)args {
    if (args.count) {
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            FMResultSet *res = [db executeQuery:FIND_ALL_VALUE_MULTI_MATCH_SQL(safeTable(table) ,args)];
            NSString *value = [res next] ? [res stringForColumnIndex:0] : nil;
            if (result) result(res ? YES : NO ,value ,nil);
            [res close];
        }];
    } else {
        if (result) result(NO ,nil ,nil);
    }
}


- (void)close {
    [_dbQueue close];
    _dbQueue = nil;
}

- (void)dealloc {
    [self close];
}

@end
