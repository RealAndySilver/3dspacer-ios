//
//  Analytic.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 16/12/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerCommunicator.h"
#import "IAmCoder.h"
@interface Analytic : NSObject{
    
}
@property(nonatomic,retain)NSString *projectId;
@property(nonatomic,retain)NSString *year;
@property(nonatomic,retain)NSString *month;
@property(nonatomic,retain)NSString *day;
@property(nonatomic,retain)NSString *hour;
@property(nonatomic,retain)NSString *minute;
@property(nonatomic,retain)NSString *amPm;
@property(nonatomic,retain)NSString *seconds;
@property(nonatomic,retain)NSString *username;
@property(nonatomic,retain)NSString *userId;
@property(nonatomic,retain)NSString *token;
-(void)sendAnalyticWithProjectId:(NSString*)theProjectId
                        username:(NSString*)theUsername
                          userId:(NSString*)theUserId
                        andPass:(NSString*)thePassword;
@end