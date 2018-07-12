//
//  LogUploader.m
// fallen.ink
//
//  Created by fallen.ink on 12/21/15.
//
//

#import "LogUploader.h"
#import "LogFileManager.h"
#import "LogRequestDataBuilder.h"
#import "_vendor_afnetworking.h"

@implementation LogUploader

@def_singleton( LogUploader )

@def_error( err_LogFileUploadFailed, 1000, @"错误日志上传失败")

- (void)uploadLogFileWithErrorType:(int)errorType
              withErrorTypeMessage:(NSString *)errorTypeMessage
                  withErrorMessage:(NSString *)errorMessage
                      successBlock:(void (^)(id response))successHandler
                        errorBlock:(void (^)(NSError *error))failHandler {
    NSString *uploadUrl = [NSString stringWithFormat:@"%@?tk=%@",
                           @"kStudent_Consult_UpdateLogFileURLString",
                           @"token"];

    AFHTTPSessionManager *httpSessionManager    = [AFHTTPSessionManager manager];
    // 用二进制形式 反序列化
    httpSessionManager.responseSerializer   = [AFHTTPResponseSerializer serializer];
    
    // 上传用的文件名
    NSString *remoteFilename    = [LogFileManager sharedInstance].zippedLogFilename;
    
    // LogRequestData
    LogRequestDataBuilder *builder   = [LogRequestDataBuilder new];
    [builder setFeedbackType:errorType];
    [builder setQuestions:errorTypeMessage];
    [builder setExplain:errorMessage];
    
    [httpSessionManager POST:uploadUrl
                  parameters:[builder generate]
   constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
       /*
        Data: 需要上传的数据
        name: 服务器参数的名称
        fileName: 文件名称
        mimeType: 文件的类型
        */
       
       // Zip logfile
       NSData *logFileData = [[LogFileManager sharedInstance] compressLogFiles];
       [formData appendPartWithFileData:logFileData
                                   name:@"file" // 文件，又如：image, document
                               fileName:remoteFilename // 文件类型
                               mimeType:@"application/zip"]; // MIME类型，其他如：text/plain
   } progress:^(NSProgress * _Nonnull uploadProgress) {
       //
   } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       //
//       NSError *error;
//       GPBSimpleResponse *response = [GPBSimpleResponse parseFromData:responseObject error:&error];
//       
//       if ([response isSucceed]) {
//           successHandler(response);
//       } else if (error) {
//           failHandler([NSError err_PBParser]);
//       } else {
//           failHandler(self.err_LogFileUploadFailed);
//       }
   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       //
       failHandler(self.err_LogFileUploadFailed);
   }];
}

@end
