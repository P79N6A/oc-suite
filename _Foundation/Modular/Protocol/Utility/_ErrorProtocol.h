//
//  ALSErrorProtocol.h
//  wesg
//
//  Created by 7 on 22/11/2017.
//  Copyright © 2017 AliSports. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kErrorMessageKey    @"errorMessagekey"

#define kMachErrorDomain        NSMachErrorDomain
#define kOSStatusErrorDomain    NSOSStatusErrorDomain
#define kPOSIXErrorDomain       NSPOSIXErrorDomain
#define kCocoaErrorDomain       NSCocoaErrorDomain
#define kAlisportsErrorDomain   @"alisportsErrorDomain"

// FIXME:
// 1. 未处理本地化
@protocol _ErrorProtocol <NSObject>

@property (nonatomic, readonly) NSString *message;

+ (instancetype)withCode:(int64_t)code message:(NSString *)message;
+ (instancetype)withDomain:(NSString *)domain code:(int64_t)code message:(NSString *)message;

@optional

// 便利方法

- (void)showAsToast;
- (void)showAsAlert;

@end
