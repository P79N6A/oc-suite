//
//  MQCache.m
// fallen.ink
//
//  Created by qingqing on 15/12/28.
//
//

#import "MQCache.h"

@implementation MQCache

@def_singleton( MQCache )

#pragma mark -

- (NSString*)getPath {
    NSString *path = NSHomeDirectory();
    path = [path stringByAppendingPathComponent:@"Documents/mqtt_message.db"];
    return path;
}

- (void)createMqttMessageTable {
    //拿到数据库文件的路径
//    NSString *path = [self getPath];
//    //拿到数据库对象，打开数据库，如果这个数据库不存在，就会自动创建
//    FMDatabase *db =[FMDatabase databaseWithPath:path];
//    BOOL res = [db open];
//    if (res == YES) {
//        res = [db executeUpdate:@"create table if not exists mqttMessage(message_id INTEGER PRIMARY KEY,userID INTEGER,messageTime INTEGER,messageType INTEGER,messageBody text)"];//执行sql语句
//        if (res == NO) {
//            LOG(@"创建失败");
//            [db close]; //关闭数据库
//        } else if(res == YES) {
//            LOG(@"创建成功");
//            
//            [db close];
//        }
//    }
}

- (void)handleExpiredMqttMessage {
    //根据服务器返回的时间，设置mqtt消息的超时时间，小于该时间都是超时的消息，需要清除掉,时间单位秒
//    long long overdueDate = [[TimeService sharedInstance] getServerTime]/1000 - 3*60;
//    //拿到数据库文件的路径
//    NSString *path = [self getPath];
//    FMDatabase *db =[FMDatabase databaseWithPath:path];
//    BOOL res = [db open];
//    if (res == YES) {
//        [db beginTransaction];
//        [db executeUpdate:@"DELETE FROM mqttMessage where messageTime < ?",[NSNumber numberWithLongLong:overdueDate]];//执行sql语句
//        [db commit];
//    }
//    [db close]; //关闭数据库
}

- (void)updateMqttmessageWithMessageID:(long long)messageID
                       withMessageTime:(long long)messageTime {
    //拿到数据库文件的路径
//    NSString *path = [self getPath];
//    FMDatabase *db =[FMDatabase databaseWithPath:path];
//    BOOL res = [db open];
//    if (res == YES) {
//        [db beginTransaction];
//        [db executeUpdate:@"update mqttMessage set messageTime = ? where message_id = ?",[NSNumber numberWithLongLong:messageTime],[NSNumber numberWithLongLong:messageID]];//执行sql语句
//        [db commit];
//    }
//    [db close]; //关闭数据库
    
}

- (void)deleteMessageFromMqttMessageWithMessageID:(long long)messageID {
    //拿到数据库文件的路径
//    NSString *path = [self getPath];
//    FMDatabase *db =[FMDatabase databaseWithPath:path];
//    BOOL res = [db open];
//    if (res == YES) {
//        [db beginTransaction];
//        [db executeUpdate:@"DELETE FROM mqttMessage where message_id = ?",[NSNumber numberWithLongLong:messageID]];//执行sql语句
//        [db commit];
//    }
//    [db close]; //关闭数据库
}

- (void)insertLocalMqttMessageWithMessageID:(long long)messageID
                            withMessageTime:(long long)messageTime
                            withMessageType:(long long)messageType
                            withMessageBody:(NSString *)messageBody {
    //拿到数据库文件的路径
//    NSString *path = [self getPath];
//    FMDatabase *db =[FMDatabase databaseWithPath:path];
//    BOOL res = [db open];
//    if (res == YES) {
//        
//        
////        [db beginTransaction];
////        [db executeUpdate:@"INSERT INTO mqttMessage(message_id,userID,messageTime,messageType,messageBody) VALUES (?,?,?,?,?)",[NSNumber numberWithLongLong:messageID],[NSNumber numberWithLongLong:[Cache sharedInstance].userID],[NSNumber numberWithLongLong:messageTime],[NSNumber numberWithLongLong:messageType],messageBody];
////        [db commit];
//    }
//    [db close];
}

- (BOOL)mqttMessageExistWithMessageID:(long long)messageID {
    BOOL messageExist = NO;
//    //拿到数据库文件的路径
//    NSString *path = [self getPath];
//    FMDatabase *db =[FMDatabase databaseWithPath:path];
//    BOOL res = [db open];
//    if (res == YES) {
//        FMResultSet *rs = [db executeQuery:@"select * from mqttMessage where message_id = ?",[NSNumber numberWithLongLong:messageID]];
//        while ([rs next]){
//            messageExist = YES;
//        }
//    }
//    [db close];
    return messageExist;
}


@end
