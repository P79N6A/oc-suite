//
//  LogRequestDataBuilder.m
// fallen.ink
//
//  Created by qingqing on 15/12/24.
//
//

#import "_greats.h"
#import "_building_tools.h"
#import "LogRequestDataBuilder.h"

@interface LogRequestDataBuilder ()

@property (nonatomic, strong) NSMutableDictionary *data;

@end

@implementation LogRequestDataBuilder

- (instancetype)init {
    if (self = [super init]) {
        self.data   = [@{} mutableCopy];
    }
    
    return self;
}

#pragma mark - Keys

@def_nsstring( Session, @"sessionId" )
@def_nsstring( QingQingUserId, @"QingQingUserId" )
@def_nsstring( UserId, @"userId" )
@def_nsstring( DeviceSystemVersion, @"Device_System_Version" )
@def_nsstring( DeviceModel, @"Device_Model" )
@def_nsstring( ApplicationVersion, @"AppVersion" )
@def_nsstring( ApplicationClientType, @"AppClientType" )
@def_nsstring( ApplicationFeedbackType, @"AppFeedBackType" )
@def_nsstring( ApplicationPlatform, @"appplatform" )
@def_nsstring( ApplicationName, @"appname" )
@def_nsstring( UserExplain, @"explain" )
@def_nsstring( UserQuestion, @"question" )

+ (NSString *)ApplicationNameAdapted {
#ifdef app_name
    NSString *appname = app_name;
#else
    NSString *appname = @"your application name";
#endif
    
    return appname;
}

#pragma mark - Param packer

- (void)setFeedbackType:(int32_t)type {
//    NSAssert(type, nil);
    
    [self.data setObject:@(type) forKey:self.ApplicationFeedbackType];
}

- (void)setQuestions:(NSString *)questions {
    NSAssert(questions, nil);
    
    [self.data setObject:questions forKey:self.UserQuestion];
}

- (void)setExplain:(NSString *)explain {
    NSAssert(explain, nil);
    
    [self.data setObject:explain forKey:self.UserExplain];
}

- (NSDictionary *)generate {
    NSString *appVersion    = [greats.device appVersion];
#ifdef DEBUG
    appVersion = [appVersion stringByAppendingString:@"_test"];
#endif
    
    [self.data setObject:[greats.device osVersion] forKey:self.DeviceSystemVersion];
    [self.data setObject:[greats.device deviceModel] forKey:self.DeviceModel];
    [self.data setObject:appVersion forKey:self.ApplicationVersion];
    [self.data setObject:[greats.device bundleIdentifier] forKey:self.ApplicationClientType];
    [self.data setObject:@"IOS" forKey:self.ApplicationPlatform];
    [self.data setObject:[LogRequestDataBuilder ApplicationNameAdapted] forKey:self.ApplicationName];
    
    return self.data;
}

@end
