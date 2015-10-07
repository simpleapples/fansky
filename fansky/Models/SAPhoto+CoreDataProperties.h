//
//  SAPhoto+CoreDataProperties.h
//  fansky
//
//  Created by Zzy on 10/7/15.
//  Copyright © 2015 Zzy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SAPhoto.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAPhoto (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *imageURL;
@property (nullable, nonatomic, retain) NSString *largeURL;
@property (nullable, nonatomic, retain) NSString *photoURL;
@property (nullable, nonatomic, retain) NSString *thumbURL;
@property (nullable, nonatomic, retain) SAStatus *status;

@end

NS_ASSUME_NONNULL_END
