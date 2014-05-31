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
@property (weak, nonatomic) IBOutlet UIView *projectContainerVIew;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UIView *userInfoContainerView;
@property (weak, nonatomic) IBOutlet UIView *emailContainerView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (strong, nonatomic) UIManagedDocument *databaseDocument;
@property (strong, nonatomic) NSArray *userProjectsArray;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSArray *rendersArray;
@property (strong, nonatomic) NSString *userRole;
@end

@implementation LoginViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    //Add as an observer of the Keyboard notifications to move the textfields when
    //the keyboard appears.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAppear) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide) name:UIKeyboardWillHideNotification object:nil];
    
    [self setupUI];
}

-(void)setupUI {
    //Project Container view
    self.projectContainerVIew.layer.shadowColor = [UIColor blackColor].CGColor;
    self.projectContainerVIew.layer.shadowOffset = CGSizeMake(5.0, 5.0);
    self.projectContainerVIew.layer.shadowOpacity = 0.9;
    self.projectContainerVIew.layer.shadowRadius = 5.0;
    
    //EmailCOntainerView
    self.emailContainerView.frame = CGRectMake(374.0, 650.0, 276.0, 44.0);
    self.cancelButton.frame = CGRectMake(374.0, 700.0, 70.0, 44.0);
    self.sendButton.frame = CGRectMake(655.0, 650.0, 60.0, 44.0);
    
    //Hidde views
    self.emailContainerView.alpha = 0.0;
    self.sendButton.alpha = 0.0;
    self.cancelButton.alpha = 0.0;
    self.spinner.hidden = YES;
    
    //Textfields
    self.usernameTextfield.tag = 1;
    self.passwordTextfield.tag = 2;
    self.emailTextfield.tag = 3;
    self.usernameTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
    self.emailTextfield.delegate = self;
    
    //Button
    [self.sendButton addTarget:self action:@selector(sendForgotPassword) forControlEvents:UIControlEventTouchUpInside];
    [self.forgotPasswordButton addTarget:self action:@selector(showEmailView) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton addTarget:self action:@selector(showLoginContainerView) forControlEvents:UIControlEventTouchUpInside];
    [self.enterButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Actions

-(void)showLoginContainerView {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.forgotPasswordButton.alpha = 1.0;
                         self.enterButton.alpha = 1.0;
                         self.userInfoContainerView.alpha = 1.0;
                         self.emailContainerView.alpha = 0.0;
                         self.cancelButton.alpha = 0.0;
                         self.sendButton.alpha = 0.0;
                     } completion:^(BOOL finished){}];
}

-(void)showEmailView {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.forgotPasswordButton.alpha = 0.0;
                         self.enterButton.alpha = 0.0;
                         self.userInfoContainerView.alpha = 0.0;
                         self.emailContainerView.alpha = 1.0;
                         self.cancelButton.alpha = 1.0;
                         self.sendButton.alpha = 1.0;
                     } completion:^(BOOL finished){}];
}

#pragma mark - Server Stuff

-(void)sendForgotPassword {
    if (![self.emailTextfield.text length] > 0) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You must specify an email." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [UserInfo sharedInstance].email = self.emailTextfield.text;
    [UserInfo sharedInstance].sendEmailAsAuth = YES;
    [serverCommunicator callServerWithPOSTMethod:@"user/resetting/request" andParameter:@"" httpMethod:@"POST"];
}

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
    [UserInfo sharedInstance].sendEmailAsAuth = NO;
    
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
                self.userRole = dictionary[@"user"][@"role"];
                [UserInfo sharedInstance].role = self.userRole;
                NSLog(@"Role del usuariooo: %@", self.userRole);
                [self startCoreDataSavingProcess];
            }
            
        } else {
            NSLog(@"Error en la respuesta de getProjectsByUser: %@", dictionary);
        }
    } else if ([methodName isEqualToString:@"user/resetting/request"]) {
        if (dictionary) {
            NSLog(@"Recibí respuesta valida del reseteo de contraseña: %@", dictionary);
        } else {
            NSLog(@"La respuesta del reseteo de contraseña fue null: %@", dictionary);
        }
    } else {
        NSLog(@"Error recibiendo respuesta del server");
    }
}

-(void)serverError:(NSError *)error {
    [UserInfo sharedInstance].sendEmailAsAuth = NO;
    
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
    [fileSaver setDictionary:@{@"User": self.usernameTextfield.text, @"Password" : self.passwordTextfield.text, @"Projects" : self.userProjectsArray, @"Role" : self.userRole} withName:@"UserInfoDic"];
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

#pragma mark - Notification Handlers 

-(void)keyboardAppear {
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.userInfoContainerView.transform = CGAffineTransformMakeTranslation(0.0, -600.0);
                         self.forgotPasswordButton.transform = CGAffineTransformMakeTranslation(0.0, -600.0);
                         self.enterButton.transform = CGAffineTransformMakeTranslation(0.0, -600.0);
                         self.emailContainerView.transform = CGAffineTransformMakeTranslation(0.0, -600.0);
                         self.cancelButton.transform = CGAffineTransformMakeTranslation(0.0, -600.0);
                         self.sendButton.transform = CGAffineTransformMakeTranslation(0.0, -600.0);
                     } completion:^(BOOL finished){}];
}

-(void)keyboardHide {
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.userInfoContainerView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                         self.forgotPasswordButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                         self.enterButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                         self.emailContainerView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                         self.sendButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                         self.cancelButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                     } completion:^(BOOL finished){}];
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"returniiing");
    [textField resignFirstResponder];
    if (textField.tag == 1 || textField.tag == 2) {
        [self login];
    } else if (textField.tag == 3) {
        [self sendForgotPassword];
    }
    return YES;
}

@end