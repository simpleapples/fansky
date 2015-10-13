//
//  SAMessage+CoreDataProperties.h
//  fansky
//
//  Created by Zzy on 10/13/15.
//  Copyright © 2015 Zzy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SAMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAMessage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSString *messageID;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSString *senderID;
@property (nullable, nonatomic, retain) NSString *recipientID;
@property (nullable, nonatomic, retain) SAConversation *conversation;
@property (nullable, nonatomic, retain) SAUser *localUser;
@property (nullable, nonatomic, retain) SAUser *recipient;
@property (nullable, nonatomic, retain) SAUser *sender;

@end

NS_ASSUME_NONNULL_END
