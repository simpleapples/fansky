//
//  SAAPIService.m
//  fansky
//
//  Created by Zzy on 6/23/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SAAPIService.h"
#import "SAConstants.h"
#import "SAUser.h"
#import "SADataManager+User.h"
#import <SSKeychain/SSKeychain.h>
#import <TDOAuth/TDOAuth.h>
#import <AFNetworking/AFNetworking.h>

@interface SAAPIService ()

@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (strong, nonatomic) AFHTTPRequestOperationManager *operationManager;

@end

@implementation SAAPIService

+ (SAAPIService *)sharedSingleton
{
    static SAAPIService *sharedSingleton;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        if (!sharedSingleton) {
            sharedSingleton = [[SAAPIService alloc] init];
        }
    });
    return sharedSingleton;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationManager = [AFHTTPRequestOperationManager manager];
    }
    return self;
}

- (void)authorizeWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure
{
    NSURLRequest *URLRequest = [TDOAuth URLRequestForPath:SA_API_ACCESS_TOKEN_PATH GETParameters:@{@"x_auth_username": username, @"x_auth_password": password,  @"x_auth_mode": @"client_auth"} host:SA_API_BASE_HOST consumerKey:SA_API_COMSUMER_KEY consumerSecret:SA_API_COMSUMER_SECRET accessToken:nil tokenSecret:nil];
    
    [NSURLConnection sendAsynchronousRequest:URLRequest queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSString *token = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            success(token);
        } else {
            failure(connectionError);
        }
    }];
}

- (void)userInfoWithToken:(NSString *)token success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure
{
    [self requestAPIWithPath:SA_API_VERIFY_CREDENTIALS_PATH method:@"POST" parametersDictionary:nil success:success failure:failure];
}

- (void)requestAPIWithPath:(NSString *)path method:(NSString *)method parametersDictionary:(NSDictionary *)parametersDictionary success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure
{
    
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    if (currentUser) {
        NSString *token = [SSKeychain passwordForService:SA_APP_DOMAIN account:currentUser.userID];
        if (token) {
            [self.operationManager.requestSerializer setAuthorizationHeaderFieldWithUsername:token password:@""];
            NSString *headerString = [NSString stringWithFormat:@"OAuth realm=%@", currentUser.token];
            [self.operationManager.requestSerializer setValue:headerString forHTTPHeaderField:@"X-asd"];
        }
    }
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    };
    void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    };
    
    NSString *URLString = [NSString stringWithFormat:@"http://%@%@", SA_API_HOST, path];
    if ([method isEqualToString:@"POST"]) {
        [self.operationManager POST:URLString parameters:parametersDictionary success:successBlock failure:failureBlock];
    } else {
        [self.operationManager GET:URLString parameters:parametersDictionary success:successBlock failure:failureBlock];
    }
}

@end
