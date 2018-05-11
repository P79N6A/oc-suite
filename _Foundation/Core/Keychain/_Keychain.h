//  inspired by [soffes/SSKeychain](https://github.com/soffes/SSKeychain)

#import <Foundation/Foundation.h>

#import "_KeychainQuery.h"

/**
 Error code specific to SSKeychain that can be returned in NSError objects.
 For codes returned by the operating system, refer to SecBase.h for your
 platform.
 */
typedef NS_ENUM(OSStatus, SSKeychainErrorCode) {
    /** Some of the arguments were invalid. */
    KeychainErrorBadArguments = -1001,
};

/** SSKeychain error domain */
extern NSString *const KeychainErrorDomain;

/** Account name. */
extern NSString *const KeychainAccountKey;

/**
 Time the item was created.
 
 The value will be a string.
 */
extern NSString *const KeychainCreatedAtKey;

/** Item class. */
extern NSString *const KeychainClassKey;

/** Item description. */
extern NSString *const KeychainDescriptionKey;

/** Item label. */
extern NSString *const KeychainLabelKey;

/** Time the item was last modified.
 
 The value will be a string.
 */
extern NSString *const KeychainLastModifiedKey;

/** Where the item was created. */
extern NSString *const KeychainWhereKey;

/**
 Simple wrapper for accessing accounts, getting passwords, setting passwords, and deleting passwords using the system
 Keychain on Mac OS X and iOS.
 
 This was originally inspired by EMKeychain and SDKeychain (both of which are now gone). Thanks to the authors.
 Keychain has since switched to a simpler implementation that was abstracted from [SSToolkit](http://sstoolk.it).
 */

@interface _Keychain : NSObject

#pragma mark - Classic methods

/**
 Returns a string containing the password for a given account and service, or `nil` if the Keychain doesn't have a
 password for the given parameters.
 
 @param serviceName The service for which to return the corresponding password.
 
 @param account The account for which to return the corresponding password.
 
 @return Returns a string containing the password for a given account and service, or `nil` if the Keychain doesn't
 have a password for the given parameters.
 */
+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account;
+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error __attribute__((swift_error(none)));

+ (NSData *)passwordDataForService:(NSString *)serviceName account:(NSString *)account;
+ (NSData *)passwordDataForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error __attribute__((swift_error(none)));


/**
 Deletes a password from the Keychain.
 
 @param serviceName The service for which to delete the corresponding password.
 
 @param account The account for which to delete the corresponding password.
 
 @return Returns `YES` on success, or `NO` on failure.
 */
+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account;
+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error __attribute__((swift_error(none)));


/**
 Sets a password in the Keychain.
 
 @param password The password to store in the Keychain.
 
 @param serviceName The service for which to set the corresponding password.
 
 @param account The account for which to set the corresponding password.
 
 @return Returns `YES` on success, or `NO` on failure.
 */
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account;
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error __attribute__((swift_error(none)));

+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)serviceName account:(NSString *)account;
+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error __attribute__((swift_error(none)));

/**
 Returns an array containing the Keychain's accounts, or `nil` if the Keychain has no accounts.
 
 See the `NSString` constants declared in SSKeychain.h for a list of keys that can be used when accessing the
 dictionaries returned by this method.
 
 @return An array of dictionaries containing the Keychain's accounts, or `nil` if the Keychain doesn't have any
 accounts. The order of the objects in the array isn't defined.
 */
+ (NSArray<NSDictionary<NSString *, id> *> *)allAccounts;
+ (NSArray<NSDictionary<NSString *, id> *> *)allAccounts:(NSError *__autoreleasing *)error __attribute__((swift_error(none)));


/**
 Returns an array containing the Keychain's accounts for a given service, or `nil` if the Keychain doesn't have any
 accounts for the given service.
 
 See the `NSString` constants declared in SSKeychain.h for a list of keys that can be used when accessing the
 dictionaries returned by this method.
 
 @param serviceName The service for which to return the corresponding accounts.
 
 @return An array of dictionaries containing the Keychain's accounts for a given `serviceName`, or `nil` if the Keychain
 doesn't have any accounts for the given `serviceName`. The order of the objects in the array isn't defined.
 */
+ (NSArray<NSDictionary<NSString *, id> *> *)accountsForService:(NSString *)serviceName;
+ (NSArray<NSDictionary<NSString *, id> *> *)accountsForService:(NSString *)serviceName error:(NSError *__autoreleasing *)error __attribute__((swift_error(none)));


#pragma mark - Configuration

#if __IPHONE_4_0 && TARGET_OS_IPHONE
/**
 Returns the accessibility type for all future passwords saved to the Keychain.
 
 @return Returns the accessibility type.
 
 The return value will be `NULL` or one of the "Keychain Item Accessibility
 Constants" used for determining when a keychain item should be readable.
 
 @see setAccessibilityType
 */
+ (CFTypeRef)accessibilityType;

/**
 Sets the accessibility type for all future passwords saved to the Keychain.
 
 @param accessibilityType One of the "Keychain Item Accessibility Constants"
 used for determining when a keychain item should be readable.
 
 If the value is `NULL` (the default), the Keychain default will be used which
 is highly insecure. You really should use at least `kSecAttrAccessibleAfterFirstUnlock`
 for background applications or `kSecAttrAccessibleWhenUnlocked` for all
 other applications.
 
 @see accessibilityType
 */
+ (void)setAccessibilityType:(CFTypeRef)accessibilityType;
#endif

@end

/**
 *  Usage
 --------------------------------
 NSError *error = nil;
 NSString *password = [_Keychain passwordForService:@"MyService" account:@"samsoffes"error:&error];
 
 if ([error code] == KeychainErrorNotFound) {
    NSLog(@"Passwordnot found");
 }
 --------------------------------
 *  Desc
 --------------------------------
 KeyChain的方法中涉及到的变量主要有三个，分别如这一小节的标题所示，是password、service、account。password、account分别保存的是密码和用户名信息。service保存的是服务的类型，就是用户名和密码是为什么应用保存的一个标志。比如一个用户可以再不同的论坛中使用相同的用户名和密码，那么service保存的信息分别标识不同的论坛。由于包名通常具有一定的唯一性，通常在程序中可以用包的名称来作为service的标识
 --------------------------------
 */
