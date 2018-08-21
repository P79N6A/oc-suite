//
//  NetHelp.m
//  FLPayManagerDemo
//
//  Created by  杨子民 on 2017/9/15.
//  Copyright © 2017年 gitKong. All rights reserved.
//

#import "NetHelp.h"
#import <CommonCrypto/CommonDigest.h>

#include <sys/socket.h> 
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "NetKReachability.h"

@implementation NetHelp

+ (NSString *) macaddress{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

+ (NSString *) uniqueDeviceIdentifierOld
{
    NSString *macaddress = [NetHelp macaddress];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString *stringToHash = [NSString stringWithFormat:@"%@%@",macaddress,bundleIdentifier];
    NSString *uniqueIdentifier = [NetHelp md5:stringToHash];
    
    if (uniqueIdentifier == nil) {
        uniqueIdentifier = @"0";
    }
    
    return uniqueIdentifier;
}

+ (NSString *) uniqueDeviceIdentifier
{
    NSString *uniqueIdentifier = @"0";
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        uniqueIdentifier = [[UIDevice currentDevice].identifierForVendor UUIDString];
    } else {
        uniqueIdentifier = [self uniqueDeviceIdentifierOld];
    }
    
    return uniqueIdentifier;
}

+ (NSString *)deviceVersion {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

+ (NSString *)currentAppVersion {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    return version;
}

+ (NSString *)currentAppBuildVersion {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDict objectForKey:@"CFBundleVersion"];
    return version;
}

+ (NSString*)netWork
{
    NSString *netStatus = @"unknown";
    switch ([[NetKReachability sharedInstance] status]) {
        case NetKNetworkStatusNotReachable:
        {
            netStatus = @"off";
        }
            break;
        case NetKNetworkStatusCellType2G:
        {
            netStatus = @"2G";
        }
            break;
        case NetKNetworkStatusCellType3G:
        {
            netStatus = @"3G";
        }
            break;
        case NetKNetworkStatusCellType4G:
        {
            netStatus = @"4G";
        }
            break;
        case NetKNetworkStatusReachableViaWiFi:
        {
            netStatus = @"wifi";
        }
            break;
        default:
            break;
    }
    
    return netStatus;
}

NSString*FillNil( NSString* str )
{
    if ( str == nil )
        str = @"'";
    
    return str;
}

//post异步请求封装函数
+ (void)post:(NSString *)URL RequestParams:(NSDictionary *)params FinishBlock:(void (^)(NSData *  data, NSURLResponse *  response, NSError * error)) block
{
    NSURL *url = [NSURL URLWithString:URL];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:60];
    
    NSString *parseParamsResult = [self parseParams:params];
    NSData *postData = [parseParamsResult dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [request addValue:FillNil([NetHelp uniqueDeviceIdentifier]) forHTTPHeaderField:@"x-alisports-device-id"];
    [request addValue:FillNil([NetHelp deviceVersion]) forHTTPHeaderField:@"x-alisports-device-type"];
    [request addValue:@"iOS" forHTTPHeaderField:@"x-alisports-platform"];
    [request addValue:FillNil([NSString stringWithFormat:@"%@", [[UIDevice currentDevice] systemVersion]]) forHTTPHeaderField:@"x-alisports-os-version"];
    [request addValue:FillNil([NetHelp netWork]) forHTTPHeaderField:@"x-alisports-network"];
    [request addValue:FillNil([[NSLocale preferredLanguages] firstObject]) forHTTPHeaderField:@"x-alisports-language"];
    [request addValue:@"0.1.0" forHTTPHeaderField:@"x-alisports-sdk-version"];
    [request addValue:FillNil([[NSBundle mainBundle] bundleIdentifier]) forHTTPHeaderField:@"x-alisports-bundle-id"];
    [request addValue:FillNil([NetHelp currentAppVersion]) forHTTPHeaderField:@"x-alisports-bundle-version"];
    [request addValue:FillNil([NetHelp currentAppBuildVersion]) forHTTPHeaderField:@"x-alisports-bundle-build-version"];
    [request addValue:@"AppStore" forHTTPHeaderField:@"x-alisports-bundle-channel"];
    
    NSLog(@"Pay request = %@", [request description]);
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:block ] resume];
}

/*
 NSString *api = @"http://www.ithtw.com/api.php";
 NSString *sData = @"username=admin&password=admin";
 //同步
 NSString *dataString = [HttpUtil httpAsynchronousRequestUrl:api postStr:sData];
 */
//该方法同步请求服务器,需要在主线程中创建其它线程完成请求,否则会阻塞主线程导致UI卡住
+(NSString*) asynchronousPost:(NSString*) spec postStr:(NSString *)sData stautsCode:(NSInteger*)statusCode
{
    NSURL *url = [NSURL URLWithString:spec];
    NSMutableURLRequest *requst = [NSMutableURLRequest requestWithURL:url];
    [requst setHTTPMethod:@"POST"];
    NSData *postData = [sData dataUsingEncoding:NSUTF8StringEncoding];
    [requst setHTTPBody:postData];
    [requst setTimeoutInterval:60.0];
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = nil;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    //如果使用局部变量指针需要传指针的地址
    NSData *data = [NSURLConnection sendSynchronousRequest:requst returningResponse:&urlResponse error:&error];
#pragma clang diagnostic pop
    
    NSString *returnStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    *statusCode = [urlResponse statusCode];
    
    NSLog(@"code:%ld",[urlResponse statusCode]);
    if ([urlResponse statusCode] == 200) {
        return returnStr;
    }
    return nil;
}

+(NSString*) asynchronousPost:(NSString*) spec param:(NSDictionary *)params stautsCode:(NSInteger*)code
{
     NSString *parseParamsResult = [self parseParams:params];
     return [self asynchronousPost:spec postStr:parseParamsResult stautsCode:code];
}

//把NSDictionary解析成post格式的NSString字符串
+ (NSString *)parseParams:(NSDictionary *)params {
    NSString *keyValueFormat;
    NSMutableString *result = [NSMutableString new];
    
    //实例化一个key枚举器用来存放dictionary的key
    NSEnumerator *keyEnum = [params keyEnumerator];
    id key;
    while (key = [keyEnum nextObject]) {
        keyValueFormat = [NSString stringWithFormat:@"%@=%@&",key,[params valueForKey:key]];
        [result appendString:keyValueFormat];
    }
    
    NSLog(@"Pay request params=%@", result);
    
    return result;
}

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error
{
    NSError __block *err = NULL;
    NSData __block *data;
    BOOL __block reqProcessed = false;
    NSURLResponse __block *resp;
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable _data, NSURLResponse * _Nullable _response, NSError * _Nullable _error) {
        resp = _response;
        err = _error;
        data = _data;
        reqProcessed = true;
    }] resume];
    
    while (!reqProcessed) {
        [NSThread sleepForTimeInterval:0];
    }
    
    *response = resp;
    *error = err;
    return data;
}

+ (NSString *)keyValueSortedStringForDictionary:(NSDictionary *)dictionary
{
    NSArray *keys = [dictionary allKeys];
    NSArray *sortedKyes = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    NSString *string = @"";
    for (NSString *key in sortedKyes) {
        NSString *valueString = nil;
        id value = dictionary[key];
        if ([value isKindOfClass:[NSNumber class]]) {
            valueString = [value stringValue];
        } else {
            valueString = value;
        }
        
        if ([valueString isKindOfClass:[NSString class]] ) {
            string = [string stringByAppendingString:valueString];
        }
    }
    return string;
}

+ (NSDictionary *)signedDictionaryForParameter:(NSDictionary *)parameter key:(NSString*)key keyvalue:(NSString*)keyvalue
{
    NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionaryWithDictionary:parameter];
    [tempDictionary removeObjectForKey:@"platform"];
    
    [tempDictionary setObject:key forKey:@"alisp_app_key"];
    NSString *timestampString = [NSString stringWithFormat:@"%ld",(long)[[NSDate date]timeIntervalSince1970]];
    [tempDictionary setObject:timestampString forKey:@"alisp_time"];
    
    NSString *keyValueString = [self keyValueSortedStringForDictionary:tempDictionary];
    keyValueString = [keyValueString stringByAppendingString:keyvalue];
    
    NSString *signString = [self codeSignStringForOriginalString:keyValueString];
    [tempDictionary setObject:signString forKey:@"alisp_sign"];
    [tempDictionary setObject:@"MOBILE_SDK" forKey:@"platform"];
    
    return tempDictionary;
}

+ (NSDictionary *)signedDictionaryH5ForParameter:(NSDictionary *)parameter key:(NSString*)key keyvalue:(NSString*)keyvalue
{
    NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionaryWithDictionary:parameter];
    [tempDictionary removeObjectForKey:@"platform"];
    
    [tempDictionary setObject:key forKey:@"alisp_app_key"];
    NSString *timestampString = [NSString stringWithFormat:@"%ld",(long)[[NSDate date]timeIntervalSince1970]];
    [tempDictionary setObject:timestampString forKey:@"alisp_time"];
    
    NSString *keyValueString = [self keyValueSortedStringForDictionary:tempDictionary];
    keyValueString = [keyValueString stringByAppendingString:keyvalue];
    
    NSString *signString = [self codeSignStringForOriginalString:keyValueString];
    [tempDictionary setObject:signString forKey:@"alisp_sign"];
    //    [tempDictionary setObject:@"MOBILE_SDK" forKey:@"platform"];
    
    return tempDictionary;
}

+ (NSString *)md5:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",(int)result[i]];
    }
    return [ret copy];
}

+ (NSString *)codeSignStringForOriginalString:(NSString *)originalString
{
    NSString *md5String =  [[self md5:originalString] substringWithRange:NSMakeRange(5, 20)];
    return md5String;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    
    if(err) {
        NSLog(@"JSON解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSString*)encodeString:(NSString*)unencodedString{
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
#pragma clang diagnostic pop
    return encodedString;
}

//URLDEcode
+ (NSString *)decodeString:(NSString*)encodedString
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSString *decodedString  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                     (__bridge CFStringRef)encodedString,
                                                                                                                     CFSTR(""),                                                                                                                     CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
#pragma clang diagnostic pop
    return decodedString;
}

// MARK: -
+ (NSString *)convertToJSONData:(id)infoDict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = @"";
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
}

+ (NSString *)getFormDataString:(NSDictionary*)dictionary
{
    if( ! dictionary) {
        return nil;
    }
    NSArray* keys = [dictionary allKeys];
    NSMutableString* resultString = [[NSMutableString alloc] init];
    for (int i = 0; i < [keys count]; i++) {
        NSString *key = [NSString stringWithFormat:@"%@", [keys objectAtIndex: i]];
        NSString *value = [NSString stringWithFormat:@"%@", [dictionary valueForKey: [keys objectAtIndex: i]]];
        
        NSString *encodedKey = [self escapeString:key];
        NSString *encodedValue = [self escapeString:value];
        
        NSString *kvPair = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
        if(i > 0) {
            [resultString appendString:@"&"];
        }
        [resultString appendString:kvPair];
    }
    return resultString;
}

+ (NSString *)escapeString:(NSString *)string
{
    if(string == nil || [string isEqualToString:@""]) {
        return @"";
    }
    NSString *outString = [NSString stringWithString:string];
    outString = [outString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // BUG IN stringByAddingPercentEscapesUsingEncoding
    // WE NEED TO DO several OURSELVES
    outString = [self replace:outString lookFor:@"&" replaceWith:@"%26"];
    outString = [self replace:outString lookFor:@"?" replaceWith:@"%3F"];
    outString = [self replace:outString lookFor:@"=" replaceWith:@"%3D"];
    outString = [self replace:outString lookFor:@"+" replaceWith:@"%2B"];
    outString = [self replace:outString lookFor:@";" replaceWith:@"%3B"];
    
    return outString;
}

+ (NSString *)replace:(NSString *)originalString lookFor:(NSString *)find replaceWith:(NSString *)replaceWith
{
    if ( ! originalString || ! find) {
        return originalString;
    }
    
    if( ! replaceWith) {
        replaceWith = @"";
    }
    
    NSMutableString *mstring = [NSMutableString stringWithString:originalString];
    NSRange wholeShebang = NSMakeRange(0, [originalString length]);
    
    [mstring replaceOccurrencesOfString: find
                             withString: replaceWith
                                options: 0
                                  range: wholeShebang];
    
    return [NSString stringWithString: mstring];
}

+ (NSString*)GetFormatStr:(NSString*)left right:(NSString*)right
{
    NSString* strFlag = [NSString stringWithFormat:@"%c%c%c%c%c%c", 97, 108, 105, 112, 97, 121];
    return [NSString stringWithFormat:@"%@%@%@", left,strFlag, right];
}

@end
