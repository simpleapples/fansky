//
//  SACacheManager.m
//  fansky
//
//  Created by Zzy on 11/12/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SACacheManager.h"

@interface SACacheManager ()

@property (strong, nonatomic) NSMutableDictionary *cacheDictionary;

@end

@implementation SACacheManager

+ (SACacheManager *)sharedManager
{
    static SACacheManager *sharedManager;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        if (!sharedManager) {
            sharedManager = [[SACacheManager alloc] init];
        }
    });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cacheDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)cachedItemForKey:(NSString *)key
{
    return [self.cacheDictionary valueForKey:key];
}

- (void)cacheItem:(id)item forKey:(NSString *)key
{
    [self.cacheDictionary setValue:item forKey:key];
}

@end
