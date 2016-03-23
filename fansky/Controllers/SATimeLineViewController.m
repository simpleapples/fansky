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
#import "SAStatus.h"
#import "SAPhoto.h"
#import "SAAPIService.h"
#import "SADataManager+Status.h"
#import "SAStatusViewController.h"
#import "SAUserViewController.h"
#import "SAMessageDisplayUtils.h"
#import "SATimeLineCell.h"
#import "SAComposeViewController.h"
#import "SACacheManager.h"
#import "SAPhotoPreviewViewController.h"
#import "UIColor+Utils.h"
#import <DTCoreText/DTCoreText.h>
#import <JTSImageViewController/JTSImageViewController.h>
#import <SDWebImage/SDImageCache.h>

@interface SATimeLineViewController () <SATimeLineCellDelegate, LGRefreshViewDelegate, JTSImageViewControllerInteractionsDelegate, UIViewControllerPreviewingDelegate>

@property (copy, nonatomic) NSString *maxID;

@end

@implementation SATimeLineViewController

static NSUInteger TIME_LINE_COUNT = 40;
static NSString *const cellName = @"SATimeLineCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateInterface];
    
    [self getLocalData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [self.tableView setEditing:NO animated:NO];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SAMessageDisplayUtils dismiss];
}

- (void)getLocalData
{
    NSString *userID = self.userID;
    SAStatusTypes type = SAStatusTypeUserStatus;
    if (!userID) {
        SAUser *currentUser = [SADataManager sharedManager].currentUser;
        userID = currentUser.userID;
        type = SAStatusTypeTimeLine;
    }
    self.timeLineList = [[SADataManager sharedManager] currentTimeLineWithUserID:userID type:type];
    [self.tableView reloadData];
    [self refreshData];
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
    } else if (self.timeLineList.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    NSString *userID = self.userID;
    SAStatusTypes type = SAStatusTypeUserStatus;
    if (!userID) {
        SAUser *currentUser = [SADataManager sharedManager].currentUser;
        userID = currentUser.userID;
        type = SAStatusTypeTimeLine;
    }
    void (^success)(id data) = ^(id data) {
        [[SADataManager sharedManager] insertOrUpdateStatusWithObjects:data type:type];
        if (self.timeLineList.count) {
            SAStatus *lastStatus = [self.timeLineList lastObject];
            self.maxID = lastStatus.statusID;
        }
        [self.tableView reloadData];
        [self.refreshView endRefreshing];
    };
    void (^failure)(NSString *error) = ^(NSString *error) {
        if (type == SAStatusTypeTimeLine) {
            [SAMessageDisplayUtils showErrorWithMessage:error];
        } else {
            [SAMessageDisplayUtils showInfoWithMessage:error];
        }
        [self.refreshView endRefreshing];
    };
    
    if (type == SAStatusTypeTimeLine) {
        if (refresh) {
            [self.refreshView triggerAnimated:YES];
        }
        [[SAAPIService sharedSingleton] timeLineWithUserID:userID sinceID:nil maxID:maxID count:TIME_LINE_COUNT success:success failure:failure];
    } else {
        if (refresh) {
            [SAMessageDisplayUtils showProgressWithMessage:@"正在刷新"];
        }
        [[SAAPIService sharedSingleton] userTimeLineWithUserID:userID sinceID:nil maxID:maxID count:TIME_LINE_COUNT success:success failure:failure];
    }
}

- (void)updateInterface
{
    if (!self.refreshView) {
        self.refreshView = [[LGRefreshView alloc] initWithScrollView:self.tableView delegate:self];
        self.refreshView.tintColor = [UIColor fanskyBlue];
    }
    [self.tableView registerNib:[UINib nibWithNibName:cellName bundle:nil] forCellReuseIdentifier:cellName];
    self.clearsSelectionOnViewWillAppear = YES;
    self.tableView.tableFooterView = [UIView new];
    
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [SAMessageDisplayUtils showErrorWithMessage:@"保存失败"];
    } else {
        [SAMessageDisplayUtils showSuccessWithMessage:@"已保存到相册"];
    }
}

- (void)showPhotoFromSourceCell:(SATimeLineCell *)timeLineCell photo:(SAPhoto *)photo
{
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:photo.largeURL];
    
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    if (image) {
        imageInfo.image = image;
    } else {
        imageInfo.imageURL = [NSURL URLWithString:photo.largeURL];
    }
    if (timeLineCell) {
        imageInfo.referenceRect = timeLineCell.contentImageView.frame;
        imageInfo.referenceView = timeLineCell.contentImageView.superview;
    }
    
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc] initWithImageInfo:imageInfo mode:JTSImageViewControllerMode_Image backgroundStyle:(JTSImageViewControllerBackgroundOption_Scaled | JTSImageViewControllerBackgroundOption_Blurred)];
    imageViewer.interactionsDelegate = self;
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

#pragma mark - UIViewControllerPreviewingDelegate

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    CGPoint tableViewLocation = [self.tableView convertPoint:location fromView:self.view];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:tableViewLocation];
    SATimeLineCell *timeLineCell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    CGPoint targetPoint = [self.view convertPoint:location toView:timeLineCell];
    CGRect sourceRect = [timeLineCell sourceRectWithLocation:targetPoint];
    
    if (!CGRectEqualToRect(sourceRect, CGRectZero)) {
        previewingContext.sourceRect = [timeLineCell convertRect:sourceRect toView:self.view];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SAOthers" bundle:[NSBundle mainBundle]];
        SAPhotoPreviewViewController *photoPreviewViewController = [storyboard instantiateViewControllerWithIdentifier:@"SAPhotoPreviewViewController"];
        photoPreviewViewController.statusID = timeLineCell.status.statusID;
        return photoPreviewViewController;
    }
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    SAPhotoPreviewViewController *photoPreviewViewController = (SAPhotoPreviewViewController *)viewControllerToCommit;
    SAStatus *status = [[SADataManager sharedManager] statusWithID:photoPreviewViewController.statusID];
    [self showPhotoFromSourceCell:nil photo:status.photo];
}

#pragma mark - JTSImageViewControllerInteractionsDelegate

- (void)imageViewerDidLongPress:(JTSImageViewController *)imageViewer atRect:(CGRect)rect
{
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *saveToAlbumAction = [UIAlertAction actionWithTitle:@"保存到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImageWriteToSavedPhotosAlbum(imageViewer.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:saveToAlbumAction];
    [alertController addAction:cancelAction];
    [imageViewer presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - LGRefreshViewDelegate

- (void)refreshViewRefreshing:(LGRefreshView *)refreshView
{
    [self refreshData];
}

#pragma mark - SATimeLineCellDelegate

- (void)timeLineCell:(SATimeLineCell *)timeLineCell avatarImageViewTouchUp:(id)sender
{
    self.selectedUserID = timeLineCell.status.user.userID;
    [self performSegueWithIdentifier:@"TimeLineToUserSegue" sender:nil];
}

- (void)timeLineCell:(SATimeLineCell *)timeLineCell contentImageViewTouchUp:(id)sender
{
    if (!self.tableView.isEditing) {
        [self showPhotoFromSourceCell:timeLineCell photo:timeLineCell.status.photo];
    }
}

- (void)timeLineCell:(SATimeLineCell *)timeLineCell contentURLTouchUp:(id)sender
{
    NSURL *url = timeLineCell.selectedURL;
    if ([url.host isEqualToString:@"fanfou.com"]) {
        self.selectedUserID = url.lastPathComponent;
        [self performSegueWithIdentifier:@"TimeLineToUserSegue" sender:nil];
    } else if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.timeLineList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAStatus *status = [self.timeLineList objectAtIndex:indexPath.row];
    
    NSNumber *cachedHeight = [[SACacheManager sharedManager] cachedItemForKey:status.statusID];
    if (cachedHeight) {
        return cachedHeight.floatValue;
    }
    
    UIColor *linkColor = [UIColor fanskyBlue];
    
    NSDictionary *optionDictionary = @{DTDefaultFontName: @"HelveticaNeue-Light",
                                       DTDefaultFontSize: @(16),
                                       DTDefaultLinkColor: linkColor,
                                       DTDefaultLinkHighlightColor: linkColor,
                                       DTDefaultLinkDecoration: @(NO),
                                       DTDefaultLineHeightMultiplier: @(1.5)};
    NSAttributedString* attributedString = [[NSAttributedString alloc] initWithHTMLData:[status.text dataUsingEncoding:NSUnicodeStringEncoding] options:optionDictionary documentAttributes:nil];
    
    DTCoreTextLayouter *layouter = [[DTCoreTextLayouter alloc] initWithAttributedString:attributedString];
    
    CGFloat width = self.tableView.frame.size.width - 86;
    CGRect maxRect = CGRectMake(0, 0, width, CGFLOAT_HEIGHT_UNKNOWN);
    NSRange entireString = NSMakeRange(0, attributedString.length);
    DTCoreTextLayoutFrame *layoutFrame = [layouter layoutFrameWithRect:maxRect range:entireString];
    CGFloat offset = 62;
    if (status.photo.imageURL) {
        offset = width / 2 + 16 + 10 + 46;
    }
    CGFloat height = layoutFrame.frame.size.height + offset;
    [[SACacheManager sharedManager] cacheItem:@(height) forKey:status.statusID];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAStatus *status = [self.timeLineList objectAtIndex:indexPath.row];
    SATimeLineCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
    [cell configWithStatus:status];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAStatus *status = [self.timeLineList objectAtIndex:indexPath.row];
    self.selectedStatusID = status.statusID;
    [self performSegueWithIdentifier:@"TimeLineToStatusSegue" sender:nil];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[SATimeLineCell class]]) {
        SATimeLineCell *timeLinePhotoCell = (SATimeLineCell *)cell;
        [timeLinePhotoCell loadAllImages];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAStatus *status = [self.timeLineList objectAtIndex:indexPath.row];
    UITableViewRowAction *repostAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"转发" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SAMain" bundle:[NSBundle mainBundle]];
        SAComposeViewController *composeViewController = [storyboard instantiateViewControllerWithIdentifier:@"SAComposeViewController"];
        composeViewController.repostStatusID = status.statusID;
        [self presentViewController:composeViewController animated:YES completion:nil];
    }];
    repostAction.backgroundColor = [UIColor fanskyBlue];
    UITableViewRowAction *replyAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"回复" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SAMain" bundle:[NSBundle mainBundle]];
        SAComposeViewController *composeViewController = [storyboard instantiateViewControllerWithIdentifier:@"SAComposeViewController"];
        composeViewController.replyToStatusID = status.statusID;
        [self presentViewController:composeViewController animated:YES completion:nil];
    }];
    replyAction.backgroundColor = [UIColor lightGrayColor];
    return @[repostAction, replyAction];
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
    return @"时间线";
}

- (UIScrollView *)streachScrollView
{
    return self.tableView;
}

@end
