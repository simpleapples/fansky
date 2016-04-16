//
//  SATrend.m
//  fansky
//
//  Created by Zzy on 16/4/16.
//  Copyright © 2016年 Zzy. All rights reserved.
//

#import "SATrend.h"

@interface SATrend ()

@property (copy, nonatomic, readwrite) NSString *name;
@property (copy, nonatomic, readwrite) NSString *query;
@property (copy, nonatomic, readwrite) NSString *url;

@end

@implementation SATrend

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Must use initWithObject: instead." userInfo:nil];
}

- (instancetype)initWithObject:(id)object
{
    self = [super init];
    if (self) {
        self.name = [object objectForKey:@"name"];
        self.query = [object objectForKey:@"query"];
        self.url = [object objectForKey:@"url"];
    }
    return self;
}

@end
