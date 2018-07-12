//
//  ImageUploadRequest.m
//  consumer
//
//  Created by fallen on 16/10/28.
//
//

#import "ImageUploadApi.h"
#if 0
#import "_network.h"

@implementation GetUploadImageurlRequest

- (NSString *)requestUrl {
    return @"/imagesvc/getURL";
}

- (NetRequestMethod)requestMethod {
    return NetRequestMethod_Get;
}

- (NSString *)responseClassname {
    return stringify(GetUploadImageUrlResponse);
}

- (RequestSerializerType)requestSerializerType {
    return RequestSerializerType_JSON;
}

- (NSString *)baseUrl {
    return [_Network sharedInstance].config.imageUrl;
}

@end

#pragma mark -

@implementation GetUploadImageUrlResponse

@end

#pragma mark - 

@implementation UploadImageRequest

- (NSString *)requestUrl {
    return @"/imagesvc/uploadJson";
}

#pragma mark - public

- (NSString *)buildUrl {
    NSString *baseUrl = [_Network sharedInstance].config.imageUrl;
    return [NSString stringWithFormat:@"%@%@", baseUrl, self.requestUrl];
}

@end

#pragma mark -

@implementation UploadImageResponse

@end

@implementation UploadHDImageResponse

- (NSString *)mixedUrl {
    return [NSString stringWithFormat:@"%@,%@", self.thumbnailImageUrl, self.originalImageUrl];
}

@end

#endif
