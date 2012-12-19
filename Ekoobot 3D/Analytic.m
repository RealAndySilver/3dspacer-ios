//
//  Analytic.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 16/12/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "Analytic.h"
#import "SqlHandler.h"
@implementation Analytic
@synthesize day,hour,minute,month,projectId,token,userId,username;
-(void)sendAnalyticWithProjectId:(NSString*)theProjectId
                        username:(NSString*)theUsername
                          userId:(NSString*)theUserId
                        andToken:(NSString*)theToken{
    projectId=theProjectId;
    month=[self getDatePieceFormatted:@"MM"];
    day=[self getDatePieceFormatted:@"dd"];
    hour=[self getDatePieceFormatted:@"hh"];
    minute=[self getDatePieceFormatted:@"mm"];
    username=theUsername;
    userId=theUserId;
    token=theToken;
    
    SqlHandler *handler=[[SqlHandler alloc]init];
    [handler InsertAnalytic:self];
    
    //[handler deleteTable];

    NSArray *array=[handler getPendingProjects];
    for (Analytic *analytic in array) {
        NSLog(@"Analytic :\n%@\n",[self convertAnalyticInDictionary:analytic]);
    }    
}
-(NSDictionary*)convertAnalyticInDictionary:(Analytic*)analytic{
    NSMutableDictionary *tempDic=[[NSMutableDictionary alloc]init];
    [tempDic setObject:analytic.projectId forKey:@"projectId"];
    [tempDic setObject:analytic.month forKey:@"month"];
    [tempDic setObject:analytic.day forKey:@"day"];
    [tempDic setObject:analytic.hour forKey:@"hour"];
    [tempDic setObject:analytic.minute forKey:@"minute"];
    [tempDic setObject:analytic.username forKey:@"username"];
    [tempDic setObject:analytic.userId forKey:@"userId"];
    [tempDic setObject:analytic.token forKey:@"token"];
    return tempDic;
}
-(NSString*)getDatePieceFormatted:(NSString*)format{
    NSDate *currentDateTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *dateInStringFormated = [dateFormatter stringFromDate:currentDateTime];
    NSLog(@"Date %@ format %@", format,dateInStringFormated);
    return dateInStringFormated;
}
@end
