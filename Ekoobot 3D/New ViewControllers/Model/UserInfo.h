//
//  UserInfo.h
//  CaracolPlay
//
//  Created by Developer on 8/04/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *role;
@property (assign, nonatomic) BOOL sendEmailAsAuth;
+(UserInfo *)sharedInstance;
@end
