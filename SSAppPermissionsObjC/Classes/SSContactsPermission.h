//
//  SSContactsPermission.h
//  PermissionObjC
//
//  Created by Alien on 2026/11/26.
//

#import <Foundation/Foundation.h>
@class SSContactsPermissionResult;
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SSContactsPermissionStatus) {
    SSContactsPermissionStatusAllowed,
    SSContactsPermissionStatusDenied,
    SSContactsPermissionStatusLimited
};

@interface SSContactsPermission : NSObject
+ (void)requestContactsPermissionWithCompletion:(void (^)(SSContactsPermissionResult *result))completion;
+ (SSContactsPermissionResult *)contactsPermission;
+ (SSContactsPermissionResult *)contactsSystemPermission;
@end

NS_ASSUME_NONNULL_END
