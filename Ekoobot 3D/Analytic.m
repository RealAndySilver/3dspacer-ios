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
@synthesize year,day,hour,minute,seconds,month,projectId,token,userId,username,amPm;
-(void)sendAnalyticWithProjectId:(NSString*)theProjectId
                        username:(NSString*)theUsername
                          userId:(NSString*)theUserId
                        andPass:(NSString *)thePassword{
    projectId=theProjectId;
    year=[self getDatePieceFormatted:@"YYYY"];
    month=[self getDatePieceFormatted:@"MM"];
    day=[self getDatePieceFormatted:@"dd"];
    hour=[self getDatePieceFormatted:@"HH"];
    minute=[self getDatePieceFormatted:@"mm"];
    seconds=[self getDatePieceFormatted:@"ss"];
    amPm=[self getDatePieceFormatted:@"a"];
    username=theUsername;
    userId=theUserId;
    token=@"Token";
    
    SqlHandler *handler=[[SqlHandler alloc]init];
    [handler InsertAnalytic:self];
    
    //[handler deleteTable];

    NSArray *array=[handler getPendingProjects];
    NSString *appendedString=@"";
    for (Analytic *analytic in array) {
        NSLog(@"Analytic :\n%@\n",[self convertAnalyticInDictionary:analytic]);
        appendedString=[appendedString stringByAppendingString:[NSString stringWithFormat:@"<item><id_proyect>%@</id_proyect><id_user>%@</id_user><date>%@-%@-%@ %@:%@:%@</date></item>",analytic.projectId,analytic.userId,analytic.year,analytic.month,analytic.day,analytic.hour,analytic.minute,analytic.seconds]];
    }
    
    ServerCommunicator *server=[[ServerCommunicator alloc]init];
    server.caller=self;
    server.tag=1;
    NSString *loginData=[NSString stringWithFormat:@"%@~%@~%@",theUsername,thePassword,[IAmCoder dateString]];
     NSString *parameters=[NSString stringWithFormat:@"<ns:setAnalytics><data>%@</data><token>%@</token><statistics><projectsStatistic>%@</projectsStatistic></statistics></ns:setAnalytics>",loginData,[IAmCoder hash256:loginData],appendedString];
    NSLog(@"Parametros %@",parameters);
    [server callServerWithMethod:@"" andParameter:parameters];
}
-(NSDictionary*)convertAnalyticInDictionary:(Analytic*)analytic{
    NSMutableDictionary *tempDic=[[NSMutableDictionary alloc]init];
    [tempDic setObject:analytic.projectId forKey:@"projectId"];
    [tempDic setObject:analytic.year forKey:@"year"];
    [tempDic setObject:analytic.month forKey:@"month"];
    [tempDic setObject:analytic.day forKey:@"day"];
    [tempDic setObject:analytic.hour forKey:@"hour"];
    [tempDic setObject:analytic.minute forKey:@"minute"];
    [tempDic setObject:analytic.seconds forKey:@"seconds"];
    [tempDic setObject:analytic.amPm forKey:@"amPm"];
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
#pragma mark server response
-(void)receivedDataFromServerAnalytics:(ServerCommunicator*)server{
    NSLog(@"Server response %@",server.resDic);
    if ([[server.resDic objectForKey:@"return"] isEqualToString:@"success"]) {
        NSLog(@"Success dude!");
        SqlHandler *handler=[[SqlHandler alloc]init];
        [handler deleteTable];
    }
}
-(void)receivedDataFromServerWithError:(ServerCommunicator*)server{
    
}
@end
