//
//  SSNotificationsPermission.h
//  PermissionObjC
//
//  Created by Alien on 2026/11/26.
//

#import <Foundation/Foundation.h>
@class SSNotificationsPermissionResult;
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SSNotificationsPermissionStatus) {
    SSNotificationsPermissionStatusAllowed,
    SSNotificationsPermissionStatusDenied,
    SSNotificationsPermissionStatusLimited
};

@interface SSNotificationsPermission : NSObject
+ (void)notificationPermissionWithIsRequest:(BOOL)isRequest completion:(void (^)(SSNotificationsPermissionResult *result))completion;
@end

NS_ASSUME_NONNULL_END
