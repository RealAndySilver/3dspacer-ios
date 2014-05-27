//
//  LoginViewController.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "LoginViewController.h"
#import "ServerCommunicator.h"
#import "UserInfo.h"
#import "MBProgressHud.h"
#import "Project+ParseInfoFromServer.h"
#import "FileSaver.h"
#import "MainCarouselViewController.h"
#import "NavController.h"
#import "NSArray+NullReplacement.h"

@interface LoginViewController () <UITextFieldDelegate, ServerCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (strong, nonatomic) UIManagedDocument *databaseDocument;
@property (strong, nonatomic) NSArray *userProjectsArray;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSArray *rendersArray;
@end

@implementation LoginViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [self setupUI];
}

-(void)setupUI {
    self.spinner.hidden = YES;
    //Textfields
    self.usernameTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
    
    //Button
    [self.enterButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Server Stuff

-(void)login {
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    
    [UserInfo sharedInstance].userName = self.usernameTextfield.text;
    [UserInfo sharedInstance].password = self.passwordTextfield.text;
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"getProjectsByUser" andParameter:@""];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [self.spinner stopAnimating];
    self.spinner.hidden = YES;
    if ([methodName isEqualToString:@"getProjectsByUser"]) {
        if (dictionary) {
            if (dictionary[@"code"]) {
                NSLog(@"error: %@", dictionary);
                [[[UIAlertView alloc] initWithTitle:@"Error" message:dictionary[@"message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            } else {
                NSLog(@"Recibí respuesta correcta de getProjectsByUser: %@", dictionary);
                NSArray *projectsArrayWithNulls = dictionary[@"projects"];
                self.userProjectsArray = [projectsArrayWithNulls arrayByReplacingNullsWithBlanks];
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
    self.spinner.hidden = YES;
    if (error.code == -1009) {
        //No Internet
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Your internet conection appears to be offline." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error trying to connecting" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
    NSLog(@"Error en el servidor: %@ %@", error, [error localizedDescription]);
}

#pragma mark - CoreData Stuff

-(void)startCoreDataSavingProcess {
    [self.spinner startAnimating];
    self.spinner.hidden = NO;
    
    //Get the Datababase Document path
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = @"MyDocument";
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
    self.databaseDocument = [[UIManagedDocument alloc] initWithFileURL:url];
    
    //Check if the document exist
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:[url path]];
    if (fileExist) {
        //Open The Database Document
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
            if (!project.imageURL) {
                project.imageURL = [self getImageURLOfProjectWithID:project.identifier];
            }
            
            if (!project.imageData) {
                project.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:project.imageURL]];
            }
            [projectsArray addObject:project];
        }
        [self saveUserInfoOnDiskUsingProjectsArray:self.userProjectsArray];
        [self goToHomeScreenVCWithProjectsArray:projectsArray];
    }
}

-(void)saveUserInfoOnDiskUsingProjectsArray:(NSArray *)projectsArray {
    FileSaver *fileSaver = [[FileSaver alloc] init];
    [fileSaver setDictionary:@{@"User": self.usernameTextfield.text, @"Password" : self.passwordTextfield.text, @"Projects" : self.userProjectsArray} withName:@"UserInfoDic"];
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
    self.spinner.hidden = YES;
    
    NavController *navController = (NavController *)self.navigationController;
    [navController setOrientationType:0];
    [navController forceLandscapeMode];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    MainCarouselViewController *mainCarousel = [self.storyboard instantiateViewControllerWithIdentifier:@"MainCarousel"];
    mainCarousel.userProjectsArray = projectsArray;
    [self.navigationController pushViewController:mainCarousel animated:NO];
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
