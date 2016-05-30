//
//  ShareViewController.m
//  ShareExtension
//
//  Created by Zzy on 16/5/30.
//  Copyright © 2016年 Zzy. All rights reserved.
//

#import "ShareViewController.h"
#import "SAMessageDisplayUtils.h"
#import "SAAPIService.h"

#import "SADataManager.h"
#import "SADataManager+User.h"
#import "SAUser+CoreDataProperties.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (BOOL)isContentValid
{
    if (self.contentText.length > 140) {
        return NO;
    }
    return YES;
}

- (void)didSelectPost
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSData *imageData;
        __block NSString *extraString;
        NSExtensionItem *item = self.extensionContext.inputItems.firstObject;
        for (NSItemProvider *provider in item.attachments) {
            NSString *dataType = provider.registeredTypeIdentifiers.firstObject;
            if ([dataType isEqualToString:@"public.image"]) {
                [provider loadItemForTypeIdentifier:dataType options:nil completionHandler:^(UIImage *image, NSError *error){
                    imageData = UIImageJPEGRepresentation(image, 0.5);
                }];
            } else if ([dataType isEqualToString:@"public.plain-text"]){
                [provider loadItemForTypeIdentifier:dataType options:nil completionHandler:^(NSString *contentText, NSError *error){
                    extraString = contentText;
                }];
            } else if ([dataType isEqualToString:@"public.url"]){
                [provider loadItemForTypeIdentifier:dataType options:nil completionHandler:^(NSURL *url, NSError *error){
                    extraString = url.absoluteString;
                }];
            }
        }
        
        NSString *status = self.contentText;
        if (extraString) {
            status = [NSString stringWithFormat:@"%@ %@", self.contentText, extraString];
        }
        [[SAAPIService sharedSingleton] sendStatus:status replyToStatusID:nil repostStatusID:nil image:imageData success:^(id data) {
            
        } failure:^(NSString *error) {
            NSLog(@"---%@", error);
        }];
    });
    
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    return @[];
}

@end
