//
//  UserService.m
//  fansky
//
//  Created by Zzy on 6/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SAUserManager.h"
#import "SAConstants.h"
#import <AFXAuthClient/AFXAuthClient.h>

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

- (void)authWithUsername:(NSString *)username password:(NSString *)password success:(void(^)())success failure:(void(^)(NSError *error))failure
{
    NSURL *baseURL = [NSURL URLWithString:BASE_URL];
    AFXAuthClient *authClient = [[AFXAuthClient alloc] initWithBaseURL:baseURL key:COMSUMER_KEY secret:COMSUMER_SECRET];
    [authClient authorizeUsingXAuthWithAccessTokenPath:ACCESS_TOKEN_PATH accessMethod:@"POST" username:username password:password success:^(AFXAuthToken *accessToken) {
        NSLog(@"%@", accessToken);
    } failure:^(NSError *error) {
        
    }];
}

@end
