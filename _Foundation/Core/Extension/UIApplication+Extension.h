//
//  UIApplication+Extension.h
//  student
//
//  Created by fallen.ink on 28/09/2017.
//  Copyright © 2017 alliance. All rights reserved.
//
//  https://github.com/JackRostron/UIApplication-Permissions

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#pragma mark - Permission

typedef enum {
    PermissionTypeBluetoothLE,
    PermissionTypeCalendar,
    PermissionTypeContacts,
    PermissionTypeLocation,
    PermissionTypeMicrophone,
    PermissionTypeMotion,
    PermissionTypePhotos,
    PermissionTypeReminders,
} PermissionType;

typedef enum {
    PermissionAccessDenied, //User has rejected feature
    PermissionAccessGranted, //User has accepted feature
    PermissionAccessRestricted, //Blocked by parental controls or system settings
    PermissionAccessUnknown, //Cannot be determined
    PermissionAccessUnsupported, //Device doesn't support this - e.g Core Bluetooth
    PermissionAccessMissingFramework, //Developer didn't import the required framework to the project
} PermissionAccess;

@interface UIApplication (Permission)

//Check permission of service. Cannot check microphone or motion without asking user for permission
- (PermissionAccess)hasAccessToBluetoothLE;
- (PermissionAccess)hasAccessToCalendar;
- (PermissionAccess)hasAccessToContacts;
- (PermissionAccess)hasAccessToLocation;
- (PermissionAccess)hasAccessToPhotos;
- (PermissionAccess)hasAccessToReminders;

//Request permission with callback
- (void)requestAccessToCalendarWithSuccess:(void(^)())accessGranted andFailure:(void(^)())accessDenied;
- (void)requestAccessToContactsWithSuccess:(void(^)())accessGranted andFailure:(void(^)())accessDenied;
- (void)requestAccessToMicrophoneWithSuccess:(void(^)())accessGranted andFailure:(void(^)())accessDenied;
- (void)requestAccessToPhotosWithSuccess:(void(^)())accessGranted andFailure:(void(^)())accessDenied;
- (void)requestAccessToRemindersWithSuccess:(void(^)())accessGranted andFailure:(void(^)())accessDenied;
- (void)requestAccessToLocationWithSuccess:(void(^)())accessGranted andFailure:(void(^)())accessDenied;

//No failure callback available
- (void)requestAccessToMotionWithSuccess:(void(^)())accessGranted;

//Needs investigating - unsure whether it can be implemented because of required delegate callbacks
//-(void)requestAccessToBluetoothLEWithSuccess:(void(^)())accessGranted;

@end

#pragma mark - NetworkActivityIndicator

@interface UIApplication (JKNetworkActivityIndicator)

/// Tell the application that network activity has begun. The network activity indicator will then be shown.
/// Display the network activity indicator to provide feedback when your application accesses the network for more than a couple of seconds. If the operation finishes sooner than that, you don’t have to show the network activity indicator, because the indicator would be likely to disappear before users notice its presence.
- (void)beginNetworkActivity;

/// Tell the application that a session of network activity has begun. The network activity indicator will remain showing or hide automatically depending the presence of other ongoing network activity in the app.
- (void)endNetworkActivity;

@end


#pragma mark - KeyboardFrame

@interface UIApplication (KeyboardFrame)

@property (nonatomic, readonly) CGRect keyboardFrame;

@end


