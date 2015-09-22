//
//  SAMessageViewController.m
//  fansky
//
//  Created by Zzy on 9/20/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SAMessageViewController.h"
#import "SADataManager+User.h"
#import "SAUser+CoreDataProperties.h"
#import "SADataManager+Message.h"
#import "SAMessage+CoreDataProperties.h"
#import "SAAPIService.h"
#import "SAMessageDisplayUtils.h"
#import "SAMessage+CoreDataProperties.h"
#import <JSQMessagesViewController/JSQMessage.h>
#import <JSQMessagesViewController/UIColor+JSQMessages.h>
#import <JSQMessagesViewController/JSQMessagesBubbleImageFactory.h>
#import <JSQMessagesViewController/JSQSystemSoundPlayer+JSQMessages.h>
#import <JSQSystemSoundPlayer/JSQSystemSoundPlayer.h>

@interface SAMessageViewController () <JSQMessagesCollectionViewDataSource, JSQMessagesCollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) SAUser *currentUser;
@property (strong, nonatomic) SAUser *user;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@end

@implementation SAMessageViewController

static NSString *const ENTITY_NAME = @"SAMessage";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentUser = [SADataManager sharedManager].currentUser;
    self.user = [[SADataManager sharedManager] userWithID:self.userID];
    
    [self updateData];
    
    [self updateInterface];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

- (void)updateInterface
{
    self.title = self.user.name;
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
}

- (void)updateData
{
    SAMessage *lastMessage = self.fetchedResultsController.fetchedObjects.lastObject;
    NSString *maxID = nil;
    if (lastMessage) {
        maxID = lastMessage.messageID;
    }
    [[SAAPIService sharedSingleton] conversationWithUserID:self.userID sinceID:nil maxID:maxID count:60 success:^(id data) {
        [[SADataManager sharedManager] insertMessageWithObjects:data];
        [self.collectionView reloadData];
    } failure:^(NSString *error) {
        [SAMessageDisplayUtils showErrorWithMessage:error];
    }];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        SADataManager *manager = [SADataManager sharedManager];
        
        NSSortDescriptor *createdAtSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:YES];
        NSArray *sortArray = [[NSArray alloc] initWithObjects: createdAtSortDescriptor, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:ENTITY_NAME];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"localUser.userID = %@ AND (sender.userID = %@ OR recipient.userID = %@)", self.currentUser.userID, self.userID, self.userID];
        fetchRequest.sortDescriptors = sortArray;
        fetchRequest.returnsObjectsAsFaults = NO;
        fetchRequest.fetchBatchSize = 6;
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:manager.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
        
        [_fetchedResultsController performFetch:nil];
    }
    return _fetchedResultsController;
}

#pragma mark - 

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger count = [[self.fetchedResultsController.sections objectAtIndex:0] numberOfObjects];
    return count;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SAMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    if ([message.sender.userID isEqualToString:self.senderId]) {
        cell.textView.textColor = [UIColor whiteColor];
    }
    else {
        cell.textView.textColor = [UIColor blackColor];
    }
    cell.textView.linkTextAttributes = @{NSForegroundColorAttributeName: cell.textView.textColor, NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle | NSUnderlinePatternSolid)};
    return cell;
}

#pragma mark - JSQMessagesCollectionViewDataSource

- (NSString *)senderDisplayName
{
    return self.currentUser.name;
}

- (NSString *)senderId
{
    return self.currentUser.userID;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SAMessage *originalMessage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:originalMessage.sender.userID senderDisplayName:originalMessage.sender.name date:originalMessage.createdAt text:originalMessage.text];
    return message;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SAMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([message.sender.userID isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    SAMessage *lastMessage = self.fetchedResultsController.fetchedObjects.lastObject;
    NSString *replyToMessageID = nil;
    if (![lastMessage.sender.userID isEqualToString:senderId]) {
        replyToMessageID = lastMessage.messageID;
    }
    [[SAAPIService sharedSingleton] sendMessageWithUserID:self.userID text:text replyToMessageID:replyToMessageID success:^(id data) {
        
    } failure:^(NSString *error) {
        [SAMessageDisplayUtils showErrorWithMessage:error];
    }];
    
    [self finishSendingMessageAnimated:YES];
}

@end
