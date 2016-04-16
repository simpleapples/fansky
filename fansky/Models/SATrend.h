//
//  SATrend.h
//  fansky
//
//  Created by Zzy on 16/4/16.
//  Copyright © 2016年 Zzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SATrend : NSObject

@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSString *query;
@property (copy, nonatomic, readonly) NSString *url;

- (instancetype)initWithObject:(id)object;

@end
