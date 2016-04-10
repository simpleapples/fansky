//
//  SAAPIService.m
//  fansky
//
//  Created by Zzy on 6/23/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SAAPIService.h"
#import "SAConstants.h"
#import "SAUser+CoreDataProperties.h"
#import "SADataManager+User.h"
#import <TDOAuth/TDOAuth.h>

@interface SAAPIService ()

@property (strong, nonatomic) NSURLSession *URLSession;
@property (strong, nonatomic) NSURLSession *uploadURLSession;

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
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = 20;
        configuration.timeoutIntervalForResource = 20;
        self.URLSession = [NSURLSession sessionWithConfiguration:configuration];
        
        NSURLSessionConfiguration *uploadConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = 60;
        configuration.timeoutIntervalForResource = 30;
        self.uploadURLSession = [NSURLSession sessionWithConfiguration:uploadConfiguration];
    }
    return self;
}

#pragma mark - Account

- (void)authorizeWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(NSString *, NSString *))success failure:(void (^)(NSString *))failure
{
    NSMutableURLRequest *URLRequest = [[TDOAuth URLRequestForPath:SA_API_ACCESS_TOKEN_PATH GETParameters:@{@"x_auth_username": username, @"x_auth_password": password,  @"x_auth_mode": @"client_auth"} host:SA_API_BASE_HOST consumerKey:SA_API_COMSUMER_KEY consumerSecret:SA_API_COMSUMER_SECRET accessToken:nil tokenSecret:nil] mutableCopy];
    
    [[self.URLSession dataTaskWithRequest:URLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (!error && ![responseString containsString:@"<error>"]) {
            
            NSRange startRange = [responseString rangeOfString:@"oauth_token="];
            NSRange endRange = [responseString rangeOfString:@"&oauth_token_secret="];
            
            NSRange tokenRange = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
            NSString *token = [responseString substringWithRange:tokenRange];
            NSString *secret = [responseString substringFromIndex:endRange.location + endRange.length];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success(token, secret);
            });
        } else {
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSRange startRange = [responseString rangeOfString:@"<error>"];
            NSRange endRange = [responseString rangeOfString:@"</error>"];
            if (startRange.location && endRange.location && endRange.location > startRange.location) {
                NSString *error = [responseString substringWithRange:NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length)];
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(error);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(@"网络故障");
                });
            }
        }
    }] resume];
}

- (void)verifyCredentialsWithToken:(NSString *)token secret:(NSString *)secret success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    NSMutableURLRequest *URLRequest = [[TDOAuth URLRequestForPath:SA_API_VERIFY_CREDENTIALS_PATH parameters:@{@"mode": @"lite"} host:SA_API_HOST consumerKey:SA_API_COMSUMER_KEY consumerSecret:SA_API_COMSUMER_SECRET accessToken:token tokenSecret:secret scheme:@"http" requestMethod:@"POST" dataEncoding:TDOAuthContentTypeUrlEncodedForm headerValues:nil signatureMethod:TDOAuthSignatureMethodHmacSha1] mutableCopy];
    
    [[self.URLSession dataTaskWithRequest:URLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSString *error = [responseJSON objectForKey:@"error"];
            if (responseJSON && !error && success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(responseJSON);
                });
            } else if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(error);
                });
            }
        } else if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(@"获取身份信息失败");
            });
        }
    }] resume];
}

- (void)accountNotificationWithSuccess:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [self requestAPIWithPath:SA_API_ACCOUNT_NOTIFICATION_PATH method:@"GET" parametersDictionary:nil success:success failure:failure];
}

- (void)updateProfileWithImage:(NSData *)image success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [self requestAPIWithPath:SA_API_UPDATE_PROFILE_IMAGE_PATH method:@"POST" parametersDictionary:@{@"mode": @"lite", @"format": @"html"} image:image success:success failure:failure];
}

- (void)updateProfileWithLocation:(NSString *)location desc:(NSString *)desc success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    if (!location) {
        location = @" ";
    }
    if (!desc) {
        desc = @" ";
    }
    [self requestAPIWithPath:SA_API_UPDATE_PROFILE_PATH method:@"POST" parametersDictionary:@{@"location": location, @"description": desc, @"mode": @"lite", @"format": @"html"} success:success failure:failure];
}

#pragma mark - User

- (void)userWithID:(NSString *)userID success:(void (^)(id))success failure:(void (^)(NSString *error))failure
{
    [self requestAPIWithPath:SA_API_USER_SHOW_PATH method:@"GET" parametersDictionary:@{@"id": userID, @"mode": @"lite"} success:success failure:failure];
}

- (void)followUserWithID:(NSString *)userID success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [self requestAPIWithPath:SA_API_FOLLOW_USER_PATH method:@"POST" parametersDictionary:@{@"id": userID, @"mode": @"lite"} success:success failure:failure];
}

- (void)unfollowUserWithID:(NSString *)userID success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [self requestAPIWithPath:SA_API_UNFOLLOW_USER_PATH method:@"POST" parametersDictionary:@{@"id": userID, @"mode": @"lite"} success:success failure:failure];
}

- (void)userFriendsWithUserID:(NSString *)userID count:(NSUInteger)count page:(NSUInteger)page success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [self requestAPIWithPath:SA_API_USER_FRIEND_PATH method:@"GET" parametersDictionary:@{@"id": userID, @"count": @(count), @"page": @(page), @"mode": @"lite", @"format": @"html"} success:success failure:failure];
}

- (void)userFollowersWithUserID:(NSString *)userID count:(NSUInteger)count page:(NSUInteger)page success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [self requestAPIWithPath:SA_API_USER_FOLLOWER_PATH method:@"GET" parametersDictionary:@{@"id": userID, @"count": @(count), @"page": @(page), @"mode": @"lite", @"format": @"html"} success:success failure:failure];
}

- (void)userFriendshipRequestWithCount:(NSUInteger)count page:(NSUInteger)page success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [self requestAPIWithPath:SA_API_FRIENDSHIP_REQUEST_PATH method:@"GET" parametersDictionary:@{@"count": @(count), @"page": @(page), @"mode": @"lite", @"format": @"html"} success:success failure:failure];
}

- (void)userFriendshipAcceptWithUserID:(NSString *)userID success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [self requestAPIWithPath:SA_API_FRIENDSHIP_ACCEPT_PATH method:@"POST" parametersDictionary:@{@"id": userID, @"mode": @"lite", @"format": @"html"} success:success failure:failure];

}

- (void)userFriendshipDenyWithUserID:(NSString *)userID success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [self requestAPIWithPath:SA_API_FRIENDSHIP_DENY_PATH method:@"POST" parametersDictionary:@{@"id": userID, @"mode": @"lite", @"format": @"html"} success:success failure:failure];
}

#pragma mark - Status

- (void)timeLineWithUserID:(NSString *)userID sinceID:(NSString *)sinceID maxID:(NSString *)maxID count:(NSInteger)count success:(void (^)(id))success failure:(void (^)(NSString *error))failure
{
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:userID, @"id", @(count), @"count", @"html", @"format", nil];
    if (sinceID) {
        [mutableDictionary setObject:sinceID forKey:@"since_id"];
    }
    if (maxID) {
        [mutableDictionary setObject:maxID forKey:@"max_id"];
    }
    [self requestAPIWithPath:SA_API_HOME_TIMELINE_PATH method:@"GET" parametersDictionary:mutableDictionary success:success failure:failure];
}

- (void)userTimeLineWithUserID:(NSString *)userID sinceID:(NSString *)sinceID maxID:(NSString *)maxID count:(NSInteger)count success:(void (^)(id))success failure:(void (^)(NSString *error))failure
{
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:userID, @"id", @(count), @"count", @"html", @"format", nil];
    if (sinceID) {
        [mutableDictionary setObject:sinceID forKey:@"since_id"];
    }
    if (maxID) {
        [mutableDictionary setObject:maxID forKey:@"max_id"];
    }
    [self requestAPIWithPath:SA_API_USER_TIMELINE_PATH method:@"GET" parametersDictionary:mutableDictionary success:success failure:failure];
}

- (void)sendStatus:(NSString *)status replyToStatusID:(NSString *)replyToStatusID repostStatusID:(NSString *)repostStatusID image:(NSData *)image success:(void (^)(id))success failure:(void (^)(NSString *error))failure
{
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:status, @"status", @"lite", @"mode", @"html", @"format", nil];
    if (replyToStatusID) {
        [mutableDictionary setObject:replyToStatusID forKey:@"in_reply_to_status_id"];
    }
    if (repostStatusID) {
        [mutableDictionary setObject:repostStatusID forKey:@"repost_status_id"];
    }
    if (image) {
        [self requestAPIWithPath:SA_API_UPDATE_PHOTO_STATUS_PATH method:@"POST" parametersDictionary:mutableDictionary image:image success:success failure:failure];
    } else {
        [self requestAPIWithPath:SA_API_UPDATE_STATUS_PATH method:@"POST" parametersDictionary:mutableDictionary success:success failure:failure];
    }
}

- (void)userPhotoTimeLineWithUserID:(NSString *)userID sinceID:(NSString *)sinceID maxID:(NSString *)maxID count:(NSInteger)count success:(void (^)(id))success failure:(void (^)(NSString *error))failure
{
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:userID, @"id", @(count), @"count", @"lite", @"mode", @"html", @"format", nil];
    if (sinceID) {
        [mutableDictionary setObject:sinceID forKey:@"since_id"];
    }
    if (maxID) {
        [mutableDictionary setObject:maxID forKey:@"max_id"];
    }
    [self requestAPIWithPath:SA_API_USER_PHOTO_TIMELINE_PATH method:@"GET" parametersDictionary:mutableDictionary success:success failure:failure];
}

- (void)deleteStatusWithID:(NSString *)statusID success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [self requestAPIWithPath:SA_API_DELETE_STATUS_PATH method:@"POST" parametersDictionary:@{@"id": statusID, @"mode": @"lite"} success:success failure:failure];
}

- (void)mentionStatusWithSinceID:(NSString *)sinceID maxID:(NSString *)maxID count:(NSInteger)count success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@(count), @"count", @"lite", @"mode", @"html", @"format", nil];
    if (sinceID) {
        [mutableDictionary setObject:sinceID forKey:@"since_id"];
    }
    if (maxID) {
        [mutableDictionary setObject:maxID forKey:@"max_id"];
    }
    [self requestAPIWithPath:SA_API_MENTION_STATUS_PATH method:@"GET" parametersDictionary:mutableDictionary success:success failure:failure];
}

- (void)userFavoriteTimeLineWithUserID:(NSString *)userID count:(NSUInteger)count page:(NSUInteger)page success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [self requestAPIWithPath:SA_API_FAVORITE_STATUS_PATH method:@"GET" parametersDictionary:@{@"id": userID, @"count": @(count), @"page": @(page), @"mode": @"lite", @"format": @"html"} success:success failure:failure];
}

- (void)createFavoriteStatusWithID:(NSString *)statusID success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [self requestAPIWithPath:SA_API_FAVORITE_STATUS_CREATE_PATH method:@"POST" parametersDictionary:@{@"id": statusID, @"mode": @"lite", @"format": @"html"} success:success failure:failure];
}

- (void)deleteFavoriteStatusWithID:(NSString *)statusID success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [self requestAPIWithPath:SA_API_FAVORITE_STATUS_DELETE_PATH method:@"POST" parametersDictionary:@{@"id": statusID, @"mode": @"lite", @"format": @"html"} success:success failure:failure];
}

- (void)showStatusWithID:(NSString *)statusID success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [self requestAPIWithPath:SA_API_STATUS_SHOW_PATH method:@"GET" parametersDictionary:@{@"id": statusID, @"mode": @"lite", @"format": @"html"} success:success failure:failure];
}

#pragma mark - Message

- (void)conversationListWithCount:(NSInteger)count success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [self requestAPIWithPath:SA_API_CONVERSATION_LIST_PATH method:@"GET" parametersDictionary:@{@"count": @(count), @"mode": @"lite"} success:success failure:failure];
}

- (void)conversationWithUserID:(NSString *)userID sinceID:(NSString *)sinceID maxID:(NSString *)maxID count:(NSInteger)count success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:userID, @"id", @(count), @"count", @"lite", @"mode", nil];
    if (sinceID) {
        [mutableDictionary setObject:sinceID forKey:@"since_id"];
    }
    if (maxID) {
        [mutableDictionary setObject:maxID forKey:@"max_id"];
    }
    [self requestAPIWithPath:SA_API_CONVERSATION_PATH method:@"GET" parametersDictionary:mutableDictionary success:success failure:failure];
}

- (void)sendMessageWithUserID:(NSString *)userID text:(NSString *)text replyToMessageID:(NSString *)replyToMessageID success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:userID, @"user", text, @"text", @"lite", @"mode", nil];
    if (replyToMessageID) {
        [mutableDictionary setValue:replyToMessageID forKey:@"in_reply_to_id"];
    }
    [self requestAPIWithPath:SA_API_SEND_NEW_MESSAGE_PATH method:@"POST" parametersDictionary:mutableDictionary success:success failure:failure];
}

#pragma mark - Search

- (void)searchPublicTimeLineWithKeyword:(NSString *)keyword sinceID:(NSString *)sinceID maxID:(NSString *)maxID count:(NSInteger)count success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:keyword, @"q", @(count), @"count", @"lite", @"mode", @"html", @"format", nil];
    if (sinceID) {
        [mutableDictionary setObject:sinceID forKey:@"since_id"];
    }
    if (maxID) {
        [mutableDictionary setObject:maxID forKey:@"max_id"];
    }
    [self requestAPIWithPath:SA_API_SEARCH_PUBLIC_TIMELINE_PATH method:@"GET" parametersDictionary:mutableDictionary success:success failure:failure];
}

#pragma mark - Base

- (void)requestAPIWithPath:(NSString *)path method:(NSString *)method parametersDictionary:(NSDictionary *)parametersDictionary image:(NSData *)image success:(void(^)(id responseObject))success failure:(void(^)(NSString *error))failure
{
    NSString *boundary = [self generateBoundaryString];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    NSData *httpBody = [self createBodyWithBoundary:boundary parameters:parametersDictionary data:image];
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    NSMutableURLRequest *mutableURLRequest = [[TDOAuth URLRequestForPath:path parameters:nil host:SA_API_HOST consumerKey:SA_API_COMSUMER_KEY consumerSecret:SA_API_COMSUMER_SECRET accessToken:currentUser.token tokenSecret:currentUser.tokenSecret scheme:@"http" requestMethod:method dataEncoding:TDOAuthContentTypeUrlEncodedForm headerValues:nil signatureMethod:TDOAuthSignatureMethodHmacSha1] mutableCopy];
    [mutableURLRequest setValue:contentType forHTTPHeaderField: @"Content-Type"];
    [mutableURLRequest setHTTPBody:httpBody];
    
    [[self.uploadURLSession dataTaskWithRequest:mutableURLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSString *error = nil;
            if ([responseJSON respondsToSelector:@selector(objectForKey:)]) {
                error = [responseJSON objectForKey:@"error"];
            }
            if (responseJSON && !error && success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(responseJSON);
                });
            } else if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(error);
                });
            }
        } else if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(@"网络故障");
            });
        }
    }] resume];
}

- (void)requestAPIWithPath:(NSString *)path method:(NSString *)method parametersDictionary:(NSDictionary *)parametersDictionary success:(void(^)(id responseObject))success failure:(void(^)(NSString *error))failure
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    
    NSMutableURLRequest *URLRequest = [[TDOAuth URLRequestForPath:path parameters:parametersDictionary host:SA_API_HOST consumerKey:SA_API_COMSUMER_KEY consumerSecret:SA_API_COMSUMER_SECRET accessToken:currentUser.token tokenSecret:currentUser.tokenSecret scheme:@"http" requestMethod:method dataEncoding:TDOAuthContentTypeUrlEncodedForm headerValues:nil signatureMethod:TDOAuthSignatureMethodHmacSha1] mutableCopy];
    
    [[self.URLSession dataTaskWithRequest:URLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSString *error = nil;
            if ([responseJSON respondsToSelector:@selector(objectForKey:)]) {
                error = [responseJSON objectForKey:@"error"];
            }
            if (responseJSON && !error && success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(responseJSON);
                });
            } else if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(error);
                });
            }
        } else if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(@"网络故障");
            });
        }
    }] resume];
}

- (void)stopAllTasks
{
    [self.URLSession getAllTasksWithCompletionHandler:^(NSArray<__kindof NSURLSessionTask *> * _Nonnull tasks) {
        for (NSURLSessionTask *task in tasks) {
            [task cancel];
        }
    }];
}

#pragma mark - PhotoUpload

- (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
                             data:(NSData *)data
{
    NSMutableData *httpBody = [NSMutableData data];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[@"Content-Disposition: form-data; name=\"photo\"; filename=\"photo\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:data];
    [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return httpBody;
}

- (NSString *)generateBoundaryString
{
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
}

@end
