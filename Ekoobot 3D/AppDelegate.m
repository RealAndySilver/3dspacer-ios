//
//  AppDelegate.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 4/17/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //[[UIApplication sharedApplication]setStatusBarHidden:YES];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    server=[[ServerCommunicator alloc]init];
    server.caller=self;
    server.tag=1;
    motionManager = [[CMMotionManager alloc] init];
    [SqlHandler createEditableCopyOfDatabaseIfNeeded];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self enviarPendientes];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
-(void)enviarPendientes{
    FileSaver *file=[[FileSaver alloc]init];
    NSDictionary *dic=[file getDictionary:@"SendInfoDictionary"];
    if ([[dic objectForKey:@"SentState"]isEqualToString:@"false"]) {
        NSString *params=[NSString stringWithFormat:@"<ns:%@><username>%@</username><password>%@</password> <language>%@</language><register><name>%@</name><email>%@</email><comments>%@</comments><project>%@</project></register></ns:%@>",[dic objectForKey:@"MethodName"],[dic objectForKey:@"Username"],[dic objectForKey:@"Password"],[dic objectForKey:@"Language"],[dic objectForKey:@"Name"],[dic objectForKey:@"Email"],[dic objectForKey:@"Comment"],[dic objectForKey:@"ProjectID"],[dic objectForKey:@"MethodName"]];
        methodName=[dic objectForKey:@"MethodName"];
        NSLog(@"El diccionario no enviado es %@",dic);
        [server callServerWithMethod:@"" andParameter:params];
    }
    else{
        NSLog(@"No hay pendientes");
    }
}
#pragma mark server methods
-(void)receivedDataFromServerRegister:(id)sender{
    server=sender;
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    [dictionary setObject:@"true" forKey:@"SentState"];
    FileSaver *file=[[FileSaver alloc]init];
    [file setDictionary:dictionary withName:@"SendInfoDictionary"];
    //NSLog(@"Resultado %@",server.resDic );
    NSString *tempMethod=[NSString stringWithFormat:@"ns1:%@Response",methodName];
    NSString *response=[[server.resDic objectForKey:tempMethod]objectForKey:@"return"];
    if ([response isEqualToString:@"success"]) {
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ProyectoEnviado", nil)
                                                        message:NSLocalizedString(@"ProyectoEnviadoExito", nil)
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil,nil];
        [alert show];*/
    }
    else{
        [self errorAlert];
    }
}
-(void)receivedDataFromServerWithError:(id)sender{
    [self errorAlert];
}
-(void)errorAlert{
    /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:NSLocalizedString(@"ProyectoEnviadoNOExito", nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Cancelar", nil)
                                          otherButtonTitles:nil,nil];
    [alert show];*/
}
-(CMMotionManager*)motionManager{
    return motionManager;
}


@end
