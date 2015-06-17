//
//  UserService.h
//  fansky
//
//  Created by Zzy on 6/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAUserManager : NSObject

+ (SAUserManager *)manager;

- (void)authWithUsername:(NSString *)username password:(NSString *)password success:(void(^)())success failure:(void(^)(NSError *error))failure;

@end
