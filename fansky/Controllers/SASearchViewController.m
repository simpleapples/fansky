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
#import "UIColor+Utils.h"
#import <DTCoreText/DTCoreText.h>
#import <JTSImageViewController/JTSImageViewController.h>
#import <SDWebImage/SDImageCache.h>

@interface SASearchViewController () <SATimeLineCellDelegate, UITextFieldDelegate, JTSImageViewControllerInteractionsDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) NSArray *timeLineList;
@property (copy, nonatomic) NSString *maxID;
@property (copy, nonatomic) NSString *keyword;
@property (copy, nonatomic) NSString *selectedStatusID;
@property (copy, nonatomic) NSString *selectedUserID;

@end

@implementation SASearchViewController

static NSString *const ENTITY_NAME = @"SAStatus";
static NSUInteger TIME_LINE_COUNT = 40;
static NSString *const cellName = @"SATimeLineCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateInterface];
    
    [self.searchTextField becomeFirstResponder];
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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
    [SAMessageDisplayUtils dismiss];
}

- (void)refreshData
{
    [self updateDataWithRefresh:YES];
}

- (void)updateDataWithRefresh:(BOOL)refresh
{
    if (!self.timeLineList) {
        self.timeLineList = [[NSArray alloc] init];
    }
    NSString *maxID;
    if (!refresh) {
        maxID = self.maxID;
    } else if (self.timeLineList.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    void (^success)(id data) = ^(id data) {
        NSArray *originalList = (NSArray *)data;
        __block NSMutableArray *tempTimeLineList = [[NSMutableArray alloc] init];
        [originalList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SAStatus *status = [[SADataManager sharedManager] statusWithObject:obj localUsers:nil type:SAStatusTypeFavoriteStatus];
            [tempTimeLineList addObject:status];
        }];
        if (!refresh) {
            NSMutableArray *existList = [self.timeLineList mutableCopy];
            [existList addObjectsFromArray:tempTimeLineList];
            self.timeLineList = [existList copy];
        } else {
            self.timeLineList = [tempTimeLineList copy];
        }
        if (self.timeLineList.count) {
            SAStatus *lastStatus = [self.timeLineList lastObject];
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
    [self.tableView registerNib:[UINib nibWithNibName:cellName bundle:nil] forCellReuseIdentifier:cellName];
    self.tableView.tableFooterView = [UIView new];
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
        [self refreshData];
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
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:timeLineCell.status.photo.largeURL];
    
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    if (image) {
        imageInfo.image = image;
    } else {
        imageInfo.imageURL = [NSURL URLWithString:timeLineCell.status.photo.largeURL];
    }
    imageInfo.referenceRect = timeLineCell.contentImageView.frame;
    imageInfo.referenceView = timeLineCell.contentImageView.superview;
    
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc] initWithImageInfo:imageInfo mode:JTSImageViewControllerMode_Image backgroundStyle:(JTSImageViewControllerBackgroundOption_Scaled | JTSImageViewControllerBackgroundOption_Blurred)];
    imageViewer.interactionsDelegate = self;
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
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
    [self performSegueWithIdentifier:@"SearchToStatusSegue" sender:nil];
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (fabs(scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y) < scrollView.contentSize.height * 0.3) {
        [self updateDataWithRefresh:NO];
    }
}

#pragma mark - EventHandler

- (IBAction)backButtonTouchUp:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
