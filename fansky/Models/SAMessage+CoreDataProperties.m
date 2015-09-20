//
//  SAMessage+CoreDataProperties.m
//  fansky
//
//  Created by Zzy on 9/20/15.
//  Copyright © 2015 Zzy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SAMessage+CoreDataProperties.h"

@implementation SAMessage (CoreDataProperties)

@dynamic messageID;
@dynamic text;
@dynamic createdAt;
@dynamic sender;
@dynamic recipient;
@dynamic localUser;

@end
