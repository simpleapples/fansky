//
//  SAPhoto.h
//  fansky
//
//  Created by Zzy on 9/12/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SAPhoto : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * largeURL;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * photoURL;

@end
