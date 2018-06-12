//
//  PBKeyValueDB.h
//  PBKeyValueDB
//
//  Created by Bennett on 2016/12/7.
//  Copyright © 2016年 PB-Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 PBKeyValueDB operation's callback block

 @param success means success or not
 @param object the operation return value,can be NSString ,NSDictionary ,NSArray
 @param error if not nil means that occour a error
 */
typedef void(^PBKeyValueDBResult)(BOOL success ,id object ,NSError *error);



/**
 PBKeyValueDB defaut database file stored in ~/Documents/PBKeyValueDB/default.db下
 */
@interface PBKeyValueDB : NSObject

+ (instancetype)shareInstance;

/**
 close up the database
 */
- (void)close ;

#pragma mark - add & modify

/**
 create a table in the database file

 @param result completion will callback. success:'YES' means successful ,'NO' means the operation failure;object: will always be nil; error:if operation successful will be nil
 
 @param table table name ,if the value is nil will be operation in defalt table
 */
- (void)createTable:(PBKeyValueDBResult)result name:(NSString *)table ;


/**
 set mutable values to table by NSDictionary

 @param result result completion will callback. success:'YES' means successful ,'NO' means the operation failure;object: will always be nil; error:if operation successful will be nil
 @param values the value will be set
 @param table table name ,if the value is nil will be operation in defalt table
 */
- (void)setValues:(PBKeyValueDBResult)result values:(NSDictionary*)values table:(NSString*)table ;


/**
 set a value to table by key

 @param result result completion will callback. success:'YES' means successful ,'NO' means the operation failure;object: will always be nil; error:if operation successful will be nil
 @param value the value will be set
 @param key the key ,can not be nil
 @param table table name ,if the value is nil will be operation in defalt table
 */
- (void)setValue:(PBKeyValueDBResult)result value:(NSString *)value key:(NSString *)key table:(NSString *)table ;


#pragma mark - delete


/**
 remove a value in table by key

 @param result result completion will callback. success:'YES' means successful ,'NO' means the operation failure;object: will always be nil; error:if operation successful will be nil
 @param key the key ,can not be nil
 @param table table name ,if the value is nil will be operation in defalt table
 */
- (void)remove:(PBKeyValueDBResult)result key:(NSString*)key table:(NSString*)table ;


/**
 remove values in table by mutiltable keys

 @param result result result completion will callback. success:'YES' means successful ,'NO' means the operation failure;object: will always be nil; error:if operation successful will be nil
 @param keys the keys, can not be nil
 @param table table name ,if the value is nil will be operation in defalt table
 */
- (void)removeBatch:(PBKeyValueDBResult)result key:(NSArray*)keys table:(NSString*)table ;


/**
 remove all values in table

 @param result result result completion will callback. success:'YES' means successful ,'NO' means the operation failure;object: will always be nil; error:if operation successful will be nil
 @param table table table name ,if the value is nil will be operation in defalt table
 */
- (void)removeAll:(PBKeyValueDBResult)result table:(NSString*)table ;

#pragma mark - find


/**
 find a value in table by key

 @param result result result completion will callback. success:'YES' means successful ,'NO' means the operation failure;object is a NSString object; error:if operation successful will be nil
 @param key the key ,can not be nil
 @param table table name ,if the value is nil will be operation in defalt table
 */
- (void)value:(PBKeyValueDBResult)result key:(NSString*)key table:(NSString*)table ;


/**
 find values in table by keys

 @param result result result result completion will callback. success:'YES' means successful ,'NO' means the operation failure;object is a NSArray object; error:if operation successful will be nil
 @param keys keys ,can not be nil
 @param table table name ,if the value is nil will be operation in defalt table
 */
- (void)values:(PBKeyValueDBResult)result keys:(NSArray *)keys table:(NSString *)table ;


/**
 find value in table by value match args string

 @param result result result result completion will callback. success:'YES' means successful ,'NO' means the operation failure;object is a NSArray object; error:if operation successful will be nil
 @param table table name ,if the value is nil will be operation in defalt table
 @param args can not be nil
 
 example:
 in defalut table '_table_' have value is
 key            |           value
 .
 .
 .
 101            |{code:0,msg:,data:{userId:0,uname:tom,gender:1,isOldMember:true}}
 102            |{code:0,msg:,data:{userId:1,uname:bennett,gender:1,isOldMember:true}}
 103            |{code:0,msg:,data:{userId:2,uname:johny,gender:1,isOldMember:true}}
 104            |{code:0,msg:,data:{userId:2,uname:rose,gender:0,isOldMember:false}}
 
 you can use the method find out the uname is bennett records
 
 [[PBKeyValueDB shareInstance] values:^(BOOL success, id object, NSError *error) {
    //the object will be a NSArray like this
    //[{code:0,msg:,data:{userId:1,uname:bennett,gender:1,isOldMember:true}}]
    //
 } table:nil valueMatch:@{@"uname" : @"bennett"}];
 
 */
- (void)values:(PBKeyValueDBResult)result table:(NSString*)table valueMatch:(NSDictionary*)args ;


@end
