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
#import "NSString+Utils.h"
#import <MWPhotoBrowser/MWPhotoBrowser.h>

@interface SAPhotoTimeLineViewController () <SAPhotoTimeLineCellDelegate, MWPhotoBrowserDelegate>

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSArray *photoTimeLineList;
@property (copy, nonatomic) NSString *maxID;

@end

@implementation SAPhotoTimeLineViewController

static NSString *const ENTITY_NAME = @"SAStatus";
static NSUInteger PHOTO_TIME_LINE_COUNT = 40;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateInterface];
    
    [self getLocalData];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSArray *selectedItems = [self.collectionView indexPathsForSelectedItems];
    [self.collectionView deselectItemAtIndexPath:selectedItems.firstObject animated:YES];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SAMessageDisplayUtils dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updateInterface
{
    if (!self.refreshControl) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.alpha = 0;
    }
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
}

- (void)getLocalData
{
    [[SADataManager sharedManager] currentPhotoTimeLineWithUserID:self.userID limit:PHOTO_TIME_LINE_COUNT completeHandler:^(NSArray *result) {
        self.photoTimeLineList = result;
        [self.collectionView reloadData];
        [self refreshData];
    }];
    
}

- (void)refreshData
{
    [self updateDataWithRefresh:YES];
}

- (void)updateDataWithRefresh:(BOOL)refresh
{
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
        [[SADataManager sharedManager] currentPhotoTimeLineWithUserID:self.userID limit:limit completeHandler:^(NSArray *result) {
            self.photoTimeLineList = result;
            if (self.photoTimeLineList.count) {
                SAStatus *lastStatus = [self.photoTimeLineList lastObject];
                self.maxID = lastStatus.statusID;
            }
            [self.collectionView reloadData];
            [SAMessageDisplayUtils dismiss];
            [self.refreshControl endRefreshing];
            // 解决刷新后不回弹问题
            if (refresh) {
                self.collectionView.contentOffset = CGPointMake(0, -244);
            }
        }];
    };
    void (^failure)(NSString *error) = ^(NSString *error) {
        [SAMessageDisplayUtils showInfoWithMessage:error];
        [self.refreshControl endRefreshing];
        self.collectionView.contentInset = UIEdgeInsetsMake(244, 0, 0, 0);
    };
    
    if (refresh) {
        [SAMessageDisplayUtils showProgressWithMessage:@"正在刷新"];
    }
    [[SAAPIService sharedSingleton] userPhotoTimeLineWithUserID:self.userID sinceID:nil maxID:maxID count:PHOTO_TIME_LINE_COUNT success:success failure:failure];
}

- (NSArray *)photoTimeLineList
{
    if (!_photoTimeLineList) {
        _photoTimeLineList = [[NSArray alloc] init];
    }
    return _photoTimeLineList;
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
    MWPhotoBrowser *photoBrowserController = [[MWPhotoBrowser alloc] initWithDelegate:self];
    photoBrowserController.displayActionButton = YES;
    photoBrowserController.displayNavArrows = YES;
    [photoBrowserController setCurrentPhotoIndex:[self.collectionView indexPathForCell:photoTimeLineCell].item];
    
    [self.navigationController showViewController:photoBrowserController sender:nil];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return self.photoTimeLineList.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < self.photoTimeLineList.count) {
        SAStatus *status = [self.photoTimeLineList objectAtIndex:index];
        MWPhoto *photo = [[MWPhoto alloc] initWithURL:[NSURL URLWithString:status.photo.largeURL]];
        photo.caption = [status.text flattenHTML];
        return photo;
    }
    return nil;
}

@end
