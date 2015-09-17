
//
//  TimeLineViewController.m
//  fansky
//
//  Created by Zzy on 6/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SATimeLineViewController.h"
#import "SADataManager+User.h"
#import "SAUser.h"
#import "SATimeLineCell.h"
#import "SAStatus.h"
#import "SAPhoto.h"
#import "SAAPIService.h"
#import "SADataManager+Status.h"
#import "SAStatusViewController.h"
#import "SAUserViewController.h"
#import "SAMessageDisplayUtils.h"
#import <URBMediaFocusViewController/URBMediaFocusViewController.h>

@interface SATimeLineViewController () <NSFetchedResultsControllerDelegate, SATimeLineCellDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (copy, nonatomic) NSString *selectedStatusID;
@property (copy, nonatomic) NSString *selectedUserID;
@property (strong, nonatomic) URBMediaFocusViewController *imageViewController;

@end

@implementation SATimeLineViewController

static NSString *const ENTITY_NAME = @"SAStatus";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateInterface];
    
    [self fetchedResultsController];
    
    [self updateData];
}

- (void)updateData
{
    SAStatus *lastStatus = self.fetchedResultsController.fetchedObjects.lastObject;
    NSString *maxID = nil;
    if (lastStatus) {
        maxID = lastStatus.statusID;
    }
    [SAMessageDisplayUtils showActivityIndicatorWithMessage:@"正在刷新"];
    if (!self.userID) {
        SAUser *currentUser = [SADataManager sharedManager].currentUser;
        [[SAAPIService sharedSingleton] timeLineWithUserID:currentUser.userID sinceID:nil maxID:maxID count:20 success:^(id data) {
            [[SADataManager sharedManager] insertStatusWithObjects:data isHomeTimeLine:YES];
            [SAMessageDisplayUtils showSuccessWithMessage:@"刷新完成"];
        } failure:^(NSString *error) {
            [SAMessageDisplayUtils showErrorWithMessage:@"刷新失败"];
        }];
    } else {
        [[SAAPIService sharedSingleton] userTimeLineWithUserID:self.userID sinceID:nil maxID:maxID count:20 success:^(id data) {
            [[SADataManager sharedManager] insertStatusWithObjects:data isHomeTimeLine:NO];
            [SAMessageDisplayUtils showSuccessWithMessage:@"刷新完成"];
        } failure:^(NSString *error) {
            [SAMessageDisplayUtils showErrorWithMessage:@"刷新失败"];

        }];
    }
}

- (void)updateInterface
{
    self.clearsSelectionOnViewWillAppear = YES;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 140;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        SADataManager *manager = [SADataManager sharedManager];
        
        NSSortDescriptor *createdAtSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
        NSArray *sortArray = [[NSArray alloc] initWithObjects: createdAtSortDescriptor, nil];
        
        SAUser *currentUser = [SADataManager sharedManager].currentUser;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
        NSString *userID;
        BOOL isHomeLine;
        if (self.userID) {
            userID = self.userID;
            isHomeLine = NO;
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user.userID = %@ AND homeLine = %@", userID, @(isHomeLine)];
        } else {
            userID = currentUser.userID;
            isHomeLine = YES;
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"localUser.userID = %@ AND homeLine = %@", userID, @(isHomeLine)];
        }
        fetchRequest.sortDescriptors = sortArray;
        fetchRequest.returnsObjectsAsFaults = NO;
        fetchRequest.fetchBatchSize = 6;
        
        
        NSString *cacheName = [NSString stringWithFormat:@"user-%@-homeline-%zd", userID, isHomeLine];
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:manager.managedObjectContext sectionNameKeyPath:nil cacheName:cacheName];
        _fetchedResultsController.delegate = self;
        
        [_fetchedResultsController performFetch:nil];
    }
    return _fetchedResultsController;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SAStatusViewController class]]) {
        SAStatusViewController *statusViewController = (SAStatusViewController *)segue.destinationViewController;
        statusViewController.statusID = self.selectedStatusID;
    } else if ([segue.destinationViewController isKindOfClass:[SAUserViewController class]]) {
        SAUserViewController *userViewController = (SAUserViewController *)segue.destinationViewController;
        userViewController.userID = self.selectedUserID;
    }
}

#pragma mark - SATimeLineCellDelegate

- (void)timeLineCell:(SATimeLineCell *)timeLineCell avatarImageViewTouchUp:(id)sender
{
    self.selectedUserID = timeLineCell.status.user.userID;
    [self performSegueWithIdentifier:@"TimeLineToUserSegue" sender:nil];
}

- (void)timeLineCell:(SATimeLineCell *)timeLineCell contentImageViewTouchUp:(id)sender
{
    if (!self.imageViewController){
        self.imageViewController = [[URBMediaFocusViewController alloc] init];
    }
    NSURL *imageURL = [NSURL URLWithString:timeLineCell.status.photo.largeURL];
    [self.imageViewController showImageFromURL:imageURL fromView:self.view];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeInsert) {
        if (controller.fetchedObjects.count) {
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            [self.tableView reloadData];
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfItems = [[self.fetchedResultsController.sections objectAtIndex:section] numberOfObjects];
    return numberOfItems;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SATimeLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SATimeLineCell" forIndexPath:indexPath];
    if (cell) {
        SAStatus *status = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [cell configWithStatus:status];
        cell.delegate = self;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAStatus *status = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.selectedStatusID = status.statusID;
    [self performSegueWithIdentifier:@"TimelineToStatusSegue" sender:nil];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    SATimeLineCell *timeLineCell = (SATimeLineCell *)cell;
    [timeLineCell loadAllImages];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (fabs(scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y) < 1.f) {
        [self updateData];
    }
}

#pragma mark - ARSegmentControllerDelegate

- (NSString *)segmentTitle
{
    return @"时间线";
}

- (UIScrollView *)streachScrollView
{
    return self.tableView;
}

@end
