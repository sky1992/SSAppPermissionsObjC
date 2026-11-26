//
//  SSNotificationsPermission.m
//  PermissionObjC
//
//  Created by Alien on 2026/11/26.
//

#import "SSNotificationsPermission.h"
#import <UserNotifications/UserNotifications.h>

@interface SSNotificationsPermissionResult : NSObject
@property (nonatomic, assign) SSNotificationsPermissionStatus status;
@property (nonatomic, assign) BOOL isSystem;
- (instancetype)initWithStatus:(SSNotificationsPermissionStatus)status isSystem:(BOOL)isSystem;
@end

@implementation SSNotificationsPermissionResult
- (instancetype)initWithStatus:(SSNotificationsPermissionStatus)status isSystem:(BOOL)isSystem {
    self = [super init];
    if (self) {
        _status = status;
        _isSystem = isSystem;
    }
    return self;
}
@end

@implementation SSNotificationsPermission

+ (void)notificationPermissionWithIsRequest:(BOOL)isRequest completion:(void (^)(SSNotificationsPermissionResult *result))completion {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        
        SSNotificationsPermissionResult *result;
        UNAuthorizationStatus authStatus = settings.authorizationStatus;
        
        if (authStatus == UNAuthorizationStatusNotDetermined) {
            if (isRequest) {
                [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    SSNotificationsPermissionStatus st = granted ? SSNotificationsPermissionStatusAllowed : SSNotificationsPermissionStatusDenied;
                    SSNotificationsPermissionResult *reqResult = [[SSNotificationsPermissionResult alloc] initWithStatus:st isSystem:YES];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(reqResult);
                    });
                }];
                return;
            } else {
                result = [[SSNotificationsPermissionResult alloc] initWithStatus:SSNotificationsPermissionStatusDenied isSystem:YES];
            }
        }
        else if (authStatus == UNAuthorizationStatusAuthorized) {
            result = [[SSNotificationsPermissionResult alloc] initWithStatus:SSNotificationsPermissionStatusAllowed isSystem:NO];
        }
        else if (authStatus == UNAuthorizationStatusDenied) {
            result = [[SSNotificationsPermissionResult alloc] initWithStatus:SSNotificationsPermissionStatusDenied isSystem:NO];
        }
        else if (authStatus == UNAuthorizationStatusProvisional || authStatus == UNAuthorizationStatusEphemeral) {
            result = [[SSNotificationsPermissionResult alloc] initWithStatus:SSNotificationsPermissionStatusLimited isSystem:NO];
        }
        else {
            result = [[SSNotificationsPermissionResult alloc] initWithStatus:SSNotificationsPermissionStatusDenied isSystem:NO];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(result);
        });
    }];
}

@end
