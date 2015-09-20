//
//  SAMessageListViewController.m
//  fansky
//
//  Created by Zzy on 9/20/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SAMessageListViewController.h"
#import "SADataManager+Message.h"
#import "SAMessage+CoreDataProperties.h"
#import "SAMessageDisplayUtils.h"
#import "SADataManager+User.h"
#import "SAUser+CoreDataProperties.h"
#import "SAAPIService.h"
#import "SAMessageCell.h"
#import "SAMessageViewController.h"

@interface SAMessageListViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (copy, nonatomic) NSString *selectedUserID;

@end

@implementation SAMessageListViewController

static NSString *const ENTITY_NAME = @"SAMessage";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateInterface];
    
    [self fetchedResultsController];
    
    [self refreshData];
}

- (void)refreshData
{
    [self updateDataWithRefresh:YES];
}

- (void)updateDataWithRefresh:(BOOL)refresh
{
    NSString *maxID = nil;
    if (!refresh) {
        SAMessage *lastMessage = self.fetchedResultsController.fetchedObjects.lastObject;
        if (lastMessage) {
            maxID = lastMessage.messageID;
        }
    }
    [SAMessageDisplayUtils showActivityIndicatorWithMessage:@"正在刷新"];
    
    [[SAAPIService sharedSingleton] messageInboxWithSinceID:nil maxID:maxID count:20 success:^(id data) {
        [[SADataManager sharedManager] insertMessageWithObjects:data];
        [SAMessageDisplayUtils showSuccessWithMessage:@"刷新完成"];
        [self.refreshControl endRefreshing];
    } failure:^(NSString *error) {
        [SAMessageDisplayUtils showErrorWithMessage:error];
        [self.refreshControl endRefreshing];
    }];
}

- (void)updateInterface
{
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
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
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"localUser.userID = %@", currentUser.userID];
        fetchRequest.sortDescriptors = sortArray;
        fetchRequest.returnsObjectsAsFaults = NO;
        fetchRequest.fetchBatchSize = 6;
        
        NSString *cacheName = [NSString stringWithFormat:@"user-%@-message", currentUser.userID];
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:manager.managedObjectContext sectionNameKeyPath:nil cacheName:cacheName];
        _fetchedResultsController.delegate = self;
        
        [_fetchedResultsController performFetch:nil];
    }
    return _fetchedResultsController;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SAMessageViewController class]]) {
        SAMessageViewController *messageViewController = (SAMessageViewController *)segue.destinationViewController;
    }
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
    static NSString *const cellName = @"SAMessageCell";
    SAMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    SAMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
    [cell configWithMessage:message];
//    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.selectedUserID = message.recipient.userID;
    [self performSegueWithIdentifier:@"MessageListToMessageSegue" sender:nil];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[SAMessageCell class]]) {
        SAMessageCell *messageCell = (SAMessageCell *)cell;
        [messageCell loadImage];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (fabs(scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y) < 1.f) {
        [self updateDataWithRefresh:NO];
    }
}


@end
