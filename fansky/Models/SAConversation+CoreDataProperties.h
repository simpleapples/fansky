//
//  SAConversation+CoreDataProperties.h
//  fansky
//
//  Created by Zzy on 16/3/25.
//  Copyright © 2016年 Zzy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SAConversation.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAConversation (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *count;
@property (nullable, nonatomic, retain) NSNumber *isNew;
@property (nullable, nonatomic, retain) NSString *otherUserID;
@property (nullable, nonatomic, retain) SAUser *localUser;
@property (nullable, nonatomic, retain) SAMessage *message;

@end

NS_ASSUME_NONNULL_END
