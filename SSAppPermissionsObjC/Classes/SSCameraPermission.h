//
//  SSCameraPermission.h
//  PermissionObjC
//
//  Created by Alien on 2026/11/26.
//

#import <Foundation/Foundation.h>
@class SSCameraPermissionResult;

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, SSCameraPermissionStatus) {
    SSCameraPermissionStatusAllowed,
    SSCameraPermissionStatusDenied,
    SSCameraPermissionStatusLimited
};

@interface SSCameraPermission : NSObject
+ (void)requestCameraPermissionWithCompletion:(void (^)(SSCameraPermissionResult *result))completion;
+ (SSCameraPermissionResult *)cameraPermission;
+ (SSCameraPermissionResult *)cameraSystemPermission;
@end
NS_ASSUME_NONNULL_END
