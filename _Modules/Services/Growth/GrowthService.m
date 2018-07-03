//
//  GrowthService.m
//  consumer
//
//  Created by fallen on 16/11/23.
//
//

#import "GrowthService.h"
#import "GrowthServer.h"
#import "GrowthCache.h"
#import "GrowthIntercepter.h"

/**
 *  语义说明：
 
 *  1. 在（某个View）点击时（触发）一个Bool数据点
 *  2. 在（某个chance）发生时（触发）一个HashMap数据点
 
 */

@interface GrowthService ()
@prop_instance(GrowthIntercepter, intercepter)
@prop_instance(GrowthServer, server)
@prop_instance(GrowthCache, cache)
@end

@implementation GrowthService
@def_prop_instance(GrowthIntercepter, intercepter)
@def_prop_instance(GrowthServer, server)
@def_prop_instance(GrowthCache, cache)

@def_singleton( GrowthService )

+ (void)load {
    [[[self sharedInstance] intercepter] initViewIntercepter];
}

- (void)startWith:(NSString *)what {
    
}

- (void)viewAppearAtIdentifier:(NSString *)identifier {
    Growth *obj = [Growth new];
    obj.id = ((int)self.cache.allObjectsCount + 1);
    obj.viewid = (int)[identifier integerValue];
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [date timeIntervalSince1970] * 1000;
    obj.time = a;
    [self.cache addObject:obj];
    if (self.cache.allObjectsCount == 1000) {
        NSMutableString *recordStr = [[NSMutableString alloc] init];
        for (Growth *aObj in self.cache.allObjects) {
            NSString *currentStr = [NSString stringWithFormat:@"%d;%ld;%d;0;0:", aObj.id, (long)aObj.time, aObj.viewid];
            [recordStr append:currentStr];
        }
        NSDate *currentDate = [NSDate date];//获取当前时间，日期
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYYMMddhhmmssSS"];
        NSString *dateString = [dateFormatter stringFromDate:currentDate];
#ifdef datapayload
        NSString * recodeStr = [NSString stringWithFormat:@"%@;%@:%@", dateString, datapayload.token, recordStr];
#else
        NSString * recodeStr = [NSString stringWithFormat:@"%@;%@:%@", dateString, @"", recordStr];
#endif
        
        [self writeConfigFile:recodeStr documentName:dateString];
        NSData * recodeData = [self readConfigFile:dateString];
        
#if 0
        [self.server uploadDocumentWithmyRequestData:recodeData documentName:dateString successBlock:^{
            [self.cache removeAllObject];
        }];
#endif
    }
}

- (void)writeConfigFile:(NSString *)recodeStr documentName:(NSString *)documentName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) ; //得到documents的路径，为当前应用程序独享
    NSString *documentD = [paths objectAtIndex:0];
    NSString *configFile = [documentD stringByAppendingPathComponent:documentName];
    NSError *error;
    [recodeStr writeToFile:configFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        LOG(@"存储失败")
    }
}

- (NSData *)readConfigFile:(NSString *)documentName {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* thepath = [paths lastObject];
    thepath = [thepath stringByAppendingPathComponent:documentName];
    NSData *data = [NSData dataWithContentsOfFile:thepath];
    return data;
}
@end
