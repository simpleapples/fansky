//
//  SAMessage+CoreDataProperties.m
//  fansky
//
//  Created by Zzy on 10/7/15.
//  Copyright © 2015 Zzy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SAMessage+CoreDataProperties.h"

@implementation SAMessage (CoreDataProperties)

@dynamic createdAt;
@dynamic messageID;
@dynamic text;
@dynamic localUser;
@dynamic recipient;
@dynamic sender;
@dynamic conversation;

@end
