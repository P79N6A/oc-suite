//
//  ALSRMStoreAppReceiptVerifier.m
//  RMStore
//
//  Created by Hermes on 10/15/13.
//  Copyright (c) 2013 Robot Media. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ALSRMStoreAppReceiptVerifier.h"
#import "ALSRMAppReceipt.h"

@implementation ALSRMStoreAppReceiptVerifier

- (BOOL)verifyTransaction:(SKPaymentTransaction*)transaction
                           success:(void (^)(void))successBlock
                           failure:(void (^)(NSError *error))failureBlock
{
#ifdef ALS_IAP_OPENSSL
    // yangzm 这里是本地认证，如果是正确的就返回了，如果有问题就进行刷新操作
    ALSRMAppReceipt *receipt = [ALSRMAppReceipt bundleReceipt];
    const BOOL verified = [self verifyTransaction:transaction inReceipt:receipt success:successBlock failure:nil]; // failureBlock is nil intentionally. See below.
    if (verified)
        return YES;

    // Apple recommends to refresh the receipt if validation fails on iOS
    [[ALSRMStore defaultStore] refreshReceiptOnSuccess:^{
        ALSRMAppReceipt *receipt = [ALSRMAppReceipt bundleReceipt];
        [self verifyTransaction:transaction inReceipt:receipt success:successBlock failure:failureBlock];
    } failure:^(NSError *error) {
        [self failWithBlock:failureBlock error:error];
    }];
    
    return NO;
#endif
    return YES;
}

- (BOOL)verifyAppReceipt
{
#ifdef ALS_IAP_OPENSSL
    ALSRMAppReceipt *receipt = [ALSRMAppReceipt bundleReceipt];
    return [self verifyAppReceipt:receipt];
#endif
    return YES;
}

#pragma mark - Properties

- (NSString*)bundleIdentifier
{
    if (!_bundleIdentifier)
    {
        return [NSBundle mainBundle].bundleIdentifier;
    }
    return _bundleIdentifier;
}

- (NSString*)bundleVersion
{
    if (!_bundleVersion)
    {
#if TARGET_OS_IPHONE
        return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
#else
        return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
#endif
    }
    return _bundleVersion;
}

#pragma mark - Private
#ifdef ALS_IAP_OPENSSL
- (BOOL)verifyAppReceipt:(ALSRMAppReceipt*)receipt
{
    if (!receipt) return NO;
    
    if (![receipt.bundleIdentifier isEqualToString:self.bundleIdentifier]) return NO;
    
    if (![receipt.appVersion isEqualToString:self.bundleVersion]) return NO;
    
    if (![receipt verifyReceiptHash]) return NO;

    return YES;
}

- (BOOL)verifyTransaction:(SKPaymentTransaction*)transaction
                inReceipt:(ALSRMAppReceipt*)receipt
                           success:(void (^)(void))successBlock
                           failure:(void (^)(NSError *error))failureBlock
{
    const BOOL receiptVerified = [self verifyAppReceipt:receipt];
    if (!receiptVerified)
    {
        [self failWithBlock:failureBlock message:NSLocalizedStringFromTable(@"The app receipt failed verification", @"RMStore", nil)];
        return NO;
    }
    SKPayment *payment = transaction.payment;
    const BOOL transactionVerified = [receipt containsInAppPurchaseOfProductIdentifier:payment.productIdentifier];
    if (!transactionVerified)
    {
        [self failWithBlock:failureBlock message:NSLocalizedStringFromTable(@"The app receipt does not contain the given product", @"RMStore", nil)];
        return NO;
    }
    if (successBlock)
    {
        successBlock();
    }
    return YES;
}
#endif

- (void)failWithBlock:(void (^)(NSError *error))failureBlock message:(NSString*)message
{
    NSError *error = [NSError errorWithDomain:ALSRMStoreErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : message}];
    [self failWithBlock:failureBlock error:error];
}

- (void)failWithBlock:(void (^)(NSError *error))failureBlock error:(NSError*)error
{
    if (failureBlock)
    {
        failureBlock(error);
    }
}

@end
