//
//  SAUserListViewController.m
//  fansky
//
//  Created by Zzy on 9/10/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SAUserListViewController.h"
#import "SADataManager+User.h"
#import "SAUserCell.h"
#import "SAUser+CoreDataProperties.h"

@interface SAUserListViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@end

@implementation SAUserListViewController

static NSString *const ENTITY_NAME = @"SAUser";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateInterface];
    [self fetchedResultsController];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [super viewDidAppear:animated];
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    if (!currentUser) {
        [self performSegueWithIdentifier:@"UserListToAuthNavigationSegue" sender:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updateInterface
{
    self.tableView.tableFooterView = [UIView new];
}

- (IBAction)exitToUserList:(UIStoryboardSegue *)segue
{
    
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        SADataManager *manager = [SADataManager sharedManager];
        
        NSSortDescriptor *userNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
        NSArray *sortArray = [[NSArray alloc] initWithObjects: userNameSortDescriptor, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"local = %@", @(YES)];
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

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    [self.tableView reloadData];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    [self.tableView reloadData];
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
    SAUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SAUserCell" forIndexPath:indexPath];
    if (cell) {
        SAUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [cell configWithUser:user];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [[SADataManager sharedManager] setCurrentUserWithUserID:user.userID];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SAUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[SADataManager sharedManager] deleteUserWithUserID:user.userID];
    }
}

#pragma mark - EventHandler

- (IBAction)addButtonTouchUp:(id)sender
{
    [self performSegueWithIdentifier:@"UserListToAuthNavigationSegue" sender:nil];
}

- (IBAction)editButtonTouchUp:(id)sender
{
    UIBarButtonItem *editButton = (UIBarButtonItem *)sender;
    if ([editButton.title isEqualToString:@"编辑"]) {
        self.tableView.editing = YES;
        editButton.title = @"完成";
    } else if ([editButton.title isEqualToString:@"完成"]) {
        self.tableView.editing = NO;
        editButton.title = @"编辑";
    }
}

@end
