//
//  SADataManager.h
//  fansky
//
//  Created by Zzy on 9/10/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SADataManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (SADataManager *)sharedManager;

- (NSUInteger)sizeOfAllPersistentStore;
- (void)saveContext;

@end
