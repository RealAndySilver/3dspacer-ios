//
//  LoadingViewController.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "LoadingViewController.h"
#import "FileSaver.h"
#import "NavController.h"
#import "UserInfo.h"
#import "MBProgressHUD.h"
#import "ServerCommunicator.h"
#import "Project+ParseInfoFromServer.h"
#import "NavController.h"
#import "LoginViewController.h"
#import "MainCarouselViewController.h"

@interface LoadingViewController () <ServerCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UIManagedDocument *databaseDocument;
@property (strong, nonatomic) NSArray *userProjectsArray;
@property (strong, nonatomic) NSArray *rendersArray;
@end

@implementation LoadingViewController

-(void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.spinner startAnimating];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self performSelector:@selector(checkIfUserExists) withObject:nil afterDelay:1.0];
}

-(void)checkIfUserExists {
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![fileSaver getDictionary:@"UserInfoDic"][@"User"]) {
        [self.spinner stopAnimating];
        
        NSLog(@"No había sesión iniciada con usuario");
        //No existe un usuario guardado
        NavController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"Nav"];
        navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:navController animated:YES completion:nil];
        
    } else {
        NSLog(@"Ya había sesión iniciada con usuario");
        [UserInfo sharedInstance].userName = [fileSaver getDictionary:@"UserInfoDic"][@"User"];
        [UserInfo sharedInstance].password = [fileSaver getDictionary:@"UserInfoDic"][@"Password"];
        NSLog(@"User: %@", [UserInfo sharedInstance].userName);
        NSLog(@"Pass: %@", [UserInfo sharedInstance].password);
        self.userProjectsArray = [fileSaver getDictionary:@"UserInfoDic"][@"Projects"];
        [self startCoreDataSavingProcess];
        //[self getProjectsForUser];
    }
}

#pragma mark - Server Stuff

-(void)getProjectsForUser {
    [self.spinner startAnimating];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"getProjectsByUser" andParameter:@""];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [self.spinner stopAnimating];
    
    if ([methodName isEqualToString:@"getProjectsByUser"]) {
        if (dictionary) {
            if (dictionary[@"code"]) {
                NSLog(@"error");
            } else {
                NSLog(@"Recibí respuesta correcta de getProjectsByUser: %@", dictionary);
                self.userProjectsArray = dictionary[@"projects"];
                self.rendersArray = dictionary[@"renders"];
                [self startCoreDataSavingProcess];
            }
            
        } else {
            NSLog(@"Error en la respuesta de getProjectsByUser: %@", dictionary);
        }
    } else {
        NSLog(@"Error recibiendo respuesta del server");
    }
}

-(void)serverError:(NSError *)error {
    [self.spinner stopAnimating];
    
    NSLog(@"Error en el servidor: %@ %@", error, [error localizedDescription]);
}

#pragma mark - CoreData Stuff

-(void)startCoreDataSavingProcess {
    [self.spinner startAnimating];
    
    //Get the Datababase Document path
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = @"MyDocument";
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
    self.databaseDocument = [[UIManagedDocument alloc] initWithFileURL:url];
    
    //Check if the document exist
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:[url path]];
    if (fileExist) {
        //Open THe Database Document
        [self.databaseDocument openWithCompletionHandler:^(BOOL success){
            if (success) {
                [self databaseDocumentIsReady];
            } else {
                NSLog(@"Could not open the document at %@", url);
            }
        }];
    } else {
        //The documents does not exist on disk, so create it
        [self.databaseDocument saveToURL:self.databaseDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            if (success) {
                [self databaseDocumentIsReady];
            } else {
                NSLog(@"Could not open the document at %@", url);
            }
        }];
    }
}

-(void)databaseDocumentIsReady {
    if (self.databaseDocument.documentState == UIDocumentStateNormal) {
        //Start using the document
        NSManagedObjectContext *context = self.databaseDocument.managedObjectContext;
        NSMutableArray *projectsArray = [[NSMutableArray alloc] initWithCapacity:[self.userProjectsArray count]]; //Of Projects
        for (int i = 0; i < [self.userProjectsArray count]; i++) {
            NSDictionary *projectInfoDic = self.userProjectsArray[i];
            Project *project = [Project projectWithServerInfo:projectInfoDic inManagedObjectContext:context];
            project.imageURL = [self getImageURLOfProjectWithID:project.identifier];
            [projectsArray addObject:project];
        }
        [self goToHomeScreenVCWithProjectsArray:projectsArray];
    }
}

#pragma mark - Custom Methods

-(NSString *)getImageURLOfProjectWithID:(NSNumber *)projectIdentifier {
    NSString *imageURL = nil;
    for (int i = 0; i < [self.rendersArray count]; i++) {
        NSDictionary *renderDic = self.rendersArray[i];
        if ([renderDic[@"project"] intValue] == [projectIdentifier intValue]) {
            imageURL = [@"http://ekoobot.com/new_bot/web/" stringByAppendingString:renderDic[@"url"]];
            break;
        }
    }
    return imageURL;
}

-(void)goToHomeScreenVCWithProjectsArray:(NSMutableArray *)projectsArray {
    [self.spinner stopAnimating];
    
    LoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
    MainCarouselViewController *mainCarousel = [self.storyboard instantiateViewControllerWithIdentifier:@"MainCarousel"];
    mainCarousel.userProjectsArray = projectsArray;
    
    NavController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"Nav"];
    [navController setViewControllers:@[loginVC, mainCarousel] animated:NO];
    navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:navController animated:YES completion:nil];
}

@end
