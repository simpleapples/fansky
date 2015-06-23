//
//  UserService.m
//  fansky
//
//  Created by Zzy on 6/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SAUserManager.h"
#import "SAConstants.h"
#import <AFNetworking/AFNetworking.h>
#import <AFXAuthClient/AFXAuthClient.h>

@interface SAUserManager ()

@property (strong, nonatomic) NSOperationQueue *networkQueue;

@end

@implementation SAUserManager

+ (SAUserManager *)manager
{
    static SAUserManager *manager;
    dispatch_once_t token;
    dispatch_once(&token, ^{
        if (!manager) {
            manager = [[SAUserManager alloc] init];
        }
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.networkQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)authWithUsername:(NSString *)username password:(NSString *)password success:(void(^)())success failure:(void(^)(NSError *error))failure
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *baseURL = [NSURL URLWithString:BASE_URL];
        AFXAuthClient *authClient = [[AFXAuthClient alloc] initWithBaseURL:baseURL key:COMSUMER_KEY secret:COMSUMER_SECRET];
        [authClient authorizeUsingXAuthWithAccessTokenPath:ACCESS_TOKEN_PATH accessMethod:@"POST" username:username password:password success:^(AFXAuthToken *accessToken) {
//            [self getUserWithUsername:username success:^(id data){
//                NSLog(@"%@", data);
//                if (success) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        success();
//                    });
//                }
//            } failure:^(NSError *error){
//                if (failure) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        failure(error);
//                    });
//                }
//            }];
            
        } failure:^(NSError *error) {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(error);
                });
            }
        }];
    });
}

@end
