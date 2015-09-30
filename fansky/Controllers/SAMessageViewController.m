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

@property (strong, nonatomic) NSArray *messageList;
@property (copy, nonatomic) NSString *maxID;
@property (strong, nonatomic) SAUser *currentUser;
@property (strong, nonatomic) SAUser *user;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@end

@implementation SAMessageViewController

static NSString *const ENTITY_NAME = @"SAMessage";
static NSUInteger MESSAGE_LIST_COUNT = 40;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentUser = [SADataManager sharedManager].currentUser;
    self.user = [[SADataManager sharedManager] userWithID:self.userID];
    
    [self updateInterface];
    
    [self getLocalData];
    
    [self refreshData];
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

- (void)getLocalData
{
    self.messageList = [[SADataManager sharedManager] currentMessageWithUserID:self.userID localUserID:self.currentUser.userID limit:MESSAGE_LIST_COUNT];
    [self.collectionView reloadData];
}

- (void)refreshData
{
    [self updateDataWithRefresh:YES];
}

- (void)updateDataWithRefresh:(BOOL)refresh
{
    [SAMessageDisplayUtils showActivityIndicatorWithMessage:@"正在刷新"];
    
    NSString *maxID;
    if (!refresh) {
        maxID = self.maxID;
    }
    [[SAAPIService sharedSingleton] conversationWithUserID:self.userID sinceID:nil maxID:maxID count:MESSAGE_LIST_COUNT success:^(id data) {
        [[SADataManager sharedManager] insertMessageWithObjects:data];
        self.messageList = [[SADataManager sharedManager] currentMessageWithUserID:self.userID localUserID:self.currentUser.userID limit:MESSAGE_LIST_COUNT];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            [SAMessageDisplayUtils showSuccessWithMessage:@"刷新完成"];
        });
    } failure:^(NSString *error) {
        [SAMessageDisplayUtils showErrorWithMessage:error];
    }];
}

#pragma mark - 

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.messageList.count;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SAMessage *message = [self.messageList objectAtIndex:indexPath.row];
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
    SAMessage *originalMessage = [self.messageList objectAtIndex:indexPath.row];

    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:originalMessage.sender.userID senderDisplayName:originalMessage.sender.name date:originalMessage.createdAt text:originalMessage.text];
    return message;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SAMessage *message = [self.messageList objectAtIndex:indexPath.row];
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
    
    SAMessage *lastMessage = self.messageList.lastObject;
    NSString *replyToMessageID = nil;
    if (![lastMessage.sender.userID isEqualToString:senderId]) {
        replyToMessageID = lastMessage.messageID;
    }
    [[SAAPIService sharedSingleton] sendMessageWithUserID:self.userID text:text replyToMessageID:replyToMessageID success:^(id data) {
        SAUser *currentUser = [SADataManager sharedManager].currentUser;
        [[SADataManager sharedManager] insertOrUpdateMessageWithObject:data localUser:currentUser];
        [self refreshData];
        [self.collectionView reloadData];
    } failure:^(NSString *error) {
        [SAMessageDisplayUtils showErrorWithMessage:error];
    }];
    
    [self finishSendingMessageAnimated:YES];
}

@end
