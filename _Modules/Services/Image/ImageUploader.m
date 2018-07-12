//
//  PictureUploader.m
// fallen.ink
//
//  Created by fallen on 15/8/4.
//

#import "_greats.h"
#import "_building_tools.h"
#import "ImageUploader.h"
#import "ImageUploadApi.h"

#if 0
static const CGFloat kUploadTimeLimit = 60.f;               //单位秒
static NSMutableArray* uploaderArray = nil;

@class SignalFromRequest;

@interface ImageUploader ()

@property (nonatomic, copy) ObjectBlock uploadSuccessBlock;
@property (nonatomic, copy) ErrorBlock uploadFailBlock;
@property (nonatomic, copy) FloatBlock uploadProgressBlock;

@property (nonatomic, strong) UIImage *uploadImage;

@end

@implementation ImageUploader

@def_singleton( ImageUploader )

- (instancetype)init {
    self = [super init];
    if (self) {
        if (uploaderArray == nil) {
            uploaderArray = [NSMutableArray new];
        }
        [uploaderArray addObject:self];
    }
    return self;
}

- (void)uploadPicture:(UIImage *)picture channelId:(int32_t)channel type:(int)type success:(ObjectBlock)success fail:(ErrorBlock)fail progress:(FloatBlock)progress {
    self.uploadImage = picture;
    self.uploadSuccessBlock = success;
    self.uploadFailBlock = fail;
    self.uploadProgressBlock = progress;
    
    GetUploadImageurlRequest *request = [GetUploadImageurlRequest new];
#ifdef datapayload
    request.uid = datapayload.userBaseInfo.uuid;
#else
    request.uid = @"";
#endif
    
    request.channel = channel;
    request.type = type;

    @weakify(self)
    [self requestWith:request
              success:^(id obj) {
                  @strongify(self)
                  
                  GetUploadImageUrlResponse *response = obj;
                  UploadImageRequest *uploadImageRequest = [UploadImageRequest new];
                  uploadImageRequest.filename = response.info;
                  
                  if (type == UploadImageType_Big) {
                      [self uploadHDImageWith:uploadImageRequest];
                  } else {
                      [self uploadImageWith:uploadImageRequest];
                  }
              } failure:^(NSError *error) {
                  @strongify(self)
                  
                  [self errorCallBack:error];
              }];
}

- (void)uploadHDPicture:(UIImage *)picture success:(ObjectBlock)success fail:(ErrorBlock)fail progress:(FloatBlock)progress {
    [self uploadPicture:picture channelId:UploadImageChannelType_Default type:UploadImageType_Big success:success fail:fail progress:progress];
}

- (void)uploadPictures:(NSArray<UIImage *> *)pictures channelId:(int32_t)channel type:(int)type success:(ArrayBlock)success fail:(ErrorBlock)fail progress:(FloatBlock)progress {
    exceptioning(@"未实现")
}

#pragma mark -

- (void)uploadHDImageWith:(UploadImageRequest *)uploadImageRequest {
#if 0
    [global_queue queueBlock:^{
        UIImage *realImage = [ImageUtil fixOrientation:self.uploadImage];
        NSData *imageData = [ImageUtil compressImageForUpload:realImage];

        uploadImageRequest.fileLength = imageData.length;

        [self requestWith:uploadImageRequest
               parameters:nil
         constructingData:^(id<AFMultipartFormData> formData) {
             [formData appendPartWithFileData:imageData
                                         name:uploadImageRequest.filename
                                     fileName:uploadImageRequest.filename
                                     mimeType:@"image/jpeg"];
         } success:^(id obj) {
             NSError *error = nil;
             UploadHDImageResponse *response = [MTLJSONAdapter modelOfClass:UploadHDImageResponse.class
                                                         fromJSONDictionary:obj
                                                                      error:&error];
             if (response.result == 1) {
                 [self successCallbackWithObject:response];
             } else {
                 NSError *error = make_error_3(@"app.common.imageupload", response.errCode, @"图片上传失败");
                 
                 [self errorCallBack:error];
             }
         } failure:^(NSError *error) {
             [self errorCallBack:error];
         }];
    }];
#endif 
    
    [global_queue queueBlock:^{
        NSString *url = [uploadImageRequest buildUrl];
        
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                           timeoutInterval:kUploadTimeLimit];
        [request setValue:uploadImageRequest.filename forHTTPHeaderField:@"name"];
        
        //调整图片
        UIImage *realImage = [ImageUtil fixOrientation:self.uploadImage];
        
        //压缩图片
        NSData *imageData = [ImageUtil compressImageForUpload:realImage];
        
        NSMutableString *body = [[NSMutableString alloc]init];
        NSMutableData *myRequestData = [NSMutableData data];
        [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]]; // 将body字符串转化为UTF8格式的二进制
        [myRequestData appendData:imageData]; //将image的data加入
        
        [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"]; //设置HTTPHeader
        [request setValue:[NSString stringWithFormat:@"%tu", [myRequestData length]] forHTTPHeaderField:@"Content-Length"]; //设置Content-Length
        [request setHTTPBody:myRequestData]; // 设置http body
        [request setHTTPMethod:@"POST"]; // http method
        
        //建立连接，设置代理
        NSHTTPURLResponse *urlResponse = nil;
        NSError *error = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
        if (!error) {
            NSError *err = nil;
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseData
                                                                       options:kNilOptions
                                                                         error:&err];
            
            LOG(@"image upload response = %@", jsonObject);
            
            UploadHDImageResponse *response = [MTLJSONAdapter modelOfClass:UploadHDImageResponse.class
                                                        fromJSONDictionary:jsonObject
                                                                     error:&err];
            if (response.result == 1) {
                [self successCallbackWithObject:response];
            } else {
                NSError *error = make_error_3(@"app.common.imageupload", response.errCode, @"图片上传失败");
                
                [self errorCallBack:error];
            }
        } else {
            [self errorCallBack:error];
        }

    }];
}

- (void)uploadImageWith:(UploadImageRequest *)uploadImageRequest {
    [global_queue queueBlock:^{
        NSString *url = [uploadImageRequest buildUrl];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                           timeoutInterval:kUploadTimeLimit];
        
        UIImage *realImage = [ImageUtil fixOrientation:self.uploadImage];
        NSData *imageData = [ImageUtil compressImageForUpload:realImage];
        
        NSMutableData *myRequestData = [NSMutableData data];
        [myRequestData appendData:imageData]; //将image的data加入
        
        [request setValue:uploadImageRequest.filename forHTTPHeaderField:@"name"];
        [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"]; //设置HTTPHeader
        [request setValue:[NSString stringWithFormat:@"%tu", [myRequestData length]] forHTTPHeaderField:@"Content-Length"]; //设置Content-Length
        [request setHTTPBody:myRequestData]; // 设置http body
        [request setHTTPMethod:@"POST"]; // http method
        
        //建立连接，设置代理
        NSHTTPURLResponse *urlResponse = nil;
        NSError *error = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
        if (!error) {
            NSError *err = nil;
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseData
                                                                       options:kNilOptions
                                                                         error:&err];
            
            LOG(@"image upload response = %@", jsonObject);
            
            NSString *result = [jsonObject objectForKey:@"result"];
            NSString *errorCode = [jsonObject objectForKey:@"errCode"];
            NSString *info = [jsonObject objectForKey:@"info"];
            
            if (result.intValue == 1) {
                
                [self successCallbackWithObject:info];
            } else {
                NSError *error = make_error_3(@"app.common.imageupload", errorCode.intValue, @"图片上传失败");
                [self errorCallBack:error];
            }
        } else {
            [self errorCallBack:error];
        }
    }];
}

#pragma mark - 回调

- (void)successCallbackWithObject:(NSObject *)object {
    if (self.uploadSuccessBlock) {
        if (is_main_thread) {
            self.uploadSuccessBlock(object);
            [self uploadDone];
        } else {
            @weakify(self)
            [main_queue queueBlock:^{
                @strongify(self)
                self.uploadSuccessBlock(object);
                [self uploadDone];
            }];
        }
    }
}

- (void)errorCallBack:(NSError *)error {
    if (self.uploadFailBlock) {
        @weakify(self)
        [main_queue queueBlock:^{
            @strongify(self)
            self.uploadFailBlock(error);
            [self uploadDone];
        }];
    }
}

- (void)progressCallBack:(float)newProgress{
    //上传进度
    if (self.uploadProgressBlock) {
        @weakify(self)
        [main_queue queueBlock:^{
            @strongify(self)
            self.uploadProgressBlock(newProgress);
        }];
    }
}

#pragma mark - Private Method

- (void)uploadDone {
    self.uploadImage = nil;
    self.uploadFailBlock = nil;
    self.uploadProgressBlock = nil;
    self.uploadSuccessBlock = nil;
    
    [uploaderArray removeObject:self];
}

@end

#endif
