#import "_Keychain.h"

NSString *const KeychainErrorDomain = @"com.samsoffes.sskeychain";
NSString *const KeychainAccountKey = @"acct";
NSString *const KeychainCreatedAtKey = @"cdat";
NSString *const KeychainClassKey = @"labl";
NSString *const KeychainDescriptionKey = @"desc";
NSString *const KeychainLabelKey = @"labl";
NSString *const KeychainLastModifiedKey = @"mdat";
NSString *const KeychainWhereKey = @"svce";

#if __IPHONE_4_0 && TARGET_OS_IPHONE
static CFTypeRef SSKeychainAccessibilityType = NULL;
#endif

@implementation _Keychain

+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account {
    return [self passwordForService:serviceName account:account error:nil];
}


+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account error:(NSError *__autoreleasing *)error {
    _KeychainQuery *query = [[_KeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    [query fetch:error];
    return query.password;
}

+ (NSData *)passwordDataForService:(NSString *)serviceName account:(NSString *)account {
    return [self passwordDataForService:serviceName account:account error:nil];
}

+ (NSData *)passwordDataForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error {
    _KeychainQuery *query = [[_KeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    [query fetch:error];
    
    return query.passwordData;
}


+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account {
    return [self deletePasswordForService:serviceName account:account error:nil];
}


+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account error:(NSError *__autoreleasing *)error {
    _KeychainQuery *query = [[_KeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    return [query deleteItem:error];
}


+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account {
    return [self setPassword:password forService:serviceName account:account error:nil];
}


+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError *__autoreleasing *)error {
    _KeychainQuery *query = [[_KeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    query.password = password;
    return [query save:error];
}

+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)serviceName account:(NSString *)account {
    return [self setPasswordData:password forService:serviceName account:account error:nil];
}


+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error {
    _KeychainQuery *query = [[_KeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    query.passwordData = password;
    return [query save:error];
}

+ (NSArray *)allAccounts {
    return [self allAccounts:nil];
}


+ (NSArray *)allAccounts:(NSError *__autoreleasing *)error {
    return [self accountsForService:nil error:error];
}


+ (NSArray *)accountsForService:(NSString *)serviceName {
    return [self accountsForService:serviceName error:nil];
}


+ (NSArray *)accountsForService:(NSString *)serviceName error:(NSError *__autoreleasing *)error {
    _KeychainQuery *query = [[_KeychainQuery alloc] init];
    query.service = serviceName;
    return [query fetchAll:error];
}


#if __IPHONE_4_0 && TARGET_OS_IPHONE
+ (CFTypeRef)accessibilityType {
    return SSKeychainAccessibilityType;
}


+ (void)setAccessibilityType:(CFTypeRef)accessibilityType {
    CFRetain(accessibilityType);
    if (SSKeychainAccessibilityType) {
        CFRelease(SSKeychainAccessibilityType);
    }
    SSKeychainAccessibilityType = accessibilityType;
}
#endif


@end
