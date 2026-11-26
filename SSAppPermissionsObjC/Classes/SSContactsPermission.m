//
//  SSContactsPermission.m
//  PermissionObjC
//
//  Created by Alien on 2026/11/26.
//

#import "SSContactsPermission.h"
#import <Contacts/Contacts.h>

@interface SSContactsPermissionResult : NSObject
@property (nonatomic, assign) SSContactsPermissionStatus status;
@property (nonatomic, assign) BOOL isSystem;
- (instancetype)initWithStatus:(SSContactsPermissionStatus)status isSystem:(BOOL)isSystem;
@end

@implementation SSContactsPermissionResult
- (instancetype)initWithStatus:(SSContactsPermissionStatus)status isSystem:(BOOL)isSystem {
    self = [super init];
    if (self) {
        _status = status;
        _isSystem = isSystem;
    }
    return self;
}
@end

@implementation SSContactsPermission

+ (void)requestContactsPermissionWithCompletion:(void (^)(SSContactsPermissionResult *result))completion {
    CNAuthorizationStatus auth = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (auth != CNAuthorizationStatusNotDetermined) {
        completion([self contactsPermission]);
        return;
    }
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        completion([self contactsSystemPermission]);
    }];
}

+ (SSContactsPermissionResult *)contactsPermission {
    CNAuthorizationStatus auth = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    SSContactsPermissionStatus status = SSContactsPermissionStatusDenied;
    switch (auth) {
        case CNAuthorizationStatusAuthorized:
            status = SSContactsPermissionStatusAllowed;
            break;
        case CNAuthorizationStatusDenied:
            status = SSContactsPermissionStatusDenied;
            break;
        case CNAuthorizationStatusRestricted:
            status = SSContactsPermissionStatusDenied;
            break;
        case CNAuthorizationStatusLimited:
            status = SSContactsPermissionStatusLimited;
            break;
        case CNAuthorizationStatusNotDetermined:
            status = SSContactsPermissionStatusDenied;
            break;
    }
    return [[SSContactsPermissionResult alloc] initWithStatus:status isSystem:NO];
}

+ (SSContactsPermissionResult *)contactsSystemPermission {
    CNAuthorizationStatus auth = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    SSContactsPermissionStatus status = SSContactsPermissionStatusDenied;
    switch (auth) {
        case CNAuthorizationStatusAuthorized:
            status = SSContactsPermissionStatusAllowed;
            break;
        case CNAuthorizationStatusDenied:
            status = SSContactsPermissionStatusDenied;
            break;
        case CNAuthorizationStatusRestricted:
            status = SSContactsPermissionStatusDenied;
            break;
        case CNAuthorizationStatusLimited:
            status = SSContactsPermissionStatusLimited;
            break;
        case CNAuthorizationStatusNotDetermined:
            status = SSContactsPermissionStatusDenied;
            break;
    }
    return [[SSContactsPermissionResult alloc] initWithStatus:status isSystem:YES];
}

@end
