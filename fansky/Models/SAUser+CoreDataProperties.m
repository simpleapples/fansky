//
//  SAUser+CoreDataProperties.m
//  fansky
//
//  Created by Zzy on 16/4/23.
//  Copyright © 2016年 Zzy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SAUser+CoreDataProperties.h"

@implementation SAUser (CoreDataProperties)

@dynamic desc;
@dynamic followersCount;
@dynamic friendsCount;
@dynamic isActive;
@dynamic isFollowing;
@dynamic isLocal;
@dynamic isProtected;
@dynamic location;
@dynamic name;
@dynamic profileImageURL;
@dynamic statusCount;
@dynamic token;
@dynamic tokenSecret;
@dynamic userID;
@dynamic createdAt;
@dynamic mineConversations;
@dynamic mineMessages;
@dynamic mineStatuses;
@dynamic recvivedMessages;
@dynamic sentMessages;
@dynamic statuses;

@end
