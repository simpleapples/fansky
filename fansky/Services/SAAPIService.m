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

- (void)authorizeWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(NSString *, NSString *))success failure:(void (^)(NSError *))failure
{
    NSURLRequest *URLRequest = [TDOAuth URLRequestForPath:SA_API_ACCESS_TOKEN_PATH GETParameters:@{@"x_auth_username": username, @"x_auth_password": password,  @"x_auth_mode": @"client_auth"} host:SA_API_BASE_HOST consumerKey:SA_API_COMSUMER_KEY consumerSecret:SA_API_COMSUMER_SECRET accessToken:nil tokenSecret:nil];
    
    [NSURLConnection sendAsynchronousRequest:URLRequest queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSRange startRange = [responseString rangeOfString:@"oauth_token="];
            NSRange endRange = [responseString rangeOfString:@"&oauth_token_secret="];
            
            NSRange tokenRange = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
            NSString *token = [responseString substringWithRange:tokenRange];
            NSString *secret = [responseString substringFromIndex:endRange.location + endRange.length];
            
            success(token, secret);
        } else {
            failure(connectionError);
        }
    }];
}

- (void)verifyCredentialsWithToken:(NSString *)token secret:(NSString *)secret success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSURLRequest *URLRequest = [TDOAuth URLRequestForPath:SA_API_VERIFY_CREDENTIALS_PATH parameters:@{@"mode": @"lite"} host:SA_API_HOST consumerKey:SA_API_COMSUMER_KEY consumerSecret:SA_API_COMSUMER_SECRET accessToken:token tokenSecret:secret scheme:@"http" requestMethod:@"POST" dataEncoding:TDOAuthContentTypeUrlEncodedForm headerValues:nil signatureMethod:TDOAuthSignatureMethodHmacSha1];
    
    [NSURLConnection sendAsynchronousRequest:URLRequest queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if (responseJSON && success) {
                success(responseJSON);
            } else if (failure) {
                failure(nil);
            }
        } else if (failure) {
            failure(connectionError);
        }
    }];
}

- (void)timeLineWithUserID:(NSString *)userID sinceID:(NSString *)sinceID maxID:(NSString *)maxID count:(NSInteger)count success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:sinceID, @"since_id", maxID, @"max_id", nil];
    if (sinceID) {
        [mutableDictionary setObject:sinceID forKey:@"since_id"];
        [mutableDictionary setObject:maxID forKey:@"max_id"];
    }
    [self requestAPIWithPath:SA_API_HOME_TIMELINE_PATH method:@"GET" parametersDictionary:mutableDictionary success:success failure:failure];
}

- (void)sendStatus:(NSString *)status replyToStatusID:(NSString *)replayToStatusID repostStatusID:(NSString *)repostStatusID success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:status, @"status", nil];
    if (replayToStatusID) {
        [mutableDictionary setObject:replayToStatusID forKey:@"in_reply_to_status_id"];
        [mutableDictionary setObject:repostStatusID forKey:@"repost_status_id"];
    }
    [self requestAPIWithPath:SA_API_UPDATE_STATUS_PATH method:@"POST" parametersDictionary:mutableDictionary success:success failure:failure];
}

- (void)userWithID:(NSString *)userID success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    [self requestAPIWithPath:SA_API_USER_SHOW_PATH method:@"POST" parametersDictionary:@{@"id": userID} success:success failure:failure];
}

- (void)requestAPIWithPath:(NSString *)path method:(NSString *)method parametersDictionary:(NSDictionary *)parametersDictionary success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    
    NSURLRequest *URLRequest = [TDOAuth URLRequestForPath:path parameters:parametersDictionary host:SA_API_HOST consumerKey:SA_API_COMSUMER_KEY consumerSecret:SA_API_COMSUMER_SECRET accessToken:currentUser.token tokenSecret:currentUser.tokenSecret scheme:@"http" requestMethod:method dataEncoding:TDOAuthContentTypeUrlEncodedForm headerValues:nil signatureMethod:TDOAuthSignatureMethodHmacSha1];

    [NSURLConnection sendAsynchronousRequest:URLRequest queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if (responseJSON && success) {
                success(responseJSON);
            } else if (failure) {
                failure(nil);
            }
        } else if (failure) {
            failure(connectionError);
        }
    }];
}

@end
