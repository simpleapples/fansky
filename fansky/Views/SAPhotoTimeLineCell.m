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
@property (weak, nonatomic) IBOutlet UIImageView *iconGIFImageView;

@end

@implementation SAPhotoTimeLineCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.imageView setImage:nil];
    self.iconGIFImageView.hidden = YES;
}

- (void)configWithStatus:(SAStatus *)status
{
    self.status = status;
    
    [self updateInterface];
}

- (void)updateInterface
{
    self.imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)loadImage
{
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.status.photo.largeURL] placeholderImage:[UIImage imageNamed:@"BackgroundImage"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if ([self.status.photo.largeURL hasSuffix:@".gif"]) {
            self.iconGIFImageView.hidden = NO;
            self.imageView.image = image.images.firstObject;
        }
    }];
}

- (IBAction)imageViewTouchUp:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoTimeLineCell:imageViewTouchUp:)]) {
        [self.delegate photoTimeLineCell:self imageViewTouchUp:sender];
    }
}
@end
