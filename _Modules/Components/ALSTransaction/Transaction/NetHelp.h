//
//  NetHelp.h
//  FLPayManagerDemo
//
//  Created by  杨子民 on 2017/9/15.
//  Copyright © 2017年 gitKong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NetHelp : NSObject

/**
 *  @author yangzm
 *
 *  如果不想引入第三方库，就调用系统的api post 异步调用
 *
 *  @param Url  url
 *  @param params 传入字典参数
 *  @param block  返回结果，如果connectionError 不为nil 成功
 */
+ (void)post:(NSString *)Url RequestParams:(NSDictionary *)params FinishBlock:(void (^)(NSData *  _data, NSURLResponse * _response, NSError *  _error)) block;//post请求封装

+(NSString*) asynchronousPost:(NSString*) spec param:(NSDictionary *)params stautsCode:(NSInteger*)code;
+ (NSString *)parseParams:(NSDictionary *)params;
+ (NSString *)convertToJSONData:(id)infoDict;
+ (NSString *)getFormDataString:(NSDictionary*)dictionary;
+ (NSString *)escapeString:(NSString *)string;
+ (NSString*)GetFormatStr:(NSString*)left right:(NSString*)right;
/**
 *  @author yangzm
 *
 *  用来调用get 消除旧版本警告
 *
 *  @param request request
 *  @param response response
 *  @param error error
 *
 *  @return NSData
 */
+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error;

+ (NSString *)keyValueSortedStringForDictionary:(NSDictionary *)dictionary;
+ (NSDictionary *)signedDictionaryForParameter:(NSDictionary *)parameter key:(NSString*)key keyvalue:(NSString*)keyvalue;
+ (NSDictionary *)signedDictionaryH5ForParameter:(NSDictionary *)parameter key:(NSString*)key keyvalue:(NSString*)keyvalue;

+ (NSString*)dictionaryToJson:(NSDictionary *)dic;
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+ (NSString *)md5:(NSString*)input;

+ (NSString*) encodeString:(NSString*)unencodedString;
+ (NSString *) decodeString:(NSString*)encodedString;
@end
