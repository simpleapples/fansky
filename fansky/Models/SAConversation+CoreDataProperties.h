//
//  SAConversation+CoreDataProperties.h
//  fansky
//
//  Created by Zzy on 9/20/15.
//  Copyright © 2015 Zzy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SAConversation.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAConversation (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *otherUserID;
@property (nullable, nonatomic, retain) NSNumber *count;
@property (nullable, nonatomic, retain) NSNumber *newConversation;
@property (nullable, nonatomic, retain) SAMessage *message;
@property (nullable, nonatomic, retain) SAUser *localUser;

@end

NS_ASSUME_NONNULL_END
