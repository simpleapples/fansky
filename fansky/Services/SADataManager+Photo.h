//
//  SADataManager+Photo.h
//  fansky
//
//  Created by Zzy on 9/14/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SADataManager.h"

@class SAPhoto;

@interface SADataManager (Photo)

- (SAPhoto *)insertOrUpdatePhotoWithObject:(id)object statusID:(NSString *)statusID;
- (SAPhoto *)photoWithObject:(id)object;

@end
