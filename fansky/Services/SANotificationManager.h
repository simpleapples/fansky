//
//  SANotificationManager.h
//  fansky
//
//  Created by Zzy on 9/30/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SANotificationManager : NSObject

@property (nonatomic, readonly) NSUInteger timeLineCount;
@property (nonatomic, readonly) NSUInteger mentionCount;
@property (nonatomic, readonly) NSUInteger messageCount;
@property (nonatomic, readonly) NSUInteger friendRequestCount;

+ (SANotificationManager *)sharedManager;

- (void)startFetchNotificationCount;
- (void)stopFetchNotificationCount;
- (void)updateNotificationCount;

@end
