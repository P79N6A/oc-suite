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

#import "ALSRMStore.h"
#import "DelegateToBlock.h"

NSString *const ALSRMStoreErrorDomain = @"net.robotmedia.store";
NSInteger const ALSRMStoreErrorCodeDownloadCanceled = 300;
NSInteger const ALSRMStoreErrorCodeUnknownProductIdentifier = 100;
NSInteger const ALSRMStoreErrorCodeUnableToCompleteVerification = 200;

static NSString* const ALSRMSKDownloadCanceled = @"ALSRMSKDownloadCanceled";
static NSString* const ALSRMSKDownloadFailed = @"ALSRMSKDownloadFailed";
static NSString* const ALSRMSKDownloadFinished = @"ALSRMSKDownloadFinished";
static NSString* const ALSRMSKDownloadPaused = @"ALSRMSKDownloadPaused";
static NSString* const ALSRMSKDownloadUpdated = @"ALSRMSKDownloadUpdated";
static NSString* const ALSRMSKPaymentTransactionDeferred = @"ALSRMSKPaymentTransactionDeferred";
static NSString* const ALSRMSKPaymentTransactionFailed = @"ALSRMSKPaymentTransactionFailed";
static NSString* const ALSRMSKPaymentTransactionFinished = @"ALSRMSKPaymentTransactionFinished";
static NSString* const ALSRMSKProductsRequestFailed = @"ALSRMSKProductsRequestFailed";
static NSString* const ALSRMSKProductsRequestFinished = @"ALSRMSKProductsRequestFinished";
static NSString* const ALSRMSKRefreshReceiptFailed = @"ALSRMSKRefreshReceiptFailed";
static NSString* const ALSRMSKRefreshReceiptFinished = @"ALSRMSKRefreshReceiptFinished";
static NSString* const ALSRMSKRestoreTransactionsFailed = @"ALSRMSKRestoreTransactionsFailed";
static NSString* const ALSRMSKRestoreTransactionsFinished = @"ALSRMSKRestoreTransactionsFinished";

static NSString* const ALSRMStoreNotificationInvalidProductIdentifiers = @"invalidProductIdentifiers";
static NSString* const ALSRMStoreNotificationDownloadProgress = @"downloadProgress";
static NSString* const ALSRMStoreNotificationProductIdentifier = @"productIdentifier";
static NSString* const ALSRMStoreNotificationProducts = @"products";
static NSString* const ALSRMStoreNotificationStoreDownload = @"storeDownload";
static NSString* const ALSRMStoreNotificationStoreError = @"storeError";
static NSString* const ALSRMStoreNotificationStoreReceipt = @"storeReceipt";
static NSString* const ALSRMStoreNotificationTransaction = @"transaction";
static NSString* const ALSRMStoreNotificationTransactions = @"transactions";

#if DEBUG
#define ALSRMStoreLog(...) NSLog(@"RMStore: %@", [NSString stringWithFormat:__VA_ARGS__]);
#else
#define ALSRMStoreLog(...)
#endif

typedef void (^RMSKPaymentTransactionFailureBlock)(SKPaymentTransaction *transaction, NSError *error);
typedef void (^RMSKPaymentTransactionSuccessBlock)(SKPaymentTransaction *transaction);
typedef void (^RMSKProductsRequestFailureBlock)(NSError *error);
typedef void (^RMSKProductsRequestSuccessBlock)(NSArray *products, NSArray *invalidIdentifiers);
typedef void (^RMStoreFailureBlock)(NSError *error);
typedef void (^RMStoreSuccessBlock)(void);

@implementation NSNotification(RMStore)

- (float)rm_downloadProgress
{
    return [self.userInfo[ALSRMStoreNotificationDownloadProgress] floatValue];
}

- (NSArray*)rm_invalidProductIdentifiers
{
    return (self.userInfo)[ALSRMStoreNotificationInvalidProductIdentifiers];
}

- (NSString*)rm_productIdentifier
{
    return (self.userInfo)[ALSRMStoreNotificationProductIdentifier];
}

- (NSArray*)rm_products
{
    return (self.userInfo)[ALSRMStoreNotificationProducts];
}

- (SKDownload*)rm_storeDownload
{
    return (self.userInfo)[ALSRMStoreNotificationStoreDownload];
}

- (NSError*)rm_storeError
{
    return (self.userInfo)[ALSRMStoreNotificationStoreError];
}

- (SKPaymentTransaction*)rm_transaction
{
    return (self.userInfo)[ALSRMStoreNotificationTransaction];
}

- (NSArray*)rm_transactions {
    return (self.userInfo)[ALSRMStoreNotificationTransactions];
}

@end

@interface ALSRMProductsRequestDelegate : NSObject<SKProductsRequestDelegate>

@property (nonatomic, strong) RMSKProductsRequestSuccessBlock successBlock;
@property (nonatomic, strong) RMSKProductsRequestFailureBlock failureBlock;
@property (nonatomic, weak) ALSRMStore *store;

@end

@interface ALSRMAddPaymentParameters : NSObject

@property (nonatomic, strong) RMSKPaymentTransactionSuccessBlock successBlock;
@property (nonatomic, strong) RMSKPaymentTransactionFailureBlock failureBlock;

@end

@implementation ALSRMAddPaymentParameters

@end

@interface ALSRMStore() <SKRequestDelegate>

@end

@implementation ALSRMStore {
    NSMutableDictionary *_addPaymentParameters; // HACK: We use a dictionary of product identifiers because the returned SKPayment is different from the one we add to the queue. Bad Apple.
    NSMutableSet *_productsRequestDelegates;
    
    NSMutableArray *_restoredTransactions;
    
    NSInteger _pendingRestoredTransactionsCount;
    BOOL _restoredCompletedTransactionsFinished;
    
    SKReceiptRefreshRequest *_refreshReceiptRequest;
    void (^_refreshReceiptFailureBlock)(NSError* error);
    void (^_refreshReceiptSuccessBlock)(void);
    
    void (^_restoreTransactionsFailureBlock)(NSError* error);
    void (^_restoreTransactionsSuccessBlock)(NSArray* transactions);
}

- (instancetype) init
{
    if (self = [super init])
    {
        _addPaymentParameters = [NSMutableDictionary dictionary];
        _products = [NSMutableDictionary dictionary];
        _productsRequestDelegates = [NSMutableSet set];
        _restoredTransactions = [NSMutableArray array];
        _isLocalVerify = NO;
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

// 查询商品
- (void)ProductRequestProc:(StoreProductsRequestFinished)onFinished failed:(StoreProductsRequestFailed)OnFailed
{
    self.storeProductsRequestFailed = OnFailed;
    self.storeProductsRequestFinished = onFinished;
}

// 进行支付
- (void)PaymentTransactionProc:(StorePaymentTransactionFinished)onFinished failed:(StorePaymentTransactionFailed)onFailed deferred:(StorePaymentTransactionDeferred)onDeferred
{
    self.storePaymentTransactionFailed = onFailed;
    self.storePaymentTransactionDeferred = onDeferred;
    self.storePaymentTransactionFinished = onFinished;
}

// 本地认证是否成功
- (void)LocalVerifyProc:(StoreLocalVerifyFinished)onFinished failed:(StoreLocalVerifyFailed)onFailed
{
    self.storeLocalVerifyFailed = onFailed;
    self.storeLocalVerifyFinished = onFinished;
}

// 认证失败时，刷新操作是否成功
- (void)RefreshReceiptProc:(StoreRefreshReceiptFinished)onFinished failed:(StoreRefreshReceiptFailed)onFailed
{
    self.storeRefreshReceiptFailed = onFailed;
    self.storeRefreshReceiptFinished = onFinished;
}

// 在进行支付过程当中的处理回调block,下载文件的回调
- (void)DownloadProtoProc:(StoreDownloadFinished)onFinished
               cancel:(StoreDownloadCanceled)onCanceled
                pause:(StoreDownloadPaused)onPaused
               update:(StoreDownloadUpdated)onUpdated
{
    self.storeDownloadFinished = onFinished;
    self.storeDownloadCanceled = onCanceled;
    self.storeDownloadPaused = onPaused;
    self.storeDownloadUpdated = onUpdated;
}

// 进行 SKPaymentTransactionStateRestored 非一次性产品恢复操作
- (void)RestoreTransactionsProc:(StoreRestoreTransactionsFinished)onFinished failed:(StoreRestoreTransactionsFailed)onFailed
{
    self.storeRestoreTransactionsFailed = onFailed;
    self.storeRestoreTransactionsFinished = onFinished;
}

- (void)RemoteVerify:(RemoteVerifyProc)remoteVerify
{
    self.remoteverify =  remoteVerify;
}

+ (ALSRMStore *)defaultStore
{
    static ALSRMStore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

#pragma mark StoreKit wrapper

+ (BOOL)canMakePayments
{
    return [SKPaymentQueue canMakePayments];
}

- (void)addPayment:(NSString*)productIdentifier
{
    [self addPayment:productIdentifier success:nil failure:nil];
}

- (void)addPayment:(NSString*)productIdentifier
           success:(void (^)(SKPaymentTransaction *transaction))successBlock
           failure:(void (^)(SKPaymentTransaction *transaction, NSError *error))failureBlock
{
    [self addPayment:productIdentifier user:nil success:successBlock failure:failureBlock];
}

- (void)addPayment:(NSString*)productIdentifier
              user:(NSString*)userIdentifier
           success:(void (^)(SKPaymentTransaction *transaction))successBlock
           failure:(void (^)(SKPaymentTransaction *transaction, NSError *error))failureBlock
{
    //////////////////////////////////////////////////////////////////////
     SKMutablePayment *payment;
    // 如果先调用了查询就使用这个创建
    if ( _products.count > 0 ){
        SKProduct *product = [self productForIdentifier:productIdentifier];
        if (product == nil)
        {
            ALSRMStoreLog(@"unknown product id %@", productIdentifier)
            if (failureBlock != nil)
            {
                NSError *error = [NSError errorWithDomain:ALSRMStoreErrorDomain code:ALSRMStoreErrorCodeUnknownProductIdentifier userInfo:@{NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"Unknown product identifier", @"ALSRMStore", @"Error description")}];
                failureBlock(nil, error);
            }
            return;
        }
        payment = [SKMutablePayment paymentWithProduct:product];
    }
    else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        //  根据identifier创建
        payment = [SKMutablePayment paymentWithProductIdentifier:productIdentifier];
#pragma clang diagnostic pop
    }
    //////////////////////////////////////////////////////////////////////
    
    if ([payment respondsToSelector:@selector(setApplicationUsername:)])
    {
        payment.applicationUsername = userIdentifier;
    }
    
    ALSRMAddPaymentParameters *parameters = [[ALSRMAddPaymentParameters alloc] init];
    parameters.successBlock = successBlock;
    parameters.failureBlock = failureBlock;
    _addPaymentParameters[productIdentifier] = parameters;
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)requestProducts:(NSSet*)identifiers
{
    [self requestProducts:identifiers success:nil failure:nil];
}

- (void)requestProducts:(NSSet*)identifiers
                success:(RMSKProductsRequestSuccessBlock)successBlock
                failure:(RMSKProductsRequestFailureBlock)failureBlock
{
    ALSRMProductsRequestDelegate *delegate = [[ALSRMProductsRequestDelegate alloc] init];
    delegate.store = self;
    delegate.successBlock = successBlock;
    delegate.failureBlock = failureBlock;
    [_productsRequestDelegates addObject:delegate];
 
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
	productsRequest.delegate = delegate;
    
    [productsRequest start];
}

- (void)restoreTransactions
{
    [self restoreTransactionsOnSuccess:nil failure:nil];
}

- (void)restoreTransactionsOnSuccess:(void (^)(NSArray *transactions))successBlock
                             failure:(void (^)(NSError *error))failureBlock
{
    _restoredCompletedTransactionsFinished = NO;
    _pendingRestoredTransactionsCount = 0;
    _restoredTransactions = [NSMutableArray array];
    _restoreTransactionsSuccessBlock = successBlock;
    _restoreTransactionsFailureBlock = failureBlock;
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)restoreTransactionsOfUser:(NSString*)userIdentifier
                        onSuccess:(void (^)(NSArray *transactions))successBlock
                          failure:(void (^)(NSError *error))failureBlock
{
    NSAssert([[SKPaymentQueue defaultQueue] respondsToSelector:@selector(restoreCompletedTransactionsWithApplicationUsername:)], @"restoreCompletedTransactionsWithApplicationUsername: not supported in this iOS version. Use restoreTransactionsOnSuccess:failure: instead.");
    _restoredCompletedTransactionsFinished = NO;
    _pendingRestoredTransactionsCount = 0;
    _restoreTransactionsSuccessBlock = successBlock;
    _restoreTransactionsFailureBlock = failureBlock;
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactionsWithApplicationUsername:userIdentifier];
}

#pragma mark Receipt

+ (NSURL*)receiptURL
{
    // The general best practice of weak linking using the respondsToSelector: method cannot be used here. Prior to iOS 7, the method was implemented as private API, but that implementation called the doesNotRecognizeSelector: method.
    NSAssert(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1, @"appStoreReceiptURL not supported in this iOS version.");
    NSURL *url = [NSBundle mainBundle].appStoreReceiptURL;
    return url;
}

- (void)refreshReceipt
{
    [self refreshReceiptOnSuccess:nil failure:nil];
}

- (void)refreshReceiptOnSuccess:(RMStoreSuccessBlock)successBlock
                        failure:(RMStoreFailureBlock)failureBlock
{
    _refreshReceiptFailureBlock = failureBlock;
    _refreshReceiptSuccessBlock = successBlock;
    _refreshReceiptRequest = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:@{}];
    _refreshReceiptRequest.delegate = self;
    [_refreshReceiptRequest start];
}

#pragma mark Product management

- (SKProduct*)productForIdentifier:(NSString*)productIdentifier
{
    return _products[productIdentifier];
}

+ (NSString*)localizedPriceOfProduct:(SKProduct*)product
{
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
	numberFormatter.locale = product.priceLocale;
	NSString *formattedString = [numberFormatter stringFromNumber:product.price];
	return formattedString;
}

#pragma mark Observers

- (void)addStoreObserver:(id<ALSRMStoreObserver>)observer
{
    [self addStoreObserver:observer selector:@selector(storeDownloadCanceled:) notificationName:ALSRMSKDownloadCanceled];
    [self addStoreObserver:observer selector:@selector(storeDownloadFailed:) notificationName:ALSRMSKDownloadFailed];
    [self addStoreObserver:observer selector:@selector(storeDownloadFinished:) notificationName:ALSRMSKDownloadFinished];
    [self addStoreObserver:observer selector:@selector(storeDownloadPaused:) notificationName:ALSRMSKDownloadPaused];
    [self addStoreObserver:observer selector:@selector(storeDownloadUpdated:) notificationName:ALSRMSKDownloadUpdated];
    [self addStoreObserver:observer selector:@selector(storeProductsRequestFailed:) notificationName:ALSRMSKProductsRequestFailed];
    [self addStoreObserver:observer selector:@selector(storeProductsRequestFinished:) notificationName:ALSRMSKProductsRequestFinished];
    [self addStoreObserver:observer selector:@selector(storePaymentTransactionDeferred:) notificationName:ALSRMSKPaymentTransactionDeferred];
    [self addStoreObserver:observer selector:@selector(storePaymentTransactionFailed:) notificationName:ALSRMSKPaymentTransactionFailed];
    [self addStoreObserver:observer selector:@selector(storePaymentTransactionFinished:) notificationName:ALSRMSKPaymentTransactionFinished];
    [self addStoreObserver:observer selector:@selector(storeRefreshReceiptFailed:) notificationName:ALSRMSKRefreshReceiptFailed];
    [self addStoreObserver:observer selector:@selector(storeRefreshReceiptFinished:) notificationName:ALSRMSKRefreshReceiptFinished];
    [self addStoreObserver:observer selector:@selector(storeRestoreTransactionsFailed:) notificationName:ALSRMSKRestoreTransactionsFailed];
    [self addStoreObserver:observer selector:@selector(storeRestoreTransactionsFinished:) notificationName:ALSRMSKRestoreTransactionsFinished];
}

- (void)removeStoreObserver:(id<ALSRMStoreObserver>)observer
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:ALSRMSKDownloadCanceled object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:ALSRMSKDownloadFailed object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:ALSRMSKDownloadFinished object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:ALSRMSKDownloadPaused object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:ALSRMSKDownloadUpdated object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:ALSRMSKProductsRequestFailed object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:ALSRMSKProductsRequestFinished object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:ALSRMSKPaymentTransactionDeferred object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:ALSRMSKPaymentTransactionFailed object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:ALSRMSKPaymentTransactionFinished object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:ALSRMSKRefreshReceiptFailed object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:ALSRMSKRefreshReceiptFinished object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:ALSRMSKRestoreTransactionsFailed object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:ALSRMSKRestoreTransactionsFinished object:self];
}

// Private

- (void)addStoreObserver:(id<ALSRMStoreObserver>)observer selector:(SEL)aSelector notificationName:(NSString*)notificationName
{
    if ([observer respondsToSelector:aSelector])
    {
        [[NSNotificationCenter defaultCenter] addObserver:observer selector:aSelector name:notificationName object:self];
    }
}

#pragma mark SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self didPurchaseTransaction:transaction queue:queue];
                break;
            case SKPaymentTransactionStateFailed:
                [self didFailTransaction:transaction queue:queue error:transaction.error];
                break;
            case SKPaymentTransactionStateRestored:
                [self didRestoreTransaction:transaction queue:queue];
                break;
            case SKPaymentTransactionStateDeferred:
                [self didDeferTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    ALSRMStoreLog(@"restore transactions finished");
    _restoredCompletedTransactionsFinished = YES;
    
    [self notifyRestoreTransactionFinishedIfApplicableAfterTransaction:nil];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    ALSRMStoreLog(@"restored transactions failed with error %@", error.debugDescription);
    if (_restoreTransactionsFailureBlock != nil)
    {
        _restoreTransactionsFailureBlock(error);
        _restoreTransactionsFailureBlock = nil;
    }
    NSDictionary *userInfo = nil;
    if (error)
    { // error might be nil (e.g., on airplane mode)
        userInfo = @{ALSRMStoreNotificationStoreError: error};
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ALSRMSKRestoreTransactionsFailed object:self userInfo:userInfo];
    if ( self.storeRestoreTransactionsFailed )
        self.storeRestoreTransactionsFailed( nil,self, userInfo);
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
    for (SKDownload *download in downloads)
    {
        switch (download.downloadState)
        {
            case SKDownloadStateActive:
                [self didUpdateDownload:download queue:queue];
                break;
            case SKDownloadStateCancelled:
                [self didCancelDownload:download queue:queue];
                break;
            case SKDownloadStateFailed:
                [self didFailDownload:download queue:queue];
                break;
            case SKDownloadStateFinished:
                [self didFinishDownload:download queue:queue];
                break;
            case SKDownloadStatePaused:
                [self didPauseDownload:download queue:queue];
                break;
            case SKDownloadStateWaiting:
                // Do nothing
                break;
        }
    }
}

#pragma mark Download State

- (void)didCancelDownload:(SKDownload*)download queue:(SKPaymentQueue*)queue
{
    SKPaymentTransaction *transaction = download.transaction;
    ALSRMStoreLog(@"download %@ for product %@ canceled", download.contentIdentifier, download.transaction.payment.productIdentifier);

    [self postNotificationWithName:ALSRMSKDownloadCanceled download:download userInfoExtras:nil];
    if ( self.storeDownloadCanceled ){
        self.storeDownloadCanceled( download.transaction.payment.productIdentifier,download, nil );
    }

    NSError *error = [NSError errorWithDomain:ALSRMStoreErrorDomain code:ALSRMStoreErrorCodeDownloadCanceled userInfo:@{NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"Download canceled", @"ALSRMStore", @"Error description")}];

    const BOOL hasPendingDownloads = [self.class hasPendingDownloadsInTransaction:transaction];
    if (!hasPendingDownloads)
    {
        [self didFailTransaction:transaction queue:queue error:error];
    }
}

- (void)didFailDownload:(SKDownload*)download queue:(SKPaymentQueue*)queue
{
    NSError *error = download.error;
    SKPaymentTransaction *transaction = download.transaction;
    ALSRMStoreLog(@"download %@ for product %@ failed with error %@", download.contentIdentifier, transaction.payment.productIdentifier, error.debugDescription);

    NSDictionary *extras = error ? @{ALSRMStoreNotificationStoreError : error} : nil;
    [self postNotificationWithName:ALSRMSKDownloadFailed download:download userInfoExtras:extras];
    if ( self.storeDownloadFailed ){
        self.storeDownloadFailed( transaction.payment.productIdentifier,download, extras );
    }
    
    const BOOL hasPendingDownloads = [self.class hasPendingDownloadsInTransaction:transaction];
    if (!hasPendingDownloads)
    {
        [self didFailTransaction:transaction queue:queue error:error];
    }
}

- (void)didFinishDownload:(SKDownload*)download queue:(SKPaymentQueue*)queue
{
    SKPaymentTransaction *transaction = download.transaction;
    ALSRMStoreLog(@"download %@ for product %@ finished", download.contentIdentifier, transaction.payment.productIdentifier);
    
    [self postNotificationWithName:ALSRMSKDownloadFinished download:download userInfoExtras:nil];
    if ( self.storeDownloadFinished ){
        self.storeDownloadFinished( transaction.payment.productIdentifier,download, nil );
    }
    
    const BOOL hasPendingDownloads = [self.class hasPendingDownloadsInTransaction:transaction];
    if (!hasPendingDownloads)
    {
        [self finishTransaction:download.transaction queue:queue];
    }
}

- (void)didPauseDownload:(SKDownload*)download queue:(SKPaymentQueue*)queue
{
    ALSRMStoreLog(@"download %@ for product %@ paused", download.contentIdentifier, download.transaction.payment.productIdentifier);
    [self postNotificationWithName:ALSRMSKDownloadPaused download:download userInfoExtras:nil];
    SKPaymentTransaction *transaction = download.transaction;
    if ( self.storeDownloadPaused && transaction )
        self.storeDownloadPaused( transaction.payment.productIdentifier,download, nil );
}

- (void)didUpdateDownload:(SKDownload*)download queue:(SKPaymentQueue*)queue
{
    ALSRMStoreLog(@"download %@ for product %@ updated", download.contentIdentifier, download.transaction.payment.productIdentifier);
    NSDictionary *extras = @{ALSRMStoreNotificationDownloadProgress : @(download.progress)};
    [self postNotificationWithName:ALSRMSKDownloadUpdated download:download userInfoExtras:extras];
    SKPaymentTransaction *transaction = download.transaction;
    if ( self.storeDownloadUpdated && transaction )
        self.storeDownloadUpdated( transaction.payment.productIdentifier,download, extras );
}

+ (BOOL)hasPendingDownloadsInTransaction:(SKPaymentTransaction*)transaction
{
    for (SKDownload *download in transaction.downloads)
    {
        switch (download.downloadState)
        {
            case SKDownloadStateActive:
            case SKDownloadStatePaused:
            case SKDownloadStateWaiting:
                return YES;
            case SKDownloadStateCancelled:
            case SKDownloadStateFailed:
            case SKDownloadStateFinished:
                continue;
        }
    }
    return NO;
}

#pragma mark Transaction State

- (void)didPurchaseTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue*)queue
{
    ALSRMStoreLog(@"transaction purchased with product %@", transaction.payment.productIdentifier);
    // 关闭交易
    [self finishTransaction:transaction queue:queue];
    
    if (self.receiptVerifier != nil)
    {
        // yangzm 这里增加默认不进行本地认证
        if ( _isLocalVerify ){
            BOOL is_local_verifier_ok = [self.receiptVerifier verifyTransaction:transaction success:^{
                [self didVerifyTransaction:transaction queue:queue];
            } failure:^(NSError *error) {
                [self didFailTransaction:transaction queue:queue error:error];
            }];
            
            // yangzm 本地认证是否成功
            NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
            NSData* userInfo = [transaction.payment.applicationUsername dataUsingEncoding:NSUTF8StringEncoding];
           
            NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
            NSString *receiptStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
            
            if ( is_local_verifier_ok ){
                if ( self.storeLocalVerifyFinished ){
                    self.storeLocalVerifyFinished( transaction.transactionIdentifier, userInfo, receiptStr );
                }
            }
            else{
                if ( self.storeDownloadFailed ){
                    self.storeLocalVerifyFailed( transaction.transactionIdentifier, userInfo, receiptStr  );
                }
            }
        }
        else{
            // yangzm 本地认证是否成功
            NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
            NSData* userInfo = [transaction.payment.applicationUsername dataUsingEncoding:NSUTF8StringEncoding];
            
            NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
            NSString *receiptStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
            
            BOOL isok = NO;
            if ( self.remoteverify ){
                self.remoteverify( transaction.transactionIdentifier, userInfo, receiptStr,&isok, nil );
            }
            
            if ( isok ){
                if ( self.storeLocalVerifyFinished ){
                    self.storeLocalVerifyFinished( transaction.transactionIdentifier, userInfo, receiptStr );
                }
            }
            else{
                if ( self.storeDownloadFailed ){
                    self.storeLocalVerifyFailed( transaction.transactionIdentifier, userInfo, receiptStr  );
                }
            }
            
        }
    }
    else
    {
        ALSRMStoreLog(@"WARNING: no receipt verification");
        [self didVerifyTransaction:transaction queue:queue];
    }
}

- (void)didFailTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue*)queue error:(NSError*)error
{
    SKPayment *payment = transaction.payment;
	NSString* productIdentifier = payment.productIdentifier;
    ALSRMStoreLog(@"transaction failed with product %@ and error %@", productIdentifier, error.debugDescription);
    
    if (error.code != ALSRMStoreErrorCodeUnableToCompleteVerification)
    { // If we were unable to complete the verification we want StoreKit to keep reminding us of the transaction
        [queue finishTransaction:transaction];
    }
    
    BOOL isok = NO;
    if ( self.remoteverify ){
        NSData* userinfo = [transaction.payment.applicationUsername dataUsingEncoding:NSUTF8StringEncoding];
        self.remoteverify( transaction.transactionIdentifier, userinfo, nil, &isok, error );
    }
    
    ALSRMAddPaymentParameters *parameters = [self popAddPaymentParametersForIdentifier:productIdentifier];
    if (parameters.failureBlock != nil)
    {
        parameters.failureBlock(transaction, error);
    }
    
    NSDictionary *extras = error ? @{ALSRMStoreNotificationStoreError : error} : nil;
    [self postNotificationWithName:ALSRMSKPaymentTransactionFailed transaction:transaction userInfoExtras:extras];
    if ( self.storePaymentTransactionFailed )
        self.storePaymentTransactionFailed( productIdentifier,transaction, extras );
    
    if (transaction.transactionState == SKPaymentTransactionStateRestored)
    {
        [self notifyRestoreTransactionFinishedIfApplicableAfterTransaction:transaction];
    }
}

- (void)didRestoreTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue*)queue
{
    ALSRMStoreLog(@"transaction restored with product %@", transaction.originalTransaction.payment.productIdentifier);
    
    _pendingRestoredTransactionsCount++;
    if (self.receiptVerifier != nil)
    {
        [self.receiptVerifier verifyTransaction:transaction success:^{
            [self didVerifyTransaction:transaction queue:queue];
        } failure:^(NSError *error) {
            [self didFailTransaction:transaction queue:queue error:error];
        }];
    }
    else
    {
        ALSRMStoreLog(@"WARNING: no receipt verification");
        [self didVerifyTransaction:transaction queue:queue];
    }
}

- (void)didDeferTransaction:(SKPaymentTransaction *)transaction
{
    [self postNotificationWithName:ALSRMSKPaymentTransactionDeferred transaction:transaction userInfoExtras:nil];
    if ( self.storePaymentTransactionDeferred )
        self.storePaymentTransactionDeferred( transaction.payment.productIdentifier,transaction, nil );
}

- (void)didVerifyTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue*)queue
{
    if (self.contentDownloader != nil)
    {
        [self.contentDownloader downloadContentForTransaction:transaction success:^{
            [self postNotificationWithName:ALSRMSKDownloadFinished transaction:transaction userInfoExtras:nil];
            if ( self.storeDownloadFinished )
                self.storeDownloadFinished( transaction.payment.productIdentifier,transaction, nil );
            [self didDownloadSelfHostedContentForTransaction:transaction queue:queue];
        } progress:^(float progress) {
            NSDictionary *extras = @{ALSRMStoreNotificationDownloadProgress : @(progress)};
            [self postNotificationWithName:ALSRMSKDownloadUpdated transaction:transaction userInfoExtras:extras];
            if ( self.storeDownloadUpdated )
                self.storeDownloadUpdated( transaction.payment.productIdentifier,transaction, extras );
        } failure:^(NSError *error) {
            NSDictionary *extras = error ? @{ALSRMStoreNotificationStoreError : error} : nil;
            [self postNotificationWithName:ALSRMSKDownloadFailed transaction:transaction userInfoExtras:extras];
            if ( self.storeDownloadFailed )
                self.storeDownloadFailed( transaction.payment.productIdentifier,transaction, extras );
            [self didFailTransaction:transaction queue:queue error:error];
        }];
    }
    else
    {
        [self didDownloadSelfHostedContentForTransaction:transaction queue:queue];
    }
}

- (void)didDownloadSelfHostedContentForTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue*)queue
{
    NSArray *downloads = [transaction respondsToSelector:@selector(downloads)] ? transaction.downloads : @[];
    if (downloads.count > 0)
    {
        ALSRMStoreLog(@"starting downloads for product %@ started", transaction.payment.productIdentifier);
        [queue startDownloads:downloads];
    }
    else
    {
        [self finishTransaction:transaction queue:queue];
    }
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue*)queue
{
    SKPayment *payment = transaction.payment;
	NSString* productIdentifier = payment.productIdentifier;
    [queue finishTransaction:transaction];
    [self.transactionPersistor persistTransaction:transaction];
    
    ALSRMAddPaymentParameters *wrapper = [self popAddPaymentParametersForIdentifier:productIdentifier];
    if (wrapper.successBlock != nil)
    {
        wrapper.successBlock(transaction);
    }
    
    [self postNotificationWithName:ALSRMSKPaymentTransactionFinished transaction:transaction userInfoExtras:nil];
    if ( self.storePaymentTransactionFinished )
        self.storePaymentTransactionFinished( transaction.payment.productIdentifier,transaction, nil );
    
    if (transaction.transactionState == SKPaymentTransactionStateRestored)
    {
        [self notifyRestoreTransactionFinishedIfApplicableAfterTransaction:transaction];
    }
}

- (void)notifyRestoreTransactionFinishedIfApplicableAfterTransaction:(SKPaymentTransaction*)transaction
{
    if (transaction != nil)
    {
        [_restoredTransactions addObject:transaction];
        _pendingRestoredTransactionsCount--;
    }
    if (_restoredCompletedTransactionsFinished && _pendingRestoredTransactionsCount == 0)
    { // Wait until all restored transations have been verified
        NSArray *restoredTransactions = [_restoredTransactions copy];
        if (_restoreTransactionsSuccessBlock != nil)
        {
            _restoreTransactionsSuccessBlock(restoredTransactions);
            _restoreTransactionsSuccessBlock = nil;
        }
        NSDictionary *userInfo = @{ ALSRMStoreNotificationTransactions : restoredTransactions };
        [[NSNotificationCenter defaultCenter] postNotificationName:ALSRMSKRestoreTransactionsFinished object:self userInfo:userInfo];
        
        if ( self.storeRestoreTransactionsFinished )
            self.storeRestoreTransactionsFinished( transaction.payment.productIdentifier,self, userInfo );
    }
}

- (ALSRMAddPaymentParameters*)popAddPaymentParametersForIdentifier:(NSString*)identifier
{
    ALSRMAddPaymentParameters *parameters = _addPaymentParameters[identifier];
    [_addPaymentParameters removeObjectForKey:identifier];
    return parameters;
}

#pragma mark SKRequestDelegate
- (void)requestDidFinish:(SKRequest *)request
{
    ALSRMStoreLog(@"refresh receipt finished");
    _refreshReceiptRequest = nil;
    if (_refreshReceiptSuccessBlock)
    {
        _refreshReceiptSuccessBlock();
        _refreshReceiptSuccessBlock = nil;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ALSRMSKRefreshReceiptFinished object:self];
    if ( self.storeRefreshReceiptFinished )
        self.storeRefreshReceiptFinished( nil,self, nil );
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    ALSRMStoreLog(@"refresh receipt failed with error %@", error.debugDescription);
    _refreshReceiptRequest = nil;
    if (_refreshReceiptFailureBlock)
    {
        _refreshReceiptFailureBlock(error);
        _refreshReceiptFailureBlock = nil;
    }
    NSDictionary *userInfo = nil;
    if (error)
    { // error might be nil (e.g., on airplane mode)
        userInfo = @{ALSRMStoreNotificationStoreError: error};
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ALSRMSKRefreshReceiptFailed object:self userInfo:userInfo];
    if ( self.storeRefreshReceiptFailed)
        self.storeRefreshReceiptFailed( nil,self, userInfo );
}

#pragma mark Private

- (void)addProduct:(SKProduct*)product
{
    _products[product.productIdentifier] = product;    
}

- (void)postNotificationWithName:(NSString*)notificationName download:(SKDownload*)download userInfoExtras:(NSDictionary*)extras
{
    NSMutableDictionary *mutableExtras = extras ? [NSMutableDictionary dictionaryWithDictionary:extras] : [NSMutableDictionary dictionary];
    mutableExtras[ALSRMStoreNotificationStoreDownload] = download;
    [self postNotificationWithName:notificationName transaction:download.transaction userInfoExtras:mutableExtras];
}

- (void)postNotificationWithName:(NSString*)notificationName transaction:(SKPaymentTransaction*)transaction userInfoExtras:(NSDictionary*)extras
{
    NSString *productIdentifier = transaction.payment.productIdentifier;
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[ALSRMStoreNotificationTransaction] = transaction;
    userInfo[ALSRMStoreNotificationProductIdentifier] = productIdentifier;
    if (extras)
    {
        [userInfo addEntriesFromDictionary:extras];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:userInfo];
}

- (void)removeProductsRequestDelegate:(ALSRMProductsRequestDelegate*)delegate
{
    [_productsRequestDelegates removeObject:delegate];
}

@end

@implementation ALSRMProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    ALSRMStoreLog(@"products request received response");
    NSArray *products = [NSArray arrayWithArray:response.products];
    NSArray *invalidProductIdentifiers = [NSArray arrayWithArray:response.invalidProductIdentifiers];
    
    for (SKProduct *product in products)
    {
        ALSRMStoreLog(@"received product with id %@", product.productIdentifier);
        [self.store addProduct:product];
    }
    
    [invalidProductIdentifiers enumerateObjectsUsingBlock:^(NSString *invalid, NSUInteger idx, BOOL *stop) {
        ALSRMStoreLog(@"invalid product with id %@", invalid);
    }];
    
    if (self.successBlock)
    {
        self.successBlock(products, invalidProductIdentifiers);
    }
    NSDictionary *userInfo = @{ALSRMStoreNotificationProducts: products, ALSRMStoreNotificationInvalidProductIdentifiers: invalidProductIdentifiers};
    [[NSNotificationCenter defaultCenter] postNotificationName:ALSRMSKProductsRequestFinished object:self.store userInfo:userInfo];
    
    if ( self.store.storeProductsRequestFinished )
        self.store.storeProductsRequestFinished( self.store.products,self.store, userInfo );
}

- (void)requestDidFinish:(SKRequest *)request
{
    [self.store removeProductsRequestDelegate:self];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    ALSRMStoreLog(@"products request failed with error %@", error.debugDescription);
    if (self.failureBlock)
    {
        self.failureBlock(error);
    }
    NSDictionary *userInfo = nil;
    if (error)
    { // error might be nil (e.g., on airplane mode)
        userInfo = @{ALSRMStoreNotificationStoreError: error};
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ALSRMSKProductsRequestFailed object:self.store userInfo:userInfo];
    
    if ( self.store.storeProductsRequestFailed )
        self.store.storeProductsRequestFailed( self,self.store, userInfo );
    
    [self.store removeProductsRequestDelegate:self];
}

@end
