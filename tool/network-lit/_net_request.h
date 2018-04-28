#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum {
  NetRequestParameterEncodingURL = 0, // default
  NetRequestParameterEncodingJSON,
  NetRequestParameterEncodingPlist
} NetRequestParameterEncoding;


typedef enum {
  NetRequestStateReady = 0,
  NetRequestStateStarted,
  NetRequestStateCancelled,
  NetRequestStateCompleted,
  NetRequestStateError
} NetRequestState;

@interface _NetRequest : NSObject {
  
  NetRequestState _state;
}

// MARK: - 请求
@property (readonly) NSMutableURLRequest *request;

@property NetRequestParameterEncoding parameterEncoding;
@property (readonly) NetRequestState state;

@property NSString *downloadPath;

//@property (readonly) BOOL requiresAuthentication;
@property (readonly) BOOL isSSL; // 是否 HTTPS

@property NSString *httpMethod;

// MARK: - 应答
@property (readonly) NSHTTPURLResponse *response;

@property (readonly) NSData *multipartFormData;
@property (readonly) NSData *responseData;
@property (readonly) NSError *error;
@property (readonly) NSURLSessionTask *task;
@property (readonly) CGFloat progress;

@property (readonly) BOOL responseAvailable;

@property (readonly) id responseAsJSON;
@property (readonly) NSString *responseAsString;

// MARK: - 
- (instancetype)initWithURLString:(NSString *)aURLString
                           params:(NSDictionary *)params
                         bodyData:(NSData *)bodyData
                       httpMethod:(NSString *)method;

typedef void (^NetHandler)(_NetRequest *completedRequest);

- (void)addParameters:(NSDictionary *)paramsDictionary;
- (void)addHeaders:(NSDictionary *)headersDictionary;
- (void)setAuthorizationHeaderValue:(NSString *)token forAuthType:(NSString *)authType;

- (void)attachFile:(NSString*) filePath forKey:(NSString *)key mimeType:(NSString *)mimeType;
- (void)attachData:(NSData*) data forKey:(NSString *)key mimeType:(NSString *)mimeType suggestedFileName:(NSString *)fileName;

- (void)addCompletionHandler:(NetHandler)completionHandler;
- (void)addUploadProgressChangedHandler:(NetHandler)uploadProgressChangedHandler;
- (void)addDownloadProgressChangedHandler:(NetHandler)downloadProgressChangedHandler;

- (void)cancel;

@end
