//
//  MQMessage.m
// fallen.ink
//
//  Created by qingqing on 15/12/28.
//
//

#import "MQMessage.h"

@interface MQMessage ()

@property (nonatomic, strong) NSDictionary *payloadDict;

@end

@implementation MQMessage

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.payloadDict    = dictionary;
        
        [self parse];
    }
    
    return self;
}

- (instancetype)initWithJsonString:(NSString *)jsonString {
    if (self = [super init]) {
        NSError *error;
        NSData *data        = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        self.payloadDict    = [NSJSONSerialization JSONObjectWithData:data
                                                              options:kNilOptions
                                                                error:&error];
        
        // todo-li handle error
        [self parse];
    }
    
    return self;
}

- (void)parse {
    if (!self.payloadDict) return;
    
    self.ID         = [[self.payloadDict objectForKey:kMessageKeyMessageID] longLongValue];
    self.type       = [[self.payloadDict objectForKey:kCommandName] intValue];
    self.title      = [self.payloadDict objectForKey:kMessageTitle];
    
    self.content    = [self.payloadDict objectForKey:kMessageContent];
    self.qqingOrderCourseId = [self.payloadDict objectForKey:kMQttNotifKeyOrderCourseIdKey];
    self.qqingOrderId   = [self.payloadDict objectForKey:kMQttNotifKeyOrderIdKey];
    self.requestId  = [self.payloadDict objectForKey:kMQttNotifKeyRequestId];
    self.requestExpireAt    = [self.payloadDict objectForKey:kMQttNotifKeyRequestExpireAt];
    self.awardContent   = [self.payloadDict objectForKey:kNotificationContentKeyForAwardActivity];
    
    self.qqingStudentId     = [self.payloadDict objectForKey:kMessageStudentId];
    self.qqingTeacherId     = [self.payloadDict objectForKey:kMessageTeacherId];
    
    self.journalId          = [self.payloadDict objectForKey:kMQttNotifKeyJournalIdKey];
    self.dateInterval       = [self.payloadDict objectForKey:kMQttNotifKeyDateKey];
    
    __unused NSString *typeString   = [NSString stringWithFormat:@"(type:%d,o:%@,oc:%@)", self.type, self.qqingOrderId, self.qqingOrderCourseId];
    /**
     *  便于调试跟踪，对content追加类型号码
     */
//    debug_code(
//              if (self.content) self.content    = [[[NSMutableString alloc] initWithString:self.content] append:typeString];
//    )
}

@end
