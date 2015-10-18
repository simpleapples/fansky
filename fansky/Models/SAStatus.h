//
//  SAStatus.h
//  fansky
//
//  Created by Zzy on 10/7/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_OPTIONS(NSUInteger, SAStatusTypes)
{
    SAStatusTypeTimeLine = 1 << 0,
    
    SAStatusTypeUserStatus = 1 << 1,
    
    SAStatusTypeMentionStatus = 1 << 2,
    
    SAStatusTypeFavoriteStatus = 1 << 3
};

@class SAPhoto, SAUser;

NS_ASSUME_NONNULL_BEGIN

@interface SAStatus : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "SAStatus+CoreDataProperties.h"
