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
#import "SAStatus.h"
#import "SAAPIService.h"

@interface SAPhotoTimeLineViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation SAPhotoTimeLineViewController

static NSString *const ENTITY_NAME = @"SAStatus";

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self updateData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updateData
{
    SAStatus *lastStatus = self.fetchedResultsController.fetchedObjects.lastObject;
    NSString *maxID = nil;
    if (lastStatus) {
        maxID = lastStatus.statusID;
    }
    [[SAAPIService sharedSingleton] userPhotoTimeLineWithUserID:self.userID sinceID:nil maxID:maxID count:20 success:^(id data) {
        [[SADataManager sharedManager] insertStatusWithObjects:data isHomeTimeLine:NO];
    } failure:^(NSError *error) {
        
    }];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        SADataManager *manager = [SADataManager sharedManager];
        
        NSSortDescriptor *createdAtSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
        NSArray *sortArray = [[NSArray alloc] initWithObjects: createdAtSortDescriptor, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user.userID = %@ AND homeLine = %@", self.userID, @(NO)];
        fetchRequest.sortDescriptors = sortArray;
        fetchRequest.returnsObjectsAsFaults = NO;
        fetchRequest.fetchBatchSize = 6;
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:manager.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
        
        [_fetchedResultsController performFetch:nil];
    }
    return _fetchedResultsController;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (collectionView.frame.size.width - 20) / 3 - 10;
    return CGSizeMake(width, width);
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeInsert) {
        if (controller.fetchedObjects.count) {
            [self.collectionView performBatchUpdates:^{
                [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            } completion:nil];
        } else {
            [self.collectionView reloadData];
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.fetchedResultsController.sections.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfItems = [[self.fetchedResultsController.sections objectAtIndex:section] numberOfObjects];
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SAPhotoTimeLineCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SAPhotoTimeLineCell" forIndexPath:indexPath];
    if (cell) {
        SAStatus *status = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [cell configWithStatus:status];
//        cell.delegate = self;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    SAPhotoTimeLineCell *photoTimeLineCell = (SAPhotoTimeLineCell *)cell;
    [photoTimeLineCell loadImage];
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

@end
