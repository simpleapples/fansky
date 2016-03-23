//
//  SADataManager.h
//  fansky
//
//  Created by Zzy on 16/3/21.
//  Copyright © 2016年 Zzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLMRealm;

@interface SADataManager : NSObject

@property (strong, nonatomic, readonly) RLMRealm *defaultRealm;

+ (SADataManager *)sharedManager;

@end
