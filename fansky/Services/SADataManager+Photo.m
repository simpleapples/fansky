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

- (SAPhoto *)insertOrUpdatePhotoWithObject:(id)object
{
    NSString *imageURL = [object objectForKey:@"imageurl"];
    NSString *largeURL = [object objectForKey:@"largeurl"];
    NSString *thumbURL = [object objectForKey:@"thumburl"];
    NSString *photoURL = [object objectForKey:@"url"];
        
    SAPhoto *photo = [[SAPhoto alloc] init];
    photo.imageURL = imageURL;
    photo.largeURL = largeURL;
    photo.thumbURL = thumbURL;
    photo.photoURL = photoURL;
    
    [self.defaultRealm beginWriteTransaction];
    SAPhoto *resultPhoto = [SAPhoto createOrUpdateInRealm:self.defaultRealm withValue:photo];
    [self.defaultRealm commitWriteTransaction];
    return resultPhoto;
}

@end
