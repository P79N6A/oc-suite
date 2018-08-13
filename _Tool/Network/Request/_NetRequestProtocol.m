//
//  _net_request_protocol.m
//  consumer
//
//  Created by fallen.ink on 10/2/16.
//
//

#import "_precompile.h"
#import "_foundation.h"
#import "_protocol.h"
#import "_net_request_protocol.h"
#import "_vendor_mantle.h"

@defs(_NetModelProtocol)

- (id<_NetModelProtocol>)this {
    return nil;
}

#pragma mark -

- (NSString *)requestUrl {
    if (self.this) {
        return self.this.requestUrl;
    }
    
    return nil;
}

- (NetRequestMethod)requestMethod {
    if (self.this) {
        return self.this.requestMethod;
    }
    
    return NetRequestMethod_Post;
}

- (NSString *)responseClassname {
    if (self.this) {
        return self.this.responseClassname;
    }
    
    return nil;
}

- (RequestSerializerType)requestSerializerType {
    if (self.this) {
        return self.this.requestSerializerType;
    }
    
    return RequestSerializerType_JSON;
}

- (NSDictionary *)requestHeaderFieldValueDictionary {
    if (self.this) {
        return [self.this.requestHeaderFieldValueDictionary mutableCopy];
    }
    
    return nil;
}

#pragma mark - cdn

- (BOOL)useCDN {
    if (self.this) {
        return self.this.useCDN;
    }
    
    return NO;
}

- (NSString *)cdnUrl {
    if (self.this) {
        return self.this.cdnUrl;
    }
    
    return nil;
}

- (NSString *)baseUrl {
    if (self.this) {
        return self.this.baseUrl;
    }
    
    return nil;
}

- (NSString *)buildUrl {
    if (self.this) {
        return self.buildUrl;
    }
    
    return nil;
}

#pragma mark - Cache

- (BOOL)useCache {
    if (self.this) {
        return self.this.useCache;
    }
    
    return NO;
}

#pragma mark -

- (NSString *)resumableDownloadPath {
    if (self.this) {
        return self.this.resumableDownloadPath;
    }
    
    return nil;
}

#pragma mark -

- (NetRequestPriority)requestPriority {
    if (self.this) {
        return self.this.requestPriority;
    }
    
    return NetRequestPriority_Default;
}

- (NSURLRequest *)customUrlRequest {
    if (self.this) {
        return self.this.customUrlRequest;
    }
    
    return nil;
}

- (NSArray *)requestAuthorizationHeaderFieldArray {
    if (self.this) {
        return self.this.requestAuthorizationHeaderFieldArray;
    }
    
    return nil;
}

#pragma mark - 序列化

- (NSDictionary *)requestParams { // 序列化器
    if (self.requestSerializerType == RequestSerializerType_HTTP) {
        return nil;
    } else if (self.requestSerializerType == RequestSerializerType_JSON) {
        if (self.this) {
            if (is_protocol_implemented(self.this, MTLJSONSerializing)) {
                return [MTLJSONAdapter JSONDictionaryFromModel:(id<MTLJSONSerializing>)self.this error:nil];
            }
        }
        
        return [MTLJSONAdapter JSONDictionaryFromModel:(id<MTLJSONSerializing>)self error:nil];
    }
    
    return nil;
}

- (id)modelableFromResponseData:(NSDictionary *)responseData error:(NSError **)error { // 反序列化器
    // object deserializing
    if (self.requestSerializerType == RequestSerializerType_HTTP) {
        return responseData;
    } else if (self.requestSerializerType == RequestSerializerType_JSON) {
        return [MTLJSONAdapter modelOfClass:classify([self responseClassname]) fromJSONDictionary:responseData error:error];
    }
    
    return nil;
}

@end
