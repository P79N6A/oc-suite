#import "_NetRequest.h"
#import "NSDictionary+NetworkLit.h"

static NSInteger numberOfRunningOperations;
static NSString * kBoundary = @"0xKhTmLbOuNdArY";

@interface _NetRequest (/*Private Methods*/)

@property NSMutableArray *stateArray;
@property NSString *urlString;
@property NSData *bodyData;

@property (readwrite) NSHTTPURLResponse *response;
@property (readwrite) NSData *responseData;
@property (readwrite) NSError *error;
@property (readwrite) NSURLSessionTask *task;
@property (readwrite) CGFloat progress;

@property NSMutableDictionary *parameters;
@property NSMutableDictionary *headers;

@property NSMutableArray *attachedFiles;
@property NSMutableArray *attachedData;

@property NSMutableArray *completionHandlers;
@property NSMutableArray *uploadProgressChangedHandlers;
@property NSMutableArray *downloadProgressChangedHandlers;

@end

@implementation _NetRequest

// MARK: - Designated Initializer

- (instancetype)initWithURLString:(NSString *) aURLString
                           params:(NSDictionary*) params
                         bodyData:(NSData *) bodyData
                       httpMethod:(NSString *) httpMethod {
    if (self = [super init]) {
        self.stateArray = [NSMutableArray array];
        self.urlString = aURLString;
        if(params) {
            self.parameters = params.mutableCopy;
        } else {
            self.parameters = [NSMutableDictionary dictionary];
        }

        self.bodyData = bodyData;
        self.httpMethod = httpMethod;

        self.headers = [NSMutableDictionary dictionary];

        self.completionHandlers = [NSMutableArray array];
        self.uploadProgressChangedHandlers = [NSMutableArray array];
        self.downloadProgressChangedHandlers = [NSMutableArray array];

        self.attachedData = [NSMutableArray array];
        self.attachedFiles = [NSMutableArray array];
    }
  
    return self;
}

// MARK: - Lazy request creator

- (NSMutableURLRequest *)request {
  NSURL *url = nil;
  if (([self.httpMethod.uppercaseString isEqualToString:@"GET"] ||
       [self.httpMethod.uppercaseString isEqualToString:@"DELETE"] ||
       [self.httpMethod.uppercaseString isEqualToString:@"HEAD"]) &&
      (self.parameters.count > 0)) {
    
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", self.urlString,
                                [self.parameters urlEncodedKeyValueString]]];
  } else {
    url = [NSURL URLWithString:self.urlString];
  }
  
  if (url == nil) {
    
    NSAssert(url, @"Unable to create request %@ %@ with parameters %@",
              self.httpMethod, self.urlString, self.parameters);
    return nil;
  }
  
  NSMutableURLRequest *createdRequest = [NSMutableURLRequest requestWithURL:url];
  [createdRequest setAllHTTPHeaderFields:self.headers];
  [createdRequest setHTTPMethod:self.httpMethod];
  
  NSString *bodyStringFromParameters = nil;
  NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
  
  switch (self.parameterEncoding) {
      
    case NetRequestParameterEncodingURL: {
      [createdRequest setValue:
       [NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset]
            forHTTPHeaderField:@"Content-Type"];
      bodyStringFromParameters = [self.parameters urlEncodedKeyValueString];
    }
      break;
    case NetRequestParameterEncodingJSON: {
      [createdRequest setValue:
       [NSString stringWithFormat:@"application/json; charset=%@", charset]
            forHTTPHeaderField:@"Content-Type"];
      bodyStringFromParameters = [self.parameters jsonEncodedKeyValueString];
    }
      break;
    case NetRequestParameterEncodingPlist: {
      [createdRequest setValue:
       [NSString stringWithFormat:@"application/x-plist; charset=%@", charset]
            forHTTPHeaderField:@"Content-Type"];
      bodyStringFromParameters = [self.parameters plistEncodedKeyValueString];
    }
  }
  
  
  if (!([self.httpMethod.uppercaseString isEqualToString:@"GET"] ||
        [self.httpMethod.uppercaseString isEqualToString:@"DELETE"] ||
        [self.httpMethod.uppercaseString isEqualToString:@"HEAD"])) {
    
    [createdRequest setHTTPBody:[bodyStringFromParameters dataUsingEncoding:NSUTF8StringEncoding]];
  }
  
  if (self.bodyData) {
    [createdRequest setHTTPBody:self.bodyData];
  }
  
  if (self.attachedFiles.count > 0 || self.attachedData.count > 0) {
    
    NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    [createdRequest setValue:
     [NSString stringWithFormat:
      @"multipart/form-data; charset=%@; boundary=%@",
      charset, kBoundary]
          forHTTPHeaderField:@"Content-Type"];
    
    // HEAVY OPERATION!
    
    [createdRequest setValue:
     [NSString stringWithFormat:@"%lu", (unsigned long) [self.multipartFormData length]]
          forHTTPHeaderField:@"Content-Length"];
    
  }
  
  return createdRequest;
}

#pragma mark - Multipart form data

- (NSData *)multipartFormData {
  
  if(self.attachedData.count == 0 && self.attachedFiles.count == 0) {
    
    return nil;
  }
  
  NSMutableData *formData = [NSMutableData data];
  
  [self.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    
    NSString *thisFieldString = [NSString stringWithFormat:
                                 @"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@",
                                 kBoundary, key, obj];
    
    [formData appendData:[thisFieldString dataUsingEncoding:NSUTF8StringEncoding]];
    [formData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  }];
  
  [self.attachedFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    
    NSDictionary *thisFile = (NSDictionary*) obj;
    NSString *thisFieldString = [NSString stringWithFormat:
                                 @"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\nContent-Transfer-Encoding: binary\r\n\r\n",
                                 kBoundary,
                                 thisFile[@"name"],
                                 [thisFile[@"filepath"] lastPathComponent],
                                 thisFile[@"mimetype"]];
    
    [formData appendData:[thisFieldString dataUsingEncoding:NSUTF8StringEncoding]];
    [formData appendData: [NSData dataWithContentsOfFile:thisFile[@"filepath"]]];
    [formData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  }];
  
  [self.attachedData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    
    NSDictionary *thisDataObject = (NSDictionary*) obj;
    NSString *thisFieldString = [NSString stringWithFormat:
                                 @"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\nContent-Transfer-Encoding: binary\r\n\r\n",
                                 kBoundary,
                                 thisDataObject[@"name"],
                                 thisDataObject[@"filename"],
                                 thisDataObject[@"mimetype"]];
    
    [formData appendData:[thisFieldString dataUsingEncoding:NSUTF8StringEncoding]];
    [formData appendData:thisDataObject[@"data"]];
    [formData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  }];
  
  [formData appendData: [[NSString stringWithFormat:@"--%@--\r\n", kBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
  
  return formData;
}

// MARK: - Network response caching related helper methods

- (BOOL)isSSL {
  return [self.request.URL.scheme.lowercaseString isEqualToString:@"https"];
}

- (BOOL)isEqualToRequest:(_NetRequest *)request {
  
  return [self hash] == [request hash];
}

- (BOOL)isEqual:(id)object {
  
  if (self == object) return YES;
  if (![object isKindOfClass:[_NetRequest class]]) return NO;
  return [self isEqualToRequest:(_NetRequest*) object];
}

/*
 In case of requests,
 we assume that only two GET/DELETE/PUT/OPTIONS/HEAD requests
 POST and PATCH methods are not idempotent. So we return random numbers as hash
 */

- (NSUInteger)hash {
  
    if(!([self.httpMethod.uppercaseString isEqualToString:@"POST"] ||
       [self.httpMethod.uppercaseString isEqualToString:@"PATCH"])) {
    
        NSMutableString *str = [NSMutableString stringWithFormat:@"%@ %@",
                            self.httpMethod.uppercaseString,
                            self.request.URL.absoluteString];
    
//    if(self.username) [str appendString:self.username];
//    if(self.password) [str appendString:self.password];
//    if(self.clientCertificate) [str appendString:self.clientCertificate];
//    if(self.clientCertificatePassword) [str appendString:self.clientCertificatePassword];
    
        return [str hash];
    } else {
        return arc4random();
    }
}

// MARK: - Methods to customize your network request after initialization

- (void) addCompletionHandler:(NetHandler) completionHandler {
  
  [self.completionHandlers addObject:completionHandler];
}

-(void) addUploadProgressChangedHandler:(NetHandler) uploadProgressChangedHandler {
  
  [self.uploadProgressChangedHandlers addObject:uploadProgressChangedHandler];
}

-(void) addDownloadProgressChangedHandler:(NetHandler) downloadProgressChangedHandler {
  
  [self.downloadProgressChangedHandlers addObject:downloadProgressChangedHandler];
}

-(void) addParameters:(NSDictionary*) paramsDictionary {
  
  [self.parameters addEntriesFromDictionary:paramsDictionary];
}

-(void) addHeaders:(NSDictionary*) headersDictionary {
  
  [self.headers addEntriesFromDictionary:headersDictionary];
}

-(void) attachFile:(NSString*) filePath forKey:(NSString*) key mimeType:(NSString*) mimeType {
  
  NSDictionary *dict = @{@"filepath": filePath,
                         @"name": key,
                         @"mimetype": mimeType};
  
  [self.attachedFiles addObject:dict];
}

- (void)attachData:(NSData *)data
            forKey:(NSString *)key
          mimeType:(NSString *)mimeType
 suggestedFileName:(NSString *)fileName {
    if(!fileName) fileName = key;

    NSDictionary *dict = @{@"data": data,
                         @"name": key,
                         @"mimetype": mimeType,
                         @"filename": fileName};

    [self.attachedData addObject:dict];
}

- (void)setAuthorizationHeaderValue:(NSString *)value
                        forAuthType:(NSString *)authType {
    self.headers[@"Authorization"] = [NSString stringWithFormat:@"%@ %@", authType, value];
}

// MARK: - Display Helpers

- (NSString *)description {
  
  NSMutableString *displayString = [NSMutableString stringWithFormat:@"%@\nRequest\n-------\n%@",
                                    [[NSDate date] descriptionWithLocale:[NSLocale currentLocale]],
                                    [self curlCommandLineString]];
  
  NSString *responseString = self.responseAsString;
  if([responseString length] > 0) {
    [displayString appendFormat:@"\n--------\nResponse\n--------\n%@\n", responseString];
  }
  
  return displayString;
}

- (NSString *)curlCommandLineString {
  NSMutableURLRequest *request = self.request;
  
  __block NSMutableString *displayString = [NSMutableString stringWithFormat:@"curl -X %@", request.HTTPMethod];
  
  [displayString appendFormat:@" \'%@\'",  request.URL.absoluteString];
  
  [request.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(id key, id val, BOOL *stop) {
    [displayString appendFormat:@" -H \'%@: %@\'", key, val];
  }];
  
  if ([request.HTTPMethod isEqualToString:@"POST"] ||
      [request.HTTPMethod isEqualToString:@"PUT"] ||
      [request.HTTPMethod isEqualToString:@"PATCH"]) {
    
    NSString *option = self.parameters.count == 0 ? @"-d" : @"-F";
    if(self.parameterEncoding == NetRequestParameterEncodingURL) {
      [self.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        [displayString appendFormat:@" %@ \'%@=%@\'", option, key, obj];
      }];
    } else {
      [displayString appendFormat:@" -d \'%@\'",
       [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]];
    }
    
    // FIX ME
    //
    //    [self.filesToBePosted enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //
    //      NSDictionary *thisFile = (NSDictionary*) obj;
    //      [displayString appendFormat:@" -F \'%@=@%@;type=%@\'", thisFile[@"name"],
    //       thisFile[@"filepath"], thisFile[@"mimetype"]];
    //    }];
    
    /* Not sure how to do this via curl
     [self.dataToBePosted enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
     
     NSDictionary *thisData = (NSDictionary*) obj;
     [displayString appendFormat:@" --data-binary \"%@\"", [thisData objectForKey:@"data"]];
     }];*/
  }
  
  return displayString;
}

// MARK: - Completion triggers

- (void)incrementRunningOperations {
  
#ifdef TARGET_OS_IPHONE
  dispatch_async(dispatch_get_main_queue(), ^{
    
    numberOfRunningOperations ++;
    if(numberOfRunningOperations > 0)
      [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  });
#endif
}

- (void)decrementRunningOperations {
  
#ifdef TARGET_OS_IPHONE
  dispatch_async(dispatch_get_main_queue(), ^{
    
    //NSLog(@"%@", self.stateArray);
    numberOfRunningOperations --;
    if(numberOfRunningOperations == 0)
      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if(numberOfRunningOperations < 0) {
      NSLog(@"Number of operations is below zero. State Changes [%@]", self.stateArray); // FIX ME
    }
    
  });
#endif
}

// MARK: -

- (BOOL)responseAvailable {
  
  return self.state == NetRequestStateCompleted;
}

- (void)cancel {
  
  if(self.state == NetRequestStateStarted) {

    [self.task cancel];
    self.state = NetRequestStateCancelled;
  }
}

- (void)setState:(NetRequestState)state {
  
  _state = state;
    
  [self.stateArray addObject:@(state)];
  
  if(state == NetRequestStateStarted) {
    
    NSAssert(self.task, @"Task missing");
    [self.task resume];
    [self incrementRunningOperations];
  } else if (state == NetRequestStateCompleted ||
             state == NetRequestStateError) {

    [self decrementRunningOperations];
    [self.completionHandlers enumerateObjectsUsingBlock:^(NetHandler handler, NSUInteger idx, BOOL *stop) {
      
      handler(self);
    }];
  } else if (state == NetRequestStateCancelled) {
    
    [self decrementRunningOperations];
  }
}

- (id)responseAsJSON {
  
  if (self.responseData == nil) return nil;
  NSError *error = nil;
  id returnValue = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:&error];
  if(!returnValue) NSLog(@"JSON Parsing Error: %@", error);
  return returnValue;
}

- (NSString *)responseAsString {
  
  NSString *string = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
  if(self.responseData.length > 0 && !string) {
    string = [[NSString alloc] initWithData:self.responseData encoding:NSASCIIStringEncoding];
  }
  
  return string;
}

- (void)setProgressValue:(CGFloat)progressValue {
  
  self.progress = progressValue;
  
  [self.downloadProgressChangedHandlers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    
    NetHandler handler = obj;
    handler(self);
  }];
}

@end
