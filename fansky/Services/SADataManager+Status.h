//
//  SADataManager+Status.h
//  fansky
//
//  Created by Zzy on 9/12/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SADataManager.h"

@class SAStatus;

@interface SADataManager (Status)

- (void)insertStatusWithObjects:(NSArray *)objects;
- (SAStatus *)insertStatusWithObject:(id)object;

@end
