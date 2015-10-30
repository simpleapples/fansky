//
//  SANotificationManager.m
//  fansky
//
//  Created by Zzy on 9/30/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SANotificationManager.h"
#import "SAAPIService.h"
#import "SADataManager+Status.h"
#import "SADataManager+User.h"
#import "SAUser+CoreDataProperties.h"
#import "SAStatus+CoreDataProperties.h"

@interface SANotificationManager ()

@property (nonatomic, readwrite) NSUInteger timeLineCount;
@property (nonatomic, readwrite) NSUInteger mentionCount;
@property (nonatomic, readwrite) NSUInteger messageCount;
@property (nonatomic, readwrite) NSUInteger friendRequestCount;
@property (strong, nonatomic) NSTimer *fetchTimer;

@end

@implementation SANotificationManager

static NSUInteger FETCH_TIME_INTERVAL = 30;

+ (SANotificationManager *)sharedManager
{
    static SANotificationManager *sharedManager;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        if (!sharedManager) {
            sharedManager = [[SANotificationManager alloc] init];
        }
    });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fetchTimer = [NSTimer timerWithTimeInterval:FETCH_TIME_INTERVAL target:self selector:@selector(updateNotificationCount) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)startFetchNotificationCount
{
    [[NSRunLoop mainRunLoop] addTimer:self.fetchTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopFetchNotificationCount
{
    [self.fetchTimer invalidate];
}

- (void)updateNotificationCount
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    if (currentUser) {
        [[SADataManager sharedManager] currentTimeLineWithUserID:currentUser.userID type:SAStatusTypeTimeLine offset:0 limit:1 completeHandler:^(NSArray *result) {
            if (result.count) {
                SAStatus *currentStatus = [result firstObject];
                [[SAAPIService sharedSingleton] timeLineWithUserID:currentUser.userID sinceID:currentStatus.statusID maxID:nil count:60 success:^(id data) {
                    NSArray *newTimeLine = (NSArray *)data;
                    if (newTimeLine.count) {
                        self.timeLineCount = newTimeLine.count;
                    }
                } failure:nil];
            }
        }];
        
        [[SAAPIService sharedSingleton] accountNotificationWithSuccess:^(id data) {
            NSNumber *mentionCountValue = (NSNumber *)[data objectForKey:@"mentions"];
            NSNumber *messageCountValue = (NSNumber *)[data objectForKey:@"direct_messages"];
            NSNumber *friendRequestCountValue = (NSNumber *)[data objectForKey:@"friend_requests"];
            self.mentionCount = mentionCountValue.integerValue;
            self.messageCount = messageCountValue.integerValue;
            self.friendRequestCount = friendRequestCountValue.integerValue;
        } failure:nil];
    }
}

@end
