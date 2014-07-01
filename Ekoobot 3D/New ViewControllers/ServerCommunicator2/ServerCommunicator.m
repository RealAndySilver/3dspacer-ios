//
//  ServerCommunicator.m
//  WebConsumer
//
//  Created by Andres Abril on 19/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ServerCommunicator.h"
//#define ENDPOINT @"http://caracol.aws.af.cm/"
//#define ENDPOINT @"http://10.0.1.9:8080"
//#define ENDPOINT @"http://iamstudio-sweetwater.herokuapp.com/"
//#define ENDPOINT @"http://sweetwater.jit.su"
//#define ENDPOINT @"http://appsbetadev.caracolplay.com"
//#define ENDPOINT @"http://apps.caracolplay.com"
#define ENDPOINT @"https://ekoobot.com/new_bot/web/app.php/api/v2_0"

#import "IAmCoder.h"
#import "UserInfo.h"

@implementation ServerCommunicator
@synthesize tag,delegate;
-(id)init {
    self = [super init];
    if (self)
    {
        tag = 0;
    }
    return self;
}
-(void)callServerWithGETMethod:(NSString*)method andParameter:(NSString*)parameter{
    parameter=[parameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    parameter=[parameter stringByExpandingTildeInPath];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@",ENDPOINT,method,parameter]];
    if ([parameter isEqualToString:@""]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",ENDPOINT,method]];
    }
    NSLog(@"URL : %@", [url description]);
	//NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSMutableURLRequest *theRequest = [self getHeaderForUrl:url];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    defaultConfigObject.timeoutIntervalForRequest = 60.0;
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                 delegate:nil
                                                            delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:theRequest
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                                        if(error == nil){
                                                            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                            [self.delegate receivedDataFromServer:dictionary
                                                                                   withMethodName:method];
                                                        }
                                                        else{
                                                            [self.delegate serverError:error];
                                                        }
                                                    }];
    [dataTask resume];
}
-(void)callServerWithPOSTMethod:(NSString *)method andParameter:(NSString *)parameter httpMethod:(NSString *)httpMethod{
    parameter=[parameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    parameter=[parameter stringByExpandingTildeInPath];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",ENDPOINT,method]];
	//NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSMutableURLRequest *theRequest = [self getHeaderForUrl:url];
    [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [theRequest setHTTPMethod:httpMethod];
    NSData *data=[NSData dataWithBytes:[parameter UTF8String] length:[parameter length]];
    [theRequest setHTTPBody: data];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    defaultConfigObject.timeoutIntervalForRequest = 60.0;
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                 delegate:nil
                                                            delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:theRequest
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                                        if(error == nil){
                                                            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                            [self.delegate receivedDataFromServer:dictionary
                                                                                   withMethodName:method];
                                                        }
                                                        else{
                                                            [self.delegate serverError:error];
                                                        }
                                                    }];
    [dataTask resume];
    NSLog(@"URL : %@ \n Body: %@", [url description],[[NSString alloc] initWithData:[theRequest HTTPBody] encoding:NSUTF8StringEncoding]);

}

#pragma mark - http header
-(NSMutableURLRequest*)getHeaderForUrl:(NSURL*)url{
   
    NSString *time = [IAmCoder dateString];
    NSString *email = [UserInfo sharedInstance].email;
    NSString *authString;
    NSString *token;
    if ([UserInfo sharedInstance].sendEmailAsAuth) {
        authString = email;
        token = [NSString stringWithFormat:@"%@~~%@", email, time];
    } else {
        authString = [NSString stringWithFormat:@"%@:%@", [UserInfo sharedInstance].userName, [UserInfo sharedInstance].password];
        token = [NSString stringWithFormat:@"%@~%@~%@", [UserInfo sharedInstance].userName, [UserInfo sharedInstance].password, time];
    }
    NSLog(@"authstring: %@", authString);
    
    
    NSLog(@"token sin hash: %@", token);
    NSString *hashToken = [IAmCoder hash256:token];
    
    NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    NSLog(@"email: %@", email);
    NSLog(@"auth: %@", authString);
    NSLog(@"TS70: %@", time);
    NSLog(@"token: %@", hashToken);
    NSLog(@"language: %@", langID);
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"accept"];
    [theRequest setValue:authString forHTTPHeaderField:@"auth"];
    [theRequest setValue:time forHTTPHeaderField:@"TS70"];
    [theRequest setValue:hashToken forHTTPHeaderField:@"token"];
    [theRequest setValue:langID forHTTPHeaderField:@"language"];
    return theRequest;
}

@end
