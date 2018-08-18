//
//  RMStore.h
//  RMStore
//
//  Created by Hermes Pique on 12/6/09.
//  Copyright (c) 2013 Robot Media SL (http://www.robotmedia.net)
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

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol ALSRMStoreContentDownloader;
@protocol ALSRMStoreReceiptVerifier;
@protocol ALSRMStoreTransactionPersistor;
@protocol ALSRMStoreObserver;

// 流程回调的block定义
typedef void (^StoreDownloadCanceled)( id pid, id anObject, NSDictionary *aUserInfo );
typedef void (^StoreDownloadFailed)( id pid,id anObject, NSDictionary *aUserInfo );
typedef void (^StoreDownloadFinished)( id pid, id anObject, NSDictionary *aUserInfo );
typedef void (^StoreDownloadPaused)( id pid, id anObject, NSDictionary *aUserInfo );
typedef void (^StoreDownloadUpdated)( id pid,id anObject, NSDictionary *aUserInfo );

typedef void (^StoreProductsRequestFailed)( id id_array, id anObject, NSDictionary *aUserInfo );
typedef void (^StoreProductsRequestFinished)( id id_array, id anObject, NSDictionary *aUserInfo );

typedef void (^StorePaymentTransactionDeferred)( id pid, id anObject, NSDictionary *aUserInfo );
typedef void (^StorePaymentTransactionFailed)( id pid, id anObject, NSDictionary *aUserInfo );
typedef void (^StorePaymentTransactionFinished)( id pid, id anObject, NSDictionary *aUserInfo );

typedef void (^StoreLocalVerifyFailed)(  id pid, NSData* data, NSString* receiptString );
typedef void (^StoreLocalVerifyFinished)( id pid, NSData* data, NSString* receiptString  );

typedef void (^StoreRefreshReceiptFailed)( id pid, id anObject, NSDictionary *aUserInfo );
typedef void (^StoreRefreshReceiptFinished)( id pid, id anObject, NSDictionary *aUserInfo );

typedef void (^StoreRestoreTransactionsFailed)( id pid, id anObject, NSDictionary *aUserInfo );
typedef void (^StoreRestoreTransactionsFinished)( id pid, id anObject, NSDictionary *aUserInfo );

typedef void (^RemoteVerifyProc)( id pid, NSData* data, NSString* receiptString, BOOL* bSucceed, NSError* error );
/** A StoreKit wrapper that adds blocks and notifications, plus optional receipt verification and purchase management.
 */

extern NSString *const ALSRMStoreErrorDomain;
extern NSInteger const ALSRMStoreErrorCodeDownloadCanceled;
extern NSInteger const ALSRMStoreErrorCodeUnknownProductIdentifier;
extern NSInteger const ALSRMStoreErrorCodeUnableToCompleteVerification;

@interface ALSRMStore : NSObject<SKPaymentTransactionObserver>
{
    
}
///---------------------------------------------
/// @name Getting the Store
///---------------------------------------------

/** Returns the singleton store instance.
 */
+ (ALSRMStore*)defaultStore;

#pragma mark StoreKit Wrapper
///---------------------------------------------
/// @name Calling StoreKit
///---------------------------------------------

/** Returns whether the user is allowed to make payments.
 */
+ (BOOL)canMakePayments;

/** Request payment of the product with the given product identifier.
 @param productIdentifier The identifier of the product whose payment will be requested.
 */
- (void)addPayment:(NSString*)productIdentifier;

/** Request payment of the product with the given product identifier. `successBlock` will be called if the payment is successful, `failureBlock` if it isn't.
 @param productIdentifier The identifier of the product whose payment will be requested.
 @param successBlock The block to be called if the payment is sucessful. Can be `nil`.
 @param failureBlock The block to be called if the payment fails or there isn't any product with the given identifier. Can be `nil`.
 */
- (void)addPayment:(NSString*)productIdentifier
           success:(void (^)(SKPaymentTransaction *transaction))successBlock
           failure:(void (^)(SKPaymentTransaction *transaction, NSError *error))failureBlock;

/** Request payment of the product with the given product identifier. `successBlock` will be called if the payment is successful, `failureBlock` if it isn't.
 @param productIdentifier The identifier of the product whose payment will be requested.
 @param userIdentifier An opaque identifier of the user’s account, if applicable. Can be `nil`.
 @param successBlock The block to be called if the payment is sucessful. Can be `nil`.
 @param failureBlock The block to be called if the payment fails or there isn't any product with the given identifier. Can be `nil`.
 @see [SKPayment applicationUsername]
 */
- (void)addPayment:(NSString*)productIdentifier
              user:(NSString*)userIdentifier
           success:(void (^)(SKPaymentTransaction *transaction))successBlock
           failure:(void (^)(SKPaymentTransaction *transaction, NSError *error))failureBlock __attribute__((availability(ios,introduced=7.0)));

/** Request localized information about a set of products from the Apple App Store.
 @param identifiers The set of product identifiers for the products you wish to retrieve information of.
 */
- (void)requestProducts:(NSSet*)identifiers;

/** Request localized information about a set of products from the Apple App Store. `successBlock` will be called if the products request is successful, `failureBlock` if it isn't.
 @param identifiers The set of product identifiers for the products you wish to retrieve information of.
 @param successBlock The block to be called if the products request is sucessful. Can be `nil`. It takes two parameters: `products`, an array of SKProducts, one product for each valid product identifier provided in the original request, and `invalidProductIdentifiers`, an array of product identifiers that were not recognized by the App Store.
 @param failureBlock The block to be called if the products request fails. Can be `nil`.
 */
- (void)requestProducts:(NSSet*)identifiers
                success:(void (^)(NSArray *products, NSArray *invalidProductIdentifiers))successBlock
                failure:(void (^)(NSError *error))failureBlock;

/** Request to restore previously completed purchases.
 */
- (void)restoreTransactions;

/** Request to restore previously completed purchases. `successBlock` will be called if the restore transactions request is successful, `failureBlock` if it isn't.
 @param successBlock The block to be called if the restore transactions request is sucessful. Can be `nil`.
 @param failureBlock The block to be called if the restore transactions request fails. Can be `nil`.
 */
- (void)restoreTransactionsOnSuccess:(void (^)(NSArray *transactions))successBlock
                             failure:(void (^)(NSError *error))failureBlock;


/** Request to restore previously completed purchases of a certain user. `successBlock` will be called if the restore transactions request is successful, `failureBlock` if it isn't.
 @param userIdentifier An opaque identifier of the user’s account.
 @param successBlock The block to be called if the restore transactions request is sucessful. Can be `nil`.
 @param failureBlock The block to be called if the restore transactions request fails. Can be `nil`.
 */
- (void)restoreTransactionsOfUser:(NSString*)userIdentifier
                        onSuccess:(void (^)(NSArray *transactions))successBlock
                          failure:(void (^)(NSError *error))failureBlock __attribute__((availability(ios,introduced=7.0)));

#pragma mark Receipt
///---------------------------------------------
/// @name Getting the receipt
///---------------------------------------------

/** Returns the url of the bundle’s App Store receipt, or nil if the receipt is missing.
 If this method returns `nil` you should refresh the receipt by calling `refreshReceipt`.
 @see refreshReceipt
 */
+ (NSURL*)receiptURL __attribute__((availability(ios,introduced=7.0)));

/** Request to refresh the App Store receipt in case the receipt is invalid or missing.
 */
- (void)refreshReceipt __attribute__((availability(ios,introduced=7.0)));

/** Request to refresh the App Store receipt in case the receipt is invalid or missing. `successBlock` will be called if the refresh receipt request is successful, `failureBlock` if it isn't.
 @param successBlock The block to be called if the refresh receipt request is sucessful. Can be `nil`.
 @param failureBlock The block to be called if the refresh receipt request fails. Can be `nil`.
 */
- (void)refreshReceiptOnSuccess:(void (^)(void))successBlock
                        failure:(void (^)(NSError *error))failureBlock __attribute__((availability(ios,introduced=7.0)));

///---------------------------------------------
/// yangzm 这里通过block回调数据到应用当中,现在实现了四种不同的流程进行回调处理
// 通过这几个方法就可以跟踪当前的支付流程当中进行到哪步出现问题。
// 查询商品
- (void)ProductRequestProc:(StoreProductsRequestFinished)onFinished failed:(StoreProductsRequestFailed)OnFailed;

// 进行支付
- (void)PaymentTransactionProc:(StorePaymentTransactionFinished)onFinished failed:(StorePaymentTransactionFailed)onFailed deferred:(StorePaymentTransactionDeferred)onDeferred;

// 在进行支付过程当中的处理回调block,下载文件的回调
- (void)DownloadProtoProc:(StoreDownloadFinished)onFinished
               cancel:(StoreDownloadCanceled)onCanceled
               pause:(StoreDownloadPaused)onPaused
               update:(StoreDownloadUpdated)onUpdated;

// 本地认证是否成功
- (void)LocalVerifyProc:(StoreLocalVerifyFinished)onFinished failed:(StoreLocalVerifyFailed)onFailed;

// 认证失败时，刷新操作是否成功
- (void)RefreshReceiptProc:(StoreRefreshReceiptFinished)onFinished failed:(StoreRefreshReceiptFailed)onFailed;

// 进行 SKPaymentTransactionStateRestored 非一次性产品恢复操作
- (void)RestoreTransactionsProc:(StoreRestoreTransactionsFinished)onFinished failed:(StoreRestoreTransactionsFailed)onFailed;

- (void)RemoteVerify:(RemoteVerifyProc)remoteVerify;
// 下边些是在进行in-app支付时用到的流程回调，在上边的四个函数进行了包装，有了这个过程就可以跟踪支付过程在哪里
// 存在问题，就可以对流程进行到不同的情况再进行分类，这样就可以处理所有出现的情况。
@property (copy, nonatomic) StoreDownloadCanceled storeDownloadCanceled;
@property (copy, nonatomic) StoreDownloadFailed storeDownloadFailed;
@property (copy, nonatomic) StoreDownloadFinished storeDownloadFinished;
@property (copy, nonatomic) StoreDownloadPaused storeDownloadPaused;
@property (copy, nonatomic) StoreDownloadUpdated storeDownloadUpdated;

@property (copy, nonatomic) StoreProductsRequestFailed storeProductsRequestFailed;
@property (copy, nonatomic) StoreProductsRequestFinished storeProductsRequestFinished;

@property (copy, nonatomic) StorePaymentTransactionDeferred storePaymentTransactionDeferred;
@property (copy, nonatomic) StorePaymentTransactionFailed storePaymentTransactionFailed;
@property (copy, nonatomic) StorePaymentTransactionFinished storePaymentTransactionFinished;

@property(copy, nonatomic) StoreLocalVerifyFailed storeLocalVerifyFailed;
@property(copy,nonatomic)  StoreLocalVerifyFinished storeLocalVerifyFinished;

@property (copy, nonatomic) StoreRefreshReceiptFailed storeRefreshReceiptFailed;
@property (copy, nonatomic) StoreRefreshReceiptFinished storeRefreshReceiptFinished;

@property (copy, nonatomic) StoreRestoreTransactionsFailed storeRestoreTransactionsFailed;
@property (copy, nonatomic) StoreRestoreTransactionsFinished storeRestoreTransactionsFinished;

@property(atomic,strong) NSString* product_id;
@property(nonatomic,strong)NSMutableDictionary *products;
@property(copy,nonatomic) RemoteVerifyProc remoteverify;
@property(atomic,assign)BOOL isLocalVerify;
/**
 The content downloader. Required to download product content from your own server.
 @discussion Hosted content from Apple’s server (SKDownload) is handled automatically. You don't need to provide a content downloader for it.
 */
@property (nonatomic, weak) id<ALSRMStoreContentDownloader> contentDownloader;

/** The receipt verifier. You can provide your own or use one of the reference implementations provided by the library.
 @see ALSRMStoreAppReceiptVerifier
 @see ALSRMStoreTransactionReceiptVerifier
 */
@property (nonatomic, weak) id<ALSRMStoreReceiptVerifier> receiptVerifier;

/**
 The transaction persistor. It is recommended to provide your own obfuscator if piracy is a concern. The store will use weak obfuscation via `NSKeyedArchiver` by default.
 @see ALSRMStoreKeychainPersistence
 @see RMStoreUserDefaultsPersistence
 */
@property (nonatomic, weak) id<ALSRMStoreTransactionPersistor> transactionPersistor;


#pragma mark Product management
///---------------------------------------------
/// @name Managing Products
///---------------------------------------------

- (SKProduct*)productForIdentifier:(NSString*)productIdentifier;

+ (NSString*)localizedPriceOfProduct:(SKProduct*)product;

#pragma mark Notifications
///---------------------------------------------
/// @name Managing Observers
///---------------------------------------------

/** Adds an observer to the store.
 Unlike `SKPaymentQueue`, it is not necessary to set an observer.
 @param observer The observer to add.
 */
- (void)addStoreObserver:(id<ALSRMStoreObserver>)observer;

/** Removes an observer from the store.
 @param observer The observer to remove.
 */
- (void)removeStoreObserver:(id<ALSRMStoreObserver>)observer;

@end

@protocol ALSRMStoreContentDownloader <NSObject>

/**
 Downloads the self-hosted content associated to the given transaction and calls the given success or failure block accordingly. Can also call the given progress block to notify progress.
 @param transaction The transaction whose associated content will be downloaded.
 @param successBlock Called if the download was successful. Must be called in the main queue.
 @param progressBlock Called to notify progress. Provides a number between 0.0 and 1.0, inclusive, where 0.0 means no data has been downloaded and 1.0 means all the data has been downloaded. Must be called in the main queue.
 @param failureBlock Called if the download failed. Must be called in the main queue.
 @discussion Hosted content from Apple’s server (@c SKDownload) is handled automatically by RMStore.
 */
- (void)downloadContentForTransaction:(SKPaymentTransaction*)transaction
                              success:(void (^)(void))successBlock
                             progress:(void (^)(float progress))progressBlock
                              failure:(void (^)(NSError *error))failureBlock;

@end

@protocol ALSRMStoreTransactionPersistor<NSObject>

- (void)persistTransaction:(SKPaymentTransaction*)transaction;

@end

@protocol ALSRMStoreReceiptVerifier <NSObject>

/** Verifies the given transaction and calls the given success or failure block accordingly.
 @param transaction The transaction to be verified.
 @param successBlock Called if the transaction passed verification. Must be called in the main queu.
 @param failureBlock Called if the transaction failed verification. If verification could not be completed (e.g., due to connection issues), then error must be of code ALSRMStoreErrorCodeUnableToCompleteVerification to prevent RMStore to finish the transaction. Must be called in the main queu.
 */
- (BOOL)verifyTransaction:(SKPaymentTransaction*)transaction
                  success:(void (^)(void))successBlock
                  failure:(void (^)(NSError *error))failureBlock;

@end

@protocol ALSRMStoreObserver<NSObject>
@optional

/**
 Tells the observer that a download has been canceled.
 @discussion Only for Apple-hosted downloads.
 */
- (void)storeDownloadCanceled:(NSNotification*)notification __attribute__((availability(ios,introduced=6.0)));

/**
 Tells the observer that a download has failed. Use @c storeError to get the cause.
 */
- (void)storeDownloadFailed:(NSNotification*)notification __attribute__((availability(ios,introduced=6.0)));

/**
 Tells the observer that a download has finished.
 */
- (void)storeDownloadFinished:(NSNotification*)notification __attribute__((availability(ios,introduced=6.0)));

/**
 Tells the observer that a download has been paused.
 @discussion Only for Apple-hosted downloads.
 */
- (void)storeDownloadPaused:(NSNotification*)notification __attribute__((availability(ios,introduced=6.0)));

/**
 Tells the observer that a download has been updated. Use @c downloadProgress to get the progress.
 */
- (void)storeDownloadUpdated:(NSNotification*)notification __attribute__((availability(ios,introduced=6.0)));

- (void)storePaymentTransactionDeferred:(NSNotification*)notification __attribute__((availability(ios,introduced=8.0)));
- (void)storePaymentTransactionFailed:(NSNotification*)notification;
- (void)storePaymentTransactionFinished:(NSNotification*)notification;
- (void)storeProductsRequestFailed:(NSNotification*)notification;
- (void)storeProductsRequestFinished:(NSNotification*)notification;
- (void)storeRefreshReceiptFailed:(NSNotification*)notification __attribute__((availability(ios,introduced=7.0)));
- (void)storeRefreshReceiptFinished:(NSNotification*)notification __attribute__((availability(ios,introduced=7.0)));
- (void)storeRestoreTransactionsFailed:(NSNotification*)notification;
- (void)storeRestoreTransactionsFinished:(NSNotification*)notification;

@end

/**
 Category on NSNotification to recover store data from userInfo without requiring to know the keys.
 */
@interface NSNotification(RMStore)

/**
 A value that indicates how much of the file has been downloaded.
 The value of this property is a floating point number between 0.0 and 1.0, inclusive, where 0.0 means no data has been downloaded and 1.0 means all the data has been downloaded. Typically, your app uses the value of this property to update a user interface element, such as a progress bar, that displays how much of the file has been downloaded.
 @discussion Corresponds to [SKDownload progress].
 @discussion Used in @c storeDownloadUpdated:.
 */
@property (nonatomic, readonly) float rm_downloadProgress;

/** Array of product identifiers that were not recognized by the App Store. Used in @c storeProductsRequestFinished:.
 */
@property (nonatomic, readonly) NSArray *rm_invalidProductIdentifiers;

/** Used in @c storeDownload*:, @c storePaymentTransactionFinished: and @c storePaymentTransactionFailed:.
 */
@property (nonatomic, readonly) NSString *rm_productIdentifier;

/** Array of SKProducts, one product for each valid product identifier provided in the corresponding request. Used in @c storeProductsRequestFinished:.
 */
@property (nonatomic, readonly) NSArray *rm_products;

/** Used in @c storeDownload*:.
 */
@property (nonatomic, readonly) SKDownload *rm_storeDownload __attribute__((availability(ios,introduced=6.0)));

/** Used in @c storeDownloadFailed:, @c storePaymentTransactionFailed:, @c storeProductsRequestFailed:, @c storeRefreshReceiptFailed: and @c storeRestoreTransactionsFailed:.
 */
@property (nonatomic, readonly) NSError *rm_storeError;

/** Used in @c storeDownload*:, @c storePaymentTransactionFinished: and in @c storePaymentTransactionFailed:.
 */
@property (nonatomic, readonly) SKPaymentTransaction *rm_transaction;

/** Used in @c storeRestoreTransactionsFinished:.
 */
@property (nonatomic, readonly) NSArray *rm_transactions;

@end
