//
//  SACacheManager.h
//  fansky
//
//  Created by Zzy on 11/12/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SACacheManager : NSObject

+ (SACacheManager *)sharedManager;

- (void)cacheItem:(id)item forKey:(NSString *)key;
- cachedItemForKey:(NSString *)key;

@end
