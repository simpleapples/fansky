//
//  SAMessage+CoreDataProperties.h
//  fansky
//
//  Created by Zzy on 16/4/23.
//  Copyright © 2016年 Zzy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SAMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAMessage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSString *messageID;
@property (nullable, nonatomic, retain) NSString *recipientID;
@property (nullable, nonatomic, retain) NSString *senderID;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSSet<SAConversation *> *conversations;
@property (nullable, nonatomic, retain) NSSet<SAUser *> *localUsers;
@property (nullable, nonatomic, retain) SAUser *recipient;
@property (nullable, nonatomic, retain) SAUser *sender;

@end

@interface SAMessage (CoreDataGeneratedAccessors)

- (void)addConversationsObject:(SAConversation *)value;
- (void)removeConversationsObject:(SAConversation *)value;
- (void)addConversations:(NSSet<SAConversation *> *)values;
- (void)removeConversations:(NSSet<SAConversation *> *)values;

- (void)addLocalUsersObject:(SAUser *)value;
- (void)removeLocalUsersObject:(SAUser *)value;
- (void)addLocalUsers:(NSSet<SAUser *> *)values;
- (void)removeLocalUsers:(NSSet<SAUser *> *)values;

@end

NS_ASSUME_NONNULL_END
