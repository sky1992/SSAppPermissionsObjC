//
//  SSCameraPermission.m
//  PermissionObjC
//
//  Created by Alien on 2026/11/26.
//

#import "SSCameraPermission.h"
#import <AVFoundation/AVFoundation.h>

@interface SSCameraPermissionResult : NSObject
@property (nonatomic, assign) SSCameraPermissionStatus status;
@property (nonatomic, assign) BOOL isSystem;
- (instancetype)initWithStatus:(SSCameraPermissionStatus)status isSystem:(BOOL)isSystem;
@end

@implementation SSCameraPermissionResult
- (instancetype)initWithStatus:(SSCameraPermissionStatus)status isSystem:(BOOL)isSystem {
    self = [super init];
    if (self) {
        _status = status;
        _isSystem = isSystem;
    }
    return self;
}
@end

@implementation SSCameraPermission

+ (void)requestCameraPermissionWithCompletion:(void (^)(SSCameraPermissionResult *result))completion {
    AVAuthorizationStatus auth = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (auth != AVAuthorizationStatusNotDetermined) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([self cameraPermission]);
        });
        return;
    }
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([self cameraSystemPermission]);
        });
    }];
}

+ (SSCameraPermissionResult *)cameraPermission {
    AVAuthorizationStatus auth = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    SSCameraPermissionStatus status = SSCameraPermissionStatusDenied;
    switch (auth) {
        case AVAuthorizationStatusAuthorized:
            status = SSCameraPermissionStatusAllowed;
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            status = SSCameraPermissionStatusDenied;
            break;
        case AVAuthorizationStatusNotDetermined:
            status = SSCameraPermissionStatusDenied;
            break;
    }
    return [[SSCameraPermissionResult alloc] initWithStatus:status isSystem:NO];
}

+ (SSCameraPermissionResult *)cameraSystemPermission {
    AVAuthorizationStatus auth = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    SSCameraPermissionStatus status = SSCameraPermissionStatusDenied;
    switch (auth) {
        case AVAuthorizationStatusAuthorized:
            status = SSCameraPermissionStatusAllowed;
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            status = SSCameraPermissionStatusDenied;
            break;
        case AVAuthorizationStatusNotDetermined:
            status = SSCameraPermissionStatusDenied;
            break;
    }
    return [[SSCameraPermissionResult alloc] initWithStatus:status isSystem:YES];
}

@end
