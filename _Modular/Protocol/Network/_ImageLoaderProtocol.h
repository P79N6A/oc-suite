#import <UIKit/UIKit.h>
#import "_Protocol.h"
#import "_NetworkProtocol.h"

#pragma mark -

@protocol _ImageLoaderProtocol <_Protocol>

/**
 *  @brief 加载图片
 *  @param imageView 图片控件
 *  @param imageURLString 图片URL
 *  @param placeholderImage 图片占位
 */
- (void)load:(UIImageView *)imageView withImageURLString:(NSString *)imageURLString placeholderImage:(UIImage *)placeholderImage;

// MARK: - 特定的云平台

/**
 *  @brief 特定的云平台 图片上传
 *  @param image 图片
 *  @param accessKey ...
 *  @param secretKey ...
 *  @param token ...
 *  @param expiration 指明Token的失效时间，格式为GMT字符串，如: "2015-11-03T08:51:05Z"
 *  @param callbackURL server回调参数
 *  @param filename server回调参数
 *  @param currentHandler 进度反馈句柄
 *  @param finishedHandler 结束接收句柄
 *
 *  潜在其他参数：contentType (PNG, JPEG, ...)
 */
- (void)uploadOnCloudWithImage:(UIImage *)image
                           uid:(NSString *)uid
                     objectKey:(NSString *)objectKey
                     accessKey:(NSString *)accessKey
                     secretKey:(NSString *)secretKey
                         token:(NSString *)token
                    expiration:(NSString *)expiration
                   callbackURL:(NSString *)callbackURL
                      filename:(NSString *)filename
                       current:(_RequestCurrentBlock)currentHandler
                      finished:(_RequestFinishedBlock)finishedHandler;

- (void)uploadOnCloudWithImageURL:(NSURL *)imageURL
                        objectKey:(NSString *)objectKey
                        accessKey:(NSString *)accessKey
                        secretKey:(NSString *)secretKey
//                            token:(NSString *)token
//                       expiration:(NSString *)expiration
//                      callbackURL:(NSString *)callbackURL
//                         filename:(NSString *)filename
                          current:(_RequestCurrentBlock)currentHandler
                         finished:(_RequestFinishedBlock)finishedHandler;

@optional

/**
 *  @brief 也可以讲 image 分级 管理 封装在这里，可选
 */

@end
