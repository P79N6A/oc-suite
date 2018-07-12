//
//  LogUploader.h
// fallen.ink
//
//  Created by fallen.ink on 12/21/15.
//
//

#import <Foundation/Foundation.h>
#import "_greats.h"

@interface LogUploader : NSObject

@singleton( LogUploader )

@error( err_LogFileUploadFailed )

- (void)uploadLogFileWithErrorType:(int)errorType
              withErrorTypeMessage:(NSString *)errorTypeMessage
                  withErrorMessage:(NSString *)errorMessage
                      successBlock:(void (^)(id respoonse))successHandler
                        errorBlock:(void (^)(NSError *error))failHandler;

@end
