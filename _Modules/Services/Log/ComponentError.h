//
//  ComponentError.h
// fallen.ink
//
//  Created by fallen.ink on 12/21/15.
//
//

#import "_greats.h"

/**
 *  这里定义log type
 
 *  不定义，type对应的字符串
 
 *  定义模块名 用于打印domain reason params
 */

typedef NS_ENUM(NSInteger, StudentAppErrorLogType) {
    AppErrorLogType_None = 0 << 0,
    
    // 学生端
    AppErrorLogType_BuyCourseError = 1 << 0,
    AppErrorLogType_AlipayError = 1 << 1,
    AppErrorLogType_RegesterOrLoginError = 1 << 2,

    // 老师端
    AppErrorLogType_registerOrLoginError = 1 << 0,
    AppErrorLogType_unIdentificaionError = 1 << 1,
    AppErrorLogType_unAcceptOrderError   = 1 << 2,
    AppErrorLogType_unUploadPictureError = 1 << 3,
    AppErrorLogType_classAttendenceError         = 1 << 4,
    AppErrorLogType_unChangeOrContinueClassError = 1 << 5,
    AppErrorLogType_unSubmitFeedBackError        = 1 << 6,
    AppErrorLogType_otherError                   = 1 << 7, // 将废弃
    
    // TA端
    AppErrorLogType_AccountExceptionError           = 1 << 0,
    AppErrorLogType_CannotRobbingOrderError         = 1 << 1,
    AppErrorLogType_SetttingPercentageError         = 1 << 2,
    AppErrorLogType_ChatFunctionError               = 1 << 3,
    AppErrorLogType_RecommendTeacherError           = 1 << 4,
    
    AppErrorLogType_OtherError                      = AppErrorLogType_otherError, // 最后一个相似的美剧即可
};

/**
 *  预定义
 *  上下文名
 
 *  搜索log的时候，可作为关键字
 */
extern const NSString *kContextAccount;             // 账号相关
extern const NSString *kContextRobOrder;            // 订单相关
extern const NSString *kContextChangeOrder;
extern const NSString *kContextRenewOrder;
extern const NSString *kContextNewOrder;
extern const NSString *kContextPercentage;          // 分成
extern const NSString *kContextChat;                // 聊天功能
extern const NSString *kContextRecommendTeacher;    // 推荐老师

@interface ComponentError : NSObject

@singleton( ComponentError )

@end



