//
//  SAPhotoTimeLineCell.m
//  fansky
//
//  Created by Zzy on 9/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SAPhotoTimeLineCell.h"
#import "SAStatus.h"
#import "SAPhoto.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SAPhotoTimeLineCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) SAStatus *status;

@end

@implementation SAPhotoTimeLineCell

- (void)configWithStatus:(SAStatus *)status
{
    self.status = status;
}

- (void)loadImage
{
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.status.photo.imageURL]];
}

@end
