//
//  SASearchViewController.m
//  fansky
//
//  Created by Zzy on 10/27/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SASearchViewController.h"
#import "SAMessageDisplayUtils.h"
#import "SAStatus+CoreDataProperties.h"
#import "SADataManager+Status.h"
#import "SAUser+CoreDataProperties.h"
#import "SADataManager+User.h"
#import "SAAPIService.h"
#import "SATimeLineCell.h"
#import "SAStatusViewController.h"
#import "SAUserViewController.h"
#import "SAPhoto+CoreDataProperties.h"
#import "SAComposeViewController.h"
#import "SACacheManager.h"
#import "SAPhotoPreviewViewController.h"
#import "SATrend.h"
#import "SATrendCell.h"
#import "UIColor+Utils.h"
#import <DTCoreText/DTCoreText.h>
#import <JTSImageViewController/JTSImageViewController.h>
#import <SDWebImage/SDImageCache.h>

@interface SASearchViewController () <SATimeLineCellDelegate, UITextFieldDelegate, JTSImageViewControllerInteractionsDelegate, UIViewControllerPreviewingDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) NSArray *resultList;
@property (copy, nonatomic) NSString *maxID;
@property (strong, nonatomic) SAStatus *selectedStatus;
@property (copy, nonatomic) NSString *selectedUserID;

@end

@implementation SASearchViewController

static NSUInteger TIME_LINE_COUNT = 40;
static NSString *const trendCellName = @"SATrendCell";
static NSString *const timeLineCellName = @"SATimeLineCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateInterface];
    
    if (self.type == SASearchViewControllerTypeTrend) {
        [self.searchTextField becomeFirstResponder];
        [[SAAPIService sharedSingleton] trendsWithSuccess:^(id data) {
            NSMutableArray *tempTrendsList = [[NSMutableArray alloc] init];
            NSArray *trends = [data objectForKey:@"trends"];
            [trends enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                SATrend *trend = [[SATrend alloc] initWithObject:obj];
                [tempTrendsList addObject:trend];
            }];
            self.resultList = tempTrendsList;
            [self.tableView reloadData];
        } failure:nil];
    } else if (self.type == SASearchViewControllerTypeSearch) {
        if (self.keyword) {
            self.searchTextField.text = self.keyword;
            [self refreshSearchResult];
        } else {
            [self.searchTextField becomeFirstResponder];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [self.tableView setEditing:NO animated:NO];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (![self.presentedViewController isKindOfClass:[JTSImageViewController class]]) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
    [SAMessageDisplayUtils dismiss];
}

- (void)refreshSearchResult
{
    [self updateSearchResultWithRefresh:YES];
}

- (void)updateSearchResultWithRefresh:(BOOL)refresh
{
    NSString *maxID;
    if (!refresh) {
        maxID = self.maxID;
    } else if (self.resultList.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    void (^success)(id data) = ^(id data) {
        NSArray *originalList = (NSArray *)data;
        __block NSMutableArray *tempTimeLineList = [[NSMutableArray alloc] init];
        [originalList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SAStatus *status = [[SADataManager sharedManager] statusWithObject:obj localUsers:nil type:SAStatusTypeFavoriteStatus];
            [tempTimeLineList addObject:status];
        }];
        if (refresh) {
            self.resultList = tempTimeLineList;
        } else {
            self.resultList = [self.resultList arrayByAddingObjectsFromArray:tempTimeLineList];
        }
        if (self.resultList.count) {
            SAStatus *lastStatus = [self.resultList lastObject];
            self.maxID = lastStatus.statusID;
        }
        [self.tableView reloadData];
        self.activityIndicator.hidden = YES;
    };
    void (^failure)(NSString *error) = ^(NSString *error) {
        [SAMessageDisplayUtils showErrorWithMessage:error];
        self.activityIndicator.hidden = YES;
    };
    
    self.activityIndicator.hidden = NO;
    [[SAAPIService sharedSingleton] searchPublicTimeLineWithKeyword:self.keyword sinceID:nil maxID:maxID count:TIME_LINE_COUNT success:success failure:failure];
}

- (void)updateInterface
{
    if (self.type == SASearchViewControllerTypeTrend) {
        [self.tableView registerNib:[UINib nibWithNibName:trendCellName bundle:nil] forCellReuseIdentifier:trendCellName];
    } else {
        [self.tableView registerNib:[UINib nibWithNibName:timeLineCellName bundle:nil] forCellReuseIdentifier:timeLineCellName];
    }
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
        statusViewController.status = self.selectedStatus;
    } else if ([segue.destinationViewController isKindOfClass:[SAUserViewController class]]) {
        SAUserViewController *userViewController = (SAUserViewController *)segue.destinationViewController;
        userViewController.userID = self.selectedUserID;
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

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [SAMessageDisplayUtils showErrorWithMessage:@"保存失败"];
    } else {
        [SAMessageDisplayUtils showSuccessWithMessage:@"已保存到相册"];
    }
}

- (NSArray *)resultList
{
    if (!_resultList) {
        _resultList = [[NSArray alloc] init];
    }
    return _resultList;
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
        photoPreviewViewController.status = timeLineCell.status;
        return photoPreviewViewController;
    }
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    SAPhotoPreviewViewController *photoPreviewViewController = (SAPhotoPreviewViewController *)viewControllerToCommit;
    SAStatus *status = [[SADataManager sharedManager] statusWithID:photoPreviewViewController.status.statusID];
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length) {
        self.keyword = textField.text;
        [self.view endEditing:YES];
        [self refreshSearchResult];
        return YES;
    }
    [SAMessageDisplayUtils showInfoWithMessage:@"请输入要搜索的内容"];
    return NO;
}

#pragma mark - SATimeLineCellDelegate

- (void)timeLineCell:(SATimeLineCell *)timeLineCell avatarImageViewTouchUp:(id)sender
{
    self.selectedUserID = timeLineCell.status.user.userID;
    [self performSegueWithIdentifier:@"SearchToUserSegue" sender:nil];
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
        [self performSegueWithIdentifier:@"SearchToUserSegue" sender:nil];
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
    return self.resultList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.type == SASearchViewControllerTypeSearch) {
        SAStatus *status = [self.resultList objectAtIndex:indexPath.row];
        
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
    } else if (self.type == SASearchViewControllerTypeTrend) {
        return 50;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.type == SASearchViewControllerTypeTrend) {
        SATrend *trend = [self.resultList objectAtIndex:indexPath.row];
        SATrendCell *trendCell = [self.tableView dequeueReusableCellWithIdentifier:trendCellName forIndexPath:indexPath];
        [trendCell configWithTrend:trend];
        return trendCell;
    } else if (self.type == SASearchViewControllerTypeSearch) {
        SAStatus *status = [self.resultList objectAtIndex:indexPath.row];
        SATimeLineCell *statusCell = [tableView dequeueReusableCellWithIdentifier:timeLineCellName forIndexPath:indexPath];
        [statusCell configWithStatus:status];
        statusCell.delegate = self;
        return statusCell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.type == SASearchViewControllerTypeTrend) {
        SATrend *trend = [self.resultList objectAtIndex:indexPath.row];
        SASearchViewController *searchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SASearchViewController"];
        searchViewController.type = SASearchViewControllerTypeSearch;
        searchViewController.keyword = trend.query;
        [self.navigationController showViewController:searchViewController sender:nil];
    } else if (self.type == SASearchViewControllerTypeSearch) {
        SAStatus *status = [self.resultList objectAtIndex:indexPath.row];
        self.selectedStatus = status;
        [self performSegueWithIdentifier:@"SearchToStatusSegue" sender:nil];
    }
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
    if (self.type == SASearchViewControllerTypeSearch) {
        SAStatus *status = [self.resultList objectAtIndex:indexPath.row];
        UITableViewRowAction *repostAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"转发" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            SAComposeViewController *composeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SAComposeViewController"];
            composeViewController.repostStatusID = status.statusID;
            [self presentViewController:composeViewController animated:YES completion:nil];
        }];
        repostAction.backgroundColor = [UIColor fanskyBlue];
        UITableViewRowAction *replyAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"回复" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            SAComposeViewController *composeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SAComposeViewController"];
            composeViewController.replyToStatusID = status.statusID;
            [self presentViewController:composeViewController animated:YES completion:nil];
        }];
        replyAction.backgroundColor = [UIColor lightGrayColor];
        return @[repostAction, replyAction];
    }
    return nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.type == SASearchViewControllerTypeSearch) {
        if (fabs(scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y) < scrollView.contentSize.height * 0.3) {
            [self updateSearchResultWithRefresh:NO];
        }
    }
}

#pragma mark - EventHandler

- (IBAction)backButtonTouchUp:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
