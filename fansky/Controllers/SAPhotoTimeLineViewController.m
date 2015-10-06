//
//  SAPhotoTimeLineViewController.m
//  fansky
//
//  Created by Zzy on 9/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SAPhotoTimeLineViewController.h"
#import "SADataManager+Status.h"
#import "SAPhotoTimeLineCell.h"
#import "SAStatus+CoreDataProperties.h"
#import "SAAPIService.h"
#import "SAPhoto.h"
#import "SADataManager+User.h"
#import "SAUser+CoreDataProperties.h"
#import "SAMessageDisplayUtils.h"
#import <URBMediaFocusViewController/URBMediaFocusViewController.h>

@interface SAPhotoTimeLineViewController () <SAPhotoTimeLineCellDelegate>

@property (strong, nonatomic) NSArray *photoTimeLineList;
@property (copy, nonatomic) NSString *maxID;
@property (strong, nonatomic) URBMediaFocusViewController *imageViewController;

@end

@implementation SAPhotoTimeLineViewController

static NSString *const ENTITY_NAME = @"SAStatus";
static NSUInteger PHOTO_TIME_LINE_COUNT = 40;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getLocalData];
    
    [self refreshData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)getLocalData
{
    self.photoTimeLineList = [[SADataManager sharedManager] currentPhotoTimeLineWithUserID:self.userID limit:PHOTO_TIME_LINE_COUNT];
    [self.collectionView reloadData];
}

- (void)refreshData
{
    [self updateDataWithRefresh:YES];
}

- (void)updateDataWithRefresh:(BOOL)refresh
{
    if (!self.photoTimeLineList) {
        self.photoTimeLineList = [[NSArray alloc] init];
    }
    NSString *maxID;
    if (!refresh) {
        maxID = self.maxID;
    } else if (self.photoTimeLineList.count) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
    void (^success)(id data) = ^(id data) {
        [[SADataManager sharedManager] insertOrUpdateStatusWithObjects:data type:SAStatusTypeUserStatus];
        NSUInteger limit = PHOTO_TIME_LINE_COUNT;
        if (!refresh) {
            limit = self.photoTimeLineList.count + PHOTO_TIME_LINE_COUNT;
        }
        self.photoTimeLineList = [[SADataManager sharedManager] currentPhotoTimeLineWithUserID:self.userID limit:limit];
        if (self.photoTimeLineList.count) {
            SAStatus *lastStatus = [self.photoTimeLineList lastObject];
            self.maxID = lastStatus.statusID;
        }
        [self.collectionView reloadData];
    };
    void (^failure)(NSString *error) = ^(NSString *error) {
        [SAMessageDisplayUtils showErrorWithMessage:error];
    };
    
    [SAMessageDisplayUtils showProgressWithMessage:@"正在刷新"];
    [[SAAPIService sharedSingleton] userPhotoTimeLineWithUserID:self.userID sinceID:nil maxID:maxID count:PHOTO_TIME_LINE_COUNT success:success failure:failure];
}

#pragma mark - UICollectionViewDataSource

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (collectionView.frame.size.width - 20) / 3 - 10;
    return CGSizeMake(width, width);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photoTimeLineList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SAPhotoTimeLineCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SAPhotoTimeLineCell" forIndexPath:indexPath];
    if (cell) {
        SAStatus *status = [self.photoTimeLineList objectAtIndex:indexPath.row];
        [cell configWithStatus:status];
        cell.delegate = self;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    SAPhotoTimeLineCell *photoTimeLineCell = (SAPhotoTimeLineCell *)cell;
    [photoTimeLineCell loadImage];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (fabs(scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y) < scrollView.contentSize.height * 0.3) {
        [self updateDataWithRefresh:NO];
    }
}

#pragma mark - ARSegmentControllerDelegate

- (NSString *)segmentTitle
{
    return @"图片";
}

- (UIScrollView *)streachScrollView
{
    return self.collectionView;
}

#pragma mark - SAPhotoTimeLineCellDelegate

- (void)photoTimeLineCell:(SAPhotoTimeLineCell *)photoTimeLineCell imageViewTouchUp:(id)sender
{
    if (!self.imageViewController){
        self.imageViewController = [[URBMediaFocusViewController alloc] init];
        self.imageViewController.shouldDismissOnImageTap = YES;
    }
    NSURL *imageURL = [NSURL URLWithString:photoTimeLineCell.status.photo.largeURL];
    [self.imageViewController showImageFromURL:imageURL fromView:self.view];
}

@end
