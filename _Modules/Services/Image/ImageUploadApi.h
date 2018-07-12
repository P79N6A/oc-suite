//
//  ImageUploadRequest.h
//  consumer
//
//  Created by fallen on 16/10/28.
//
//

#import "_precompile.h"
#import "_base_net_command.h"

#if 0
typedef enum : NSUInteger {
    UploadImageType_Big = 1,
    UploadImageType_Small = 2,
} UploadImageType;

typedef enum : NSUInteger {
    UploadImageChannelType_Default = 0,
} UploadImageChannelType;

@interface GetUploadImageurlRequest : _BaseRequest

// 必要, 0:默认渠道
@property (nonatomic, assign) int32_t channel;

// 1：大图 2：小图
@property (nonatomic, assign) int32_t type;

@property (nonatomic, strong) NSString *uid;

@end

#pragma mark -

@interface GetUploadImageUrlResponse : _BaseResponse

@property (nonatomic, strong) NSString *info; // 图片的唯一UUID

@end

#pragma mark - 

@interface UploadImageRequest : _BaseUploadRequest

- (NSString *)buildUrl;

@end

#pragma mark -

@interface UploadImageResponse : _BaseResponse

@property (nonatomic, strong) NSString *info;

@end

#pragma mark -

@interface UploadHDImageResponse : _BaseResponse

@property (nonatomic, assign) int32_t errCode;

@property (nonatomic, strong) NSString *info;

@property (nonatomic, strong) NSString *originalImageUrl;

@property (nonatomic, strong) NSString *thumbnailImageUrl;

- (NSString *)mixedUrl; // 'thumbnailImageUrl'+','+'originalImageUrl'

@end
#endif
