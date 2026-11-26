//
//  SSLocationPermission.h
//  PermissionObjC
//
//  Created by Alien on 2026/11/26.
//

#import <Foundation/Foundation.h>
@class SSLocationPermissionResult;
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SSLocationPermissionStatus) {
    SSLocationPermissionStatusAllowed,
    SSLocationPermissionStatusDenied,
    SSLocationPermissionStatusLimited
};

@interface SSLocationPermission : NSObject
+ (void)requestLocationCoordinateWithCompletion:(void (^)(SSLocationPermissionResult *result, NSString *latitude, NSString *longitude))completion;
+ (SSLocationPermissionResult *)locationPermission;
+ (SSLocationPermissionResult *)locationChangedPermission;
@end

NS_ASSUME_NONNULL_END
