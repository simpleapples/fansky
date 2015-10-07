//
//  SAUser.h
//  fansky
//
//  Created by Zzy on 10/7/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SAConversation, SAMessage, SAStatus;

NS_ASSUME_NONNULL_BEGIN

@interface SAUser : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "SAUser+CoreDataProperties.h"
