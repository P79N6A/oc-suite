//
//  ALSImageLoaderImpl.m
//  NewStructure
//
//  Created by 7 on 20/11/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <objc/runtime.h>
#import "ALSportsPrecompile.h"
#import "ALSImageLoaderImpl.h"
#if __has_OSSService
#import "OSSService.h"
#endif


#pragma mark -

@interface ALSImageLoaderImpl ()

#if __has_OSSService
@property (nonatomic, strong) OSSClient *ossClient;
#endif

@end

@implementation ALSImageLoaderImpl

// MARK: - Lazy load
#if __has_OSSService
#define OSS_ENDPOINT (@"http://oss-cn-hangzhou.aliyuncs.com")
- (OSSClient *)ossClient {
    if (!_ossClient) {
        _ossClient = [[OSSClient alloc] initWithEndpoint:OSS_ENDPOINT credentialProvider:nil];
    }
    
    return _ossClient;
}
#endif


// MARK: - Impl

// 测试：@"http://img3.redocn.com/tupian/20150312/haixinghezhenzhubeikeshiliangbeijing_3937174.jpg"
- (void)load:(UIImageView *)imageView withImageURLString:(NSString *)imageURLString placeholderImage:(UIImage *)placeholderImage {
#if __has_AEDataKit
    AEDKWebImageLoader *loader = [[AEDKWebImageLoader alloc] init];
    
    [loader setImageForImageView:imageView withURL:[NSURL URLWithString:imageURLString] placeholderImage:nil progress:^(int64_t totalAmount, int64_t currentAmount) {
        
    } completed:^(NSURL * _Nullable imageUrl, UIImage * _Nullable image, NSError * _Nullable error) {
        NSLog(@"图片请求结束");
    }];
#endif
}

- (void)uploadOnCloudWithImage:(UIImage *)image
                     objectKey:(NSString *)objectKey
                     accessKey:(NSString *)accessKey
                     secretKey:(NSString *)secretKey
                         token:(NSString *)token
                    expiration:(NSString *)expiration
                   callbackURL:(NSString *)callbackURL
                      filename:(NSString *)filename
                       current:(ALSRequestCurrentBlock)currentHandler
                      finished:(ALSRequestFinishedBlock)finishedHandler {
#if __has_OSSService
#define OSS_BUCKETNAME (@"oneimg")
    id<OSSCredentialProvider> provider = [[OSSFederationCredentialProvider alloc] initWithFederationTokenGetter:^OSSFederationToken *{
        OSSFederationToken *federationToken = [OSSFederationToken new];
        federationToken.tAccessKey = accessKey;
        federationToken.tSecretKey = secretKey;
        federationToken.tToken = token;
        federationToken.expirationTimeInGMTFormat = expiration;
        return federationToken;
    }];
    
    [self.ossClient setCredentialProvider:provider];
    
    NSString *aliuid = [AESUser currentUser].uid;
    
    OSSPutObjectRequest *request = [OSSPutObjectRequest new];
    request.bucketName = OSS_BUCKETNAME;
    request.objectKey = objectKey;
    request.uploadingData = UIImageJPEGRepresentation(image, 1);
    request.contentType = @".JPEG";
    //size=${size}&mimeType=${mimeType}&height=${imageInfo.height}&width=${imageInfo.width}
    request.callbackParam = @{
                              @"callbackUrl":callbackURL,
                              @"callbackBody": [NSString stringWithFormat:@"filename=%@&size=%luf&mimeType=JPEG&height=%f&width=%f&aliuid=%@", filename, (unsigned long)[image byteCount],image.size.height * 2, image.size.width * 2,aliuid]
                              };
    
    request.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"正在发送：%lld, 已上传长度%lld, 总长度%lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
        if (currentHandler) {
//            CGFloat ratio = (CGFloat)totalByteSent / (CGFloat)totalBytesExpectedToSend;
//            progress(ratio, bytesSent, totalByteSent, totalBytesExpectedToSend);
            
            currentHandler(totalBytesExpectedToSend, totalByteSent);
        }
    };
    
    OSSTask *putTask = [self.ossClient putObject:request];
    [putTask continueWithBlock:^id(OSSTask *task) {
        task = [self.ossClient presignPublicURLWithBucketName:OSS_BUCKETNAME withObjectKey:objectKey]; // 必须对上传的对象，进行签名，否则会有认证error
        
        if (finishedHandler) {
            finishedHandler(task.error, task.result, nil);
        }

        return nil;
    }];
#endif
}

- (void)uploadOnCloudWithImageURL:(NSURL *)imageURL
                        objectKey:(NSString *)objectKey
                        accessKey:(NSString *)accessKey
                        secretKey:(NSString *)secretKey
                          current:(ALSRequestCurrentBlock)currentHandler
                         finished:(ALSRequestFinishedBlock)finishedHandler {
    // TODO: 该方法还没有测试过！！！！！！！！！！！！别轻信！！！！！！！！！！
    
#if __has_OSSService
    id<OSSCredentialProvider> provider = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:accessKey secretKey:secretKey];
    [self.ossClient setCredentialProvider:provider];
    
    OSSPutObjectRequest *request = [OSSPutObjectRequest new];
    request.bucketName = OSS_BUCKETNAME;
    request.objectKey = objectKey;
    request.uploadingFileURL = imageURL;
    // TODO: 为什么这里不需要callback？？？？？
    //    request.callbackParam = @{@"callbackUrl": @""/*info.callbackUrl*/};
    
    request.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"正在发送：%lld, 已上传长度%lld, 总长度%lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
        if (currentHandler) {
            currentHandler(totalBytesExpectedToSend, totalByteSent);
        }
    };
    
    OSSTask *putTask = [self.ossClient putObject:request];
    
    [putTask continueWithBlock:^id(OSSTask *task) {
        task = [self.ossClient presignPublicURLWithBucketName:OSS_BUCKETNAME withObjectKey:objectKey]; // 必须对上传的对象，进行签名，否则会有认证error
        
        if (finishedHandler) {
            finishedHandler(task.error, task.result, nil);
        }
        
        return nil;
    }];
#endif
}

@end
