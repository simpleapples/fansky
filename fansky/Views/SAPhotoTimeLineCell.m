//
//  SAPhotoTimeLineCell.m
//  fansky
//
//  Created by Zzy on 9/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SAPhotoTimeLineCell.h"
#import "SAStatus+CoreDataProperties.h"
#import "SAPhoto.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SAPhotoTimeLineCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation SAPhotoTimeLineCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.imageView setImage:nil];
}

- (void)configWithStatus:(SAStatus *)status
{
    self.status = status;
}

- (void)loadImage
{
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.status.photo.imageURL] placeholderImage:nil options:(SDWebImageRetryFailed|SDWebImageLowPriority)];
}

- (IBAction)imageViewTouchUp:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoTimeLineCell:imageViewTouchUp:)]) {
        [self.delegate photoTimeLineCell:self imageViewTouchUp:sender];
    }
}
@end
