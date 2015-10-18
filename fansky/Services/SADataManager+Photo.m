//
//  SADataManager+Photo.m
//  fansky
//
//  Created by Zzy on 9/14/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SADataManager+Photo.h"
#import "SAPhoto.h"

@implementation SADataManager (Photo)

static NSString *const ENTITY_NAME = @"SAPhoto";

- (SAPhoto *)insertPhotoWithObject:(id)object
{
    NSString *imageURL = [object objectForKey:@"imageurl"];
    NSString *largeURL = [object objectForKey:@"largeurl"];
    NSString *thumbURL = [object objectForKey:@"thumburl"];
    NSString *photoURL = [object objectForKey:@"url"];
        
    __block SAPhoto *resultPhoto;
    [self.managedObjectContext performBlockAndWait:^{
        SAPhoto *photo = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:self.managedObjectContext];
        photo.imageURL = imageURL;
        photo.largeURL = largeURL;
        photo.thumbURL = thumbURL;
        photo.photoURL = photoURL;
        resultPhoto = photo;
    }];
    return resultPhoto;
}

- (SAPhoto *)photoWithObject:(id)object
{
    NSString *imageURL = [object objectForKey:@"imageurl"];
    NSString *largeURL = [object objectForKey:@"largeurl"];
    NSString *thumbURL = [object objectForKey:@"thumburl"];
    NSString *photoURL = [object objectForKey:@"url"];
    
    SAPhoto *photo = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:self.managedObjectContext];
    photo.imageURL = imageURL;
    photo.largeURL = largeURL;
    photo.thumbURL = thumbURL;
    photo.photoURL = photoURL;
    return photo;
}

@end
