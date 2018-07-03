//
//  GrowthServer.m
//  consumer
//
//  Created by 张衡的mini on 16/12/26.
//
//

#import "GrowthServer.h"

static const CGFloat kUploadTimeLimit = 60.f;               //单位秒

@implementation GrowthServer

#if 0
- (void)uploadDocumentWithmyRequestData:(NSData *)myRequestData documentName:(NSString *)documentName successBlock:(Block)successHandler {
    [global_queue queueBlock:^{	
        NSString *url = @"http://192.168.10.220:8080/log/uploadAndroid";
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                           timeoutInterval:kUploadTimeLimit];

        [request setValue:documentName forHTTPHeaderField:@"name"];
        [request setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"]; //设置HTTPHeader
        [request setValue:[NSString stringWithFormat:@"%tu", [myRequestData length]] forHTTPHeaderField:@"Content-Length"]; //设置Content-Length
        [request setHTTPBody:myRequestData]; // 设置http body
        [request setHTTPMethod:@"POST"]; // http method
        
        //建立连接，设置代理
        NSHTTPURLResponse *urlResponse = nil;
        NSError *error = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
        //{"maxLogNum":0,"maxLogPerSendTime":0,"maxLogErrReSendTime":0,"result":0,"errorLevel":0,"errorCode":3}
        if (!error) {
            NSError *err = nil;
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseData
                                                                       options:kNilOptions
                                                                         error:&err];

            
            NSString *result = [jsonObject objectForKey:@"result"];
            
            if (result.intValue == 1) {
                //Success
                successHandler();
            } else {

            }
        } else {
            
        }
    }];
}
#endif

@end
