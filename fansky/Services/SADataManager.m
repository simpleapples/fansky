//
//  SADataManager.m
//  fansky
//
//  Created by Zzy on 16/3/21.
//  Copyright © 2016年 Zzy. All rights reserved.
//

#import "SADataManager.h"
#import <Realm/Realm.h>

@implementation SADataManager

+ (SADataManager *)sharedManager
{
    static SADataManager *sharedManager;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        if (!sharedManager) {
            sharedManager = [[SADataManager alloc] init];
        }
    });
    return sharedManager;
}

- (RLMRealm *)defaultRealm
{
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.path = [[[config.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"fansky"] stringByAppendingPathExtension:@"realm"];
    RLMRealm *realm = [RLMRealm realmWithConfiguration:config error:nil];
    return realm;
}

@end
