//
//  SAConstants.m
//  fansky
//
//  Created by Zzy on 6/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SAConstants.h"

NSString *const SA_APP_DOMAIN = @"com.zangzhiya.fansky";

NSString *const SA_API_BASE_HOST = @"fanfou.com";
NSString *const SA_API_COMSUMER_KEY = @"f1a7f5a8dc2faa0342bb8121de2f9b07";
NSString *const SA_API_COMSUMER_SECRET = @"6763155636ac7029f91cc7691d0e7939";
NSString *const SA_API_ACCESS_TOKEN_PATH = @"/oauth/access_token";
NSString *const SA_API_REQUEST_TOKEN_PATH = @"/oauth/request_token";
NSString *const SA_API_AUTHORIZE_PATH = @"/oauth/authorize";
NSString *const SA_API_AUTHORIZE_CALLBACK_URL = @"fansky://authorize-success";

NSString *const SA_API_HOST = @"api.fanfou.com";
NSString *const SA_API_VERIFY_CREDENTIALS_PATH = @"/account/verify_credentials.json";

NSString *const SA_API_HOME_TIMELINE_PATH = @"/statuses/home_timeline.json";
NSString *const SA_API_USER_TIMELINE_PATH = @"/statuses/user_timeline.json";
NSString *const SA_API_UPDATE_STATUS_PATH = @"/statuses/update.json";
NSString *const SA_API_UPDATE_PHOTO_STATUS_PATH = @"/photos/upload.json";
NSString *const SA_API_USER_PHOTO_TIMELINE_PATH = @"/photos/user_timeline.json";
NSString *const SA_API_DELETE_STATUS_PATH = @"/statuses/destroy.json";
NSString *const SA_API_MENTION_STATUS_PATH = @"/statuses/mentions.json";

NSString *const SA_API_USER_SHOW_PATH = @"/users/show.json";
NSString *const SA_API_FOLLOW_USER_PATH = @"/friendships/create.json";
NSString *const SA_API_UNFOLLOW_USER_PATH = @"/friendships/destroy.json";
NSString *const SA_API_USER_FRIEND_PATH = @"/users/friends.json";
NSString *const SA_API_USER_FOLLOWER_PATH = @"/users/followers.json";

NSString *const SA_API_CONVERSATION_LIST_PATH = @"/direct_messages/conversation_list.json";
NSString *const SA_API_CONVERSATION_PATH = @"/direct_messages/conversation.json";
NSString *const SA_API_SEND_NEW_MESSAGE_PATH = @"/direct_messages/new.json";