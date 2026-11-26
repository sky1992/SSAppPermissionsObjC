//
//  SSLocationPermission.m
//  PermissionObjC
//
//  Created by Alien on 2026/11/26.
//

#import "SSLocationPermission.h"
#import <CoreLocation/CoreLocation.h>

@interface SSLocationPermissionResult : NSObject
@property (nonatomic, assign) SSLocationPermissionStatus status;
@property (nonatomic, assign) BOOL isSystem;
- (instancetype)initWithStatus:(SSLocationPermissionStatus)status isSystem:(BOOL)isSystem;
@end

@interface SSLocationRequestDelegate : NSObject <CLLocationManagerDelegate>
@property (nonatomic, copy) void(^authCompletion)(SSLocationPermissionResult *);
@property (nonatomic, copy) void(^coordinateCompletion)(SSLocationPermissionResult *, NSString *, NSString *);
@property (nonatomic, assign) BOOL hasReturnedCoordinate;
@property (nonatomic, strong) NSLock *coordinateLock;
- (void)prepareCoordinateCompletion:(void (^)(SSLocationPermissionResult *, NSString *, NSString *))completion;
- (void)finishCoordinateOnceWithLatitude:(NSString *)lat longitude:(NSString *)lon;
@end

@implementation SSLocationRequestDelegate
- (instancetype)init {
    self = [super init];
    if (self) {
        _coordinateLock = [[NSLock alloc] init];
        _hasReturnedCoordinate = NO;
    }
    return self;
}

- (void)prepareCoordinateCompletion:(void (^)(SSLocationPermissionResult *, NSString *, NSString *))completion {
    [self.coordinateLock lock];
    self.coordinateCompletion = completion;
    self.hasReturnedCoordinate = NO;
    [self.coordinateLock unlock];
}

- (void)finishCoordinateOnceWithLatitude:(NSString *)lat longitude:(NSString *)lon {
    [self.coordinateLock lock];
    if (self.hasReturnedCoordinate) {
        [self.coordinateLock unlock];
        return;
    }
    self.hasReturnedCoordinate = YES;
    void(^callback)(SSLocationPermissionResult *, NSString *, NSString *) = self.coordinateCompletion;
    self.coordinateCompletion = nil;
    [self.coordinateLock unlock];
    if (callback) {
        callback([SSLocationPermission locationPermission], lat, lon);
    }
}

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    CLAuthorizationStatus auth = manager.authorizationStatus;
    if (auth == kCLAuthorizationStatusNotDetermined) {
        return;
    }
    void(^callback)(SSLocationPermissionResult *) = self.authCompletion;
    self.authCompletion = nil;
    if (callback) {
        callback([SSLocationPermission locationChangedPermission]);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *loc = locations.lastObject;
    if (!loc) {
        [self finishCoordinateOnceWithLatitude:@"-360" longitude:@"-360"];
        return;
    }
    NSString *latStr = [NSString stringWithFormat:@"%.6f", loc.coordinate.latitude];
    NSString *lonStr = [NSString stringWithFormat:@"%.6f", loc.coordinate.longitude];
    [self finishCoordinateOnceWithLatitude:latStr longitude:lonStr];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self finishCoordinateOnceWithLatitude:@"-360" longitude:@"-360"];
}
@end

@implementation SSLocationPermissionResult
- (instancetype)initWithStatus:(SSLocationPermissionStatus)status isSystem:(BOOL)isSystem {
    self = [super init];
    if (self) {
        _status = status;
        _isSystem = isSystem;
    }
    return self;
}
@end

@interface SSLocationPermission ()
@property (class, nonatomic, readonly) CLLocationManager *ssManager;
@property (class, nonatomic, readonly) SSLocationRequestDelegate *ssDelegate;
@end

@implementation SSLocationPermission

+ (CLLocationManager *)ssManager {
    static CLLocationManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CLLocationManager alloc] init];
    });
    return manager;
}

+ (SSLocationRequestDelegate *)ssDelegate {
    static SSLocationRequestDelegate *delegate;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        delegate = [[SSLocationRequestDelegate alloc] init];
    });
    return delegate;
}

+ (SSLocationPermissionResult *)locationPermission {
    CLAuthorizationStatus auth = self.ssManager.authorizationStatus;
    SSLocationPermissionStatus status = SSLocationPermissionStatusDenied;
    if (auth == kCLAuthorizationStatusAuthorizedAlways || auth == kCLAuthorizationStatusAuthorizedWhenInUse) {
        status = SSLocationPermissionStatusAllowed;
    }
    return [[SSLocationPermissionResult alloc] initWithStatus:status isSystem:NO];
}

+ (SSLocationPermissionResult *)locationChangedPermission {
    CLAuthorizationStatus auth = self.ssManager.authorizationStatus;
    SSLocationPermissionStatus status = SSLocationPermissionStatusDenied;
    if (auth == kCLAuthorizationStatusAuthorizedAlways || auth == kCLAuthorizationStatusAuthorizedWhenInUse) {
        status = SSLocationPermissionStatusAllowed;
    }
    return [[SSLocationPermissionResult alloc] initWithStatus:status isSystem:YES];
}

+ (void)requestLocationPermissionWithCompletion:(void (^)(SSLocationPermissionResult *result))completion {
    CLAuthorizationStatus current = self.ssManager.authorizationStatus;
    if (current != kCLAuthorizationStatusNotDetermined) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([self locationPermission]);
        });
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.ssManager.delegate = self.ssDelegate;
        self.ssDelegate.authCompletion = completion;
        [self.ssManager requestWhenInUseAuthorization];
    });
}

+ (void)requestLocationCoordinateWithCompletion:(void (^)(SSLocationPermissionResult *result, NSString *latitude, NSString *longitude))completion {
    CLAuthorizationStatus auth = self.ssManager.authorizationStatus;
    if (auth == kCLAuthorizationStatusAuthorizedAlways || auth == kCLAuthorizationStatusAuthorizedWhenInUse) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.ssManager.delegate = self.ssDelegate;
            [self.ssDelegate prepareCoordinateCompletion:completion];
            [self.ssManager requestLocation];
        });
    } else if (auth == kCLAuthorizationStatusNotDetermined) {
        [self requestLocationPermissionWithCompletion:^(SSLocationPermissionResult *result) {
            if (result.status != SSLocationPermissionStatusAllowed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(result, @"-360", @"-360");
                });
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.ssManager.delegate = self.ssDelegate;
                [self.ssDelegate prepareCoordinateCompletion:completion];
                [self.ssManager requestLocation];
            });
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([self locationPermission], @"-360", @"-360");
        });
    }
}
@end
