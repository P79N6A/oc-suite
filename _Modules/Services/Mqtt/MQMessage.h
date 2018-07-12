//
//  MQMessage.h
// fallen.ink
//
//  Created by qingqing on 15/12/28.
//
//

#import <Foundation/Foundation.h>

#define kCommandName                        @"t"
#define kCommandMQMessageBoardcastAction_s  @"com.open.student.MQMessage"
#define kCommandMQMessageBoardcastAction_t  @"com.open.teacher.MQMessage"
#define kMessageName                        @"message"

#define kMessageKeyNumber                   @"n"
#define kMessageKeyRequestID                @"q"
#define kMessageKeyMessageID                @"message_id"
#define kMessageKeyMessageBody              @"c"

#define kMessageTitle                       @"tt"
#define kMessageContent                     @"tv"

/**
 *  Mqtt通知消息
 */
#define kMQttNotifKeyTitle                       @"tt"
#define kMQttNotifKeyContent                     @"tv"
#define kMQttNotifKeyNumber                      @"n"
#define kMQttNotifKeyRequestId                   @"q"
#define kMQttNotifKeyRequestExpireAt             @"ea"
#define kMQttNotifKeyUserId                      @"u"
#define kMQttNotifKeyOrderIdKey                  @"o"
#define kMQttNotifKeyOrderCourseIdKey            @"oc"
#define kMQttNotifKeyTeacherIdKey                @"tid"
#define kMQttNotifKeyStudentIdKey                @"sid"
#define kMQttNotifKeyJournalIdKey                @"j"
#define kMQttNotifKeyDateKey                     @"date"

/**
 *  Mqtt聊天消息
 */

#define kMessageKeyID                           @"id"
#define kMessageKeySenderID                     @"s"
#define kMessageKeySendType                     @"st"
#define kMessageKeyReceiveID                    @"r"
#define kMessageKeyReceiveType                  @"rt"
#define kMessageKeyContent                      @"c"
#define kMessageKeyContentType                  @"ct"
#define kMessageKeyTeacherID                    @"te"
#define kMessageKeyPhoneTime                    @"pt" // Not necessary
#define kMessageKeyCreateTime                   @"i"
#define kNotificationContentKeyForAwardActivity     @"v"

/**
 *  最新整理：16.1.12
 */

#define kMessageOrderId                         @"o"            // 订单id
#define kMessageOrderCourseId                   @"oc"           // 课程id
#define kMessageRequestId                       @"q"            // 智能匹配请求id
#define kMessageStudentId_del                   @"u"            // 智能匹配中使用，后续废弃
#define kMessageTeacherId                       @"tid"          // 老师id
#define kMessageStudentId                       @"stid"         // 学生id

#define kMessageCacheTypes                      @"cache_types"  // 用于缓存更新
#define kMessageCacheTypeOption                 @"options"      // ???
#define kMessageCacheTypeBaseinfo               @"base_info"    // ???
#define kMessageCacheTypeContactList            @"contact_list" // ???

@interface MQMessage : NSObject

@property (nonatomic, assign) int64_t   ID;
@property (nonatomic, assign) int       type;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;

@property (nonatomic, strong) NSString *qqingOrderId;
@property (nonatomic, strong) NSString *qqingOrderCourseId;

@property (nonatomic, strong) NSNumber *requestId;
@property (nonatomic, strong) NSNumber *requestExpireAt;

@property (nonatomic, strong) NSString *awardContent;

@property (nonatomic, strong) NSString *qqingStudentId; // tid
@property (nonatomic, strong) NSString *qqingTeacherId; // sid

@property (nonatomic, strong) NSString *journalId;      // journalId
@property (nonatomic, strong) NSNumber *dateInterval;   // date

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (instancetype)initWithJsonString:(NSString *)jsonString;

@end

