//
//  HomeScreenViewController.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 14/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "HomeScreenViewController.h"
#import "iCarousel.h"
#import "Usuario.h"
#import "IAmCoder.h"
#import "SendInfoViewController.h"
#import "MBProgressHud.h"
#import "ProjectDownloader.h"
#import "SlideControlViewController.h"
#import "SlideshowViewController.h"
#import "ProjectsListViewController.h"
#import "ProyectoViewController.h"
#import "ProgressView.h"
#import "Project+AddOn.h"
#import "Project+ParseInfoFromServer.h"
#import "UserInfo.h"
#import "TermsAndConditionsViewController.h"
#import "NSArray+NullReplacement.h"
#import "NSDictionary+NullReplacement.h"
#import "Render+AddOns.h"
#import "Urbanization+AddOns.h"
#import "Group+AddOns.h"
#import "Floor+AddOns.h"
#import "Product+AddOns.h"
#import "Plant+AddOns.h"
#import "Space+AddOns.h"
#import "Finish+AddOns.h"
#import "FinishImage+AddOns.h"
#import "DownloadView.h"
#import "UIImage+Resize.h"
#import "Video+AddOns.h"
#import "ImageSaver.h"
#import "AppDelegate.h"

@interface HomeScreenViewController () <iCarouselDataSource, iCarouselDelegate, TermsAndConditionsDelegate, ServerCommunicatorDelegate, UIAlertViewDelegate, UIActionSheetDelegate, DownloadViewDelegate>
@property (strong, nonatomic) iCarousel *carousel;
@property (strong, nonatomic) NSMutableArray *projectNamesArray;
@property (strong, nonatomic) UIButton *slideShowButton;
@property (strong, nonatomic) UIButton *logoutButton;
@property (strong, nonatomic) UIButton *messageButton;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIWindow *secondWindow;
@property (strong, nonatomic) ProgressView *progressView;
@property (strong, nonatomic) UIManagedDocument *databaseDocument;

//Project objects
@property (strong, nonatomic) NSArray *videoArray;
@property (strong, nonatomic) NSArray *rendersArray;
@property (strong, nonatomic) NSDictionary *urbanizationDic;
@property (strong, nonatomic) NSArray *groupsArray;
@property (strong, nonatomic) NSArray *floorsArray;
@property (strong, nonatomic) NSArray *productsArray;
@property (strong, nonatomic) NSArray *plantsArray;
@property (strong, nonatomic) NSArray *spacesArray;
@property (strong, nonatomic) NSArray *finishesArray;
@property (strong, nonatomic) NSArray *finishesImagesArray;

@property (strong, nonatomic) NSArray *projectMainRendersArray;
@property (strong, nonatomic) NSArray *referenceProjectsArray;
@property (strong, nonatomic) NSString *currentUserName;
@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) DownloadView *downloadView;
@end

@implementation HomeScreenViewController {
    CGRect screenBounds;
    NSUInteger projectToDownloadIndex;
    BOOL getProjectFromTheDatabase;
    BOOL fetchOnlyRenders;
    BOOL downloadEntireProject;
    BOOL downloadWasCancelled;
    BOOL searchingForUpdates;
    BOOL connectionError;
    BOOL firstTimeViewAppears;
}

#pragma mark - Lazy Instantiation

-(UIView *)opacityView {
    if (!_opacityView) {
        _opacityView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024.0, 768.0)];
        _opacityView.backgroundColor = [UIColor blackColor];
        _opacityView.alpha = 0.7;
    }
    return _opacityView;
}

-(DownloadView *)downloadView {
    if (!_downloadView) {
        _downloadView = [[DownloadView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 350/2.0, screenBounds.size.height/2.0 - 250.0/2.0, 350.0, 250.0)];
        _downloadView.delegate = self;
    }
    return _downloadView;
}

-(NSMutableArray *)projectNamesArray {
    if (!_projectNamesArray) {
        _projectNamesArray = [[NSMutableArray alloc] initWithCapacity:[self.userProjectsArray count]];
        for (int i = 0; i < [self.userProjectsArray count]; i++) {
            Project *project = self.userProjectsArray[i];
            [_projectNamesArray addObject:project.name];
        }
    }
    return _projectNamesArray;
}

-(void)lockScreenToLandscape {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.screenIsAllOrientations = NO;
    appDelegate.screenIsLandscapeLeftOnly = NO;
    appDelegate.screenIsLandscapeRightOnly = NO;
}

-(void)unlockScreenToAllOrientations {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.screenIsAllOrientations = YES;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    firstTimeViewAppears = YES;
    //[self lockScreenToLandscape];
    NavController *navController = (NavController *)self.navigationController;
    [navController setOrientationType:0];
    downloadWasCancelled = NO;
    connectionError = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(errorDownloadingReceived:)
                                                 name:@"ErrorDownloadingNotification"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ProjectUpdatedNotificationReceived:)
                                                 name:@"ProjectUpdatedNotification"
                                               object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinished:) name:@"updates" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertViewAppear) name:@"alert" object:nil];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    NSLog(@"screen boundsss:%@", NSStringFromCGRect(screenBounds));
    self.view.backgroundColor = [UIColor whiteColor];
    //[self startMainProjectImagesSavingProcess];
    [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(searchForUpdatesInServer) userInfo:nil repeats:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self) {
        // View is disappearing because a new view controller was pushed onto the stack
        NSLog(@"New view controller was pushed");
    } else if ([viewControllers indexOfObject:self] == NSNotFound) {
        // View is disappearing because it was popped from the stack
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self unlockScreenToAllOrientations];
            
        NavController *navController = (NavController *)self.navigationController;
        [navController setOrientationType:1];
        
        NSLog(@"View controller was popped");
    }
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect screen = [UIScreen mainScreen].bounds;
    NSLog(@"UIScreen: %@", NSStringFromCGRect(screen));
    screenBounds = CGRectMake(0.0, 0.0, screen.size.width, screen.size.height);
    if (firstTimeViewAppears) {
        [self setupUI];
        firstTimeViewAppears = NO;
    }
}

-(void)setupUI {
    //Carousel
    self.carousel = [[iCarousel alloc] initWithFrame:screenBounds];
    self.carousel.delegate = self;
    self.carousel.dataSource = self;
    self.carousel.type = iCarouselTypeCustom;
    self.carousel.scrollSpeed = 0.5;
    self.carousel.bounceDistance = 0.3;
    self.carousel.pagingEnabled = YES;
    self.carousel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.carousel];
    
    //Logout button
    /*UIButton *logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 14.0, 100.0, 44.0)];
    [logoutButton setTitle:NSLocalizedString(@"CerrarSesion", nil) forState:UIControlStateNormal];
    logoutButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    logoutButton.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    logoutButton.titleLabel.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    logoutButton.titleLabel.layer.shadowOpacity = 0.6;
    logoutButton.titleLabel.layer.shadowRadius = 2.0;
    [logoutButton addTarget:self action:@selector(showLogoutAlert) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logoutButton];*/
    
    //Delete button
    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 + 15.0, screenBounds.size.height - 60.0, 40.0, 40.0)];
    [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"delete_icon_phone.png"] forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deleteProject) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.deleteButton];
    
    
    //Meesage button
    self.messageButton = [[UIButton alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 15.0 - 40.0 - 30.0 - 40.0, screenBounds.size.height - 60.0, 40.0, 40.0)];
    [self.messageButton setBackgroundImage:[UIImage imageNamed:@"share_icon_phone.png"] forState:UIControlStateNormal];
    [self.messageButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.messageButton];
    
    //Logout button
    self.logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 + 15.0 + 40.0 + 30.0, screenBounds.size.height - 60.0, 40.0, 40.0)];
    [self.logoutButton setBackgroundImage:[UIImage imageNamed:@"logout_icon_phone.png"] forState:UIControlStateNormal];
    [self.logoutButton addTarget:self action:@selector(showLogoutAlert) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.logoutButton];
    
    //Slideshow button
    self.slideShowButton = [[UIButton alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 15.0 - 40.0, screenBounds.size.height - 60.0, 40.0, 40.0)];
    [self.slideShowButton setBackgroundImage:[UIImage imageNamed:@"tv_icon_phone.png"] forState:UIControlStateNormal];
    [self.slideShowButton addTarget:self action:@selector(startSlideshowProcess) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.slideShowButton];
    
    /*Proyecto *proyecto = self.usuario.arrayProyectos[0];
    if (![proyecto.arrayAdjuntos count] > 0) {
        self.slideShowButton.hidden = YES;
    }*/
    
    //ProgressView
    /*self.progressView=[[ProgressView alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.height, self.navigationController.view.frame.size.width)];
    
    [self.navigationController.view addSubview:self.progressView];
    [self.view bringSubviewToFront:self.progressView];*/
    
    [self.view addSubview:self.opacityView];
    [self.view addSubview:self.downloadView];
    self.opacityView.hidden = YES;
    self.downloadView.hidden = YES;
}

#pragma mark - Actions 

-(void)deleteProject {
    [[[UIActionSheet alloc] initWithTitle:@"¿Are you sure you want to delete this project?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil] showInView:self.view];
}

-(void)goToProjectsList {
    ProjectsListViewController *projectsListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProjectsList"];
    [self.navigationController pushViewController:projectsListVC animated:YES];
}

-(void)startSlideshowProcess {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    /*NSUInteger projectIndex = self.carousel.currentItemIndex;
     
     dispatch_queue_t imageSavingTask = dispatch_queue_create("ImageSaving", NULL);
     dispatch_async(imageSavingTask, ^(){
     [self saveProjectImagesInBackgroundAtIndex:projectIndex];
     dispatch_async(dispatch_get_main_queue(), ^(){
     [MBProgressHUD hideHUDForView:self.view animated:YES];
     [self goToSlideshow];
     });
     });*/
    BOOL userCanPassToSlideshowDirectly = [self userHasDownloadProjectAtIndex:self.carousel.currentItemIndex];
    if (userCanPassToSlideshowDirectly) {
        getProjectFromTheDatabase = YES;
        fetchOnlyRenders = YES;
        [self startSavingProcessInCoreData];
    } else {
        [self getRendersFromServer];
    }
}

/*-(void)goToSlideshow {
    SlideshowViewController *ssVC=[[SlideshowViewController alloc]init];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //ssVC.imagePathArray = [self arrayOfImagePathsFromProjectAtIndex:self.carousel.currentItemIndex];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"slideshow images paths arra: %@", ssVC.imagePathArray);
    //ssVC.imagePathArray = [renderPathArray objectAtIndex:sender.tag-3500];
    
    SlideControlViewController *cVC=[[SlideControlViewController alloc]init];
    cVC=[self.storyboard instantiateViewControllerWithIdentifier:@"SlideControl"];
    if ([[UIScreen screens] count] > 1)
    {
        UIScreen *secondScreen = [[UIScreen screens] objectAtIndex:1];
        NSString *availableModeString;
        
        for (int i = 0; i < secondScreen.availableModes.count; i++)
        {
            availableModeString = [NSString stringWithFormat:@"%f, %f",
                                   ((UIScreenMode *)[secondScreen.availableModes objectAtIndex:i]).size.width,
                                   ((UIScreenMode *)[secondScreen.availableModes objectAtIndex:i]).size.height];
            
            //[[[UIAlertView alloc] initWithTitle:@"Available Mode" message:availableModeString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            availableModeString = nil;
        }
        
        // undocumented value 3 means no overscan compensation
        secondScreen.overscanCompensation = 3;
        self.secondWindow=nil;
        self.secondWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, secondScreen.bounds.size.width, secondScreen.bounds.size.height)];
        self.secondWindow.screen = secondScreen;
        ssVC.window=self.secondWindow;
        self.secondWindow.rootViewController = ssVC;
        self.secondWindow.hidden = NO;
        NSLog(@"Screen %f x %f",ssVC.window.screen.bounds.size.height,ssVC.window.screen.bounds.size.width);
        cVC.modalPresentationStyle = UIModalPresentationFormSheet;
        [self.navigationController presentViewController:cVC animated:YES completion:nil];
        
    }
    else{
        
        [self.navigationController pushViewController:ssVC animated:YES];
    }
}*/

-(void)goToSlideshowWithRendersArray:(NSMutableArray *)rendersArray {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSMutableArray *renderImagesArray = [NSMutableArray arrayWithCapacity:[rendersArray count]];
    for (int i = 0; i < [rendersArray count]; i++) {
        Render *render = rendersArray[i];
        NSString *imageDir = [docDir stringByAppendingPathComponent:render.renderPath];
        UIImage *image = [UIImage imageWithContentsOfFile:imageDir];
        [renderImagesArray addObject:image];
    }
    
    SlideshowViewController *ssVC=[[SlideshowViewController alloc]init];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //ssVC.imagePathArray = [self arrayOfImagePathsFromProjectAtIndex:self.carousel.currentItemIndex];
    ssVC.imagesArray = renderImagesArray;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"slideshow images paths arra: %@", ssVC.imagePathArray);
    //ssVC.imagePathArray = [renderPathArray objectAtIndex:sender.tag-3500];
    SlideControlViewController *cVC=[[SlideControlViewController alloc]init];
    cVC=[self.storyboard instantiateViewControllerWithIdentifier:@"SlideControl"];
    if ([[UIScreen screens] count] > 1)
    {
        UIScreen *secondScreen = [[UIScreen screens] objectAtIndex:1];
        NSString *availableModeString;
        
        for (int i = 0; i < secondScreen.availableModes.count; i++)
        {
            availableModeString = [NSString stringWithFormat:@"%f, %f",
                                   ((UIScreenMode *)[secondScreen.availableModes objectAtIndex:i]).size.width,
                                   ((UIScreenMode *)[secondScreen.availableModes objectAtIndex:i]).size.height];
            
            //[[[UIAlertView alloc] initWithTitle:@"Available Mode" message:availableModeString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            availableModeString = nil;
        }
        
        // undocumented value 3 means no overscan compensation
        secondScreen.overscanCompensation = 3;
        self.secondWindow=nil;
        self.secondWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, secondScreen.bounds.size.width, secondScreen.bounds.size.height)];
        self.secondWindow.screen = secondScreen;
        ssVC.window=self.secondWindow;
        self.secondWindow.rootViewController = ssVC;
        self.secondWindow.hidden = NO;
        NSLog(@"Screen %f x %f",ssVC.window.screen.bounds.size.height,ssVC.window.screen.bounds.size.width);
        cVC.modalPresentationStyle = UIModalPresentationFormSheet;
        [self.navigationController presentViewController:cVC animated:YES completion:nil];
        
    }
    else{
        
        [self.navigationController pushViewController:ssVC animated:YES];
    }
}

-(void)sendMessage {
    Project *project = self.userProjectsArray[self.carousel.currentItemIndex];
    SendInfoViewController *sendInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SendInfo"];
    sendInfoVC.nombreProyecto = project.name;
    sendInfoVC.proyectoID = [NSString stringWithFormat:@"%d", [project.identifier intValue]];
    sendInfoVC.usuario = [UserInfo sharedInstance].userName;
    sendInfoVC.contrasena = [UserInfo sharedInstance].password;
    sendInfoVC.userType = @"sellers"; // ***********************************Corregir estoooooooooo******************************************//
    sendInfoVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    sendInfoVC.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self.navigationController presentViewController:sendInfoVC animated:YES completion:nil];
}

-(void)showLogoutAlert {
    NSString *title=NSLocalizedString(@"CerrarSesion", nil);
    NSString *message=NSLocalizedString(@"CerrarSesionSeguro", nil);
    NSString *cancel=NSLocalizedString(@"Cancelar", nil);;
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:self
                      cancelButtonTitle:cancel
                      otherButtonTitles:@"OK",nil] show];
}

- (void)logout{
    FileSaver *fileSaver = [[FileSaver alloc] init];
    [fileSaver setDictionary:@{} withName:@"UserInfoDic"];
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)goToTermsVC {
    Project *project = self.userProjectsArray[self.carousel.currentItemIndex];
    
    TermsAndConditionsViewController *termsAndConditionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsAndConditions"];
    termsAndConditionsVC.termsString = project.terms;
    termsAndConditionsVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    termsAndConditionsVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:termsAndConditionsVC animated:YES completion:nil];
}

/*-(void)updateProject:(UIButton *)downloadButton {
    projectToDownloadIndex = downloadButton.tag - 1000;
    Proyecto *proyecto = self.usuario.arrayProyectos[projectToDownloadIndex];
    
    self.navigationController.navigationBarHidden = YES;
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    [dic setObject:proyecto forKey:@"Project"];
    [dic setObject:@(2000 + projectToDownloadIndex) forKey:@"Tag"];
    [dic setObject:self.progressView forKey:@"Sender"];
    [dic setObject:self.usuario forKey:@"Usuario"];
    [self performSelectorInBackground:@selector(downloadProject:) withObject:dic];
}

-(void)downloadProject:(NSMutableDictionary*)dic{
    NSLog(@"entré a descargar el proyectooo");
    Proyecto *proyecto=[dic objectForKey:@"Project"];
    if ([proyecto.data isEqualToString:@"1"]) {
        [self.progressView setViewAlphaToOne];
        [ProjectDownloader downloadProject:[dic objectForKey:@"Project"] yTag:[[dic objectForKey:@"Tag"]intValue] sender:self.progressView usuario:[dic objectForKey:@"Usuario"]];
        [self.progressView setViewAlphaToCero];
    }
}*/

#pragma mark - Custom Methods

-(void)goToTermsVCFromDownloadButton {
    Project *project = self.userProjectsArray[self.carousel.currentItemIndex];
    
    TermsAndConditionsViewController *termsAndConditionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsAndConditions"];
    termsAndConditionsVC.termsString = project.terms;
    termsAndConditionsVC.delegate = self;
    termsAndConditionsVC.controllerWasPresentedFromDownloadButton = YES;
    termsAndConditionsVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    termsAndConditionsVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:termsAndConditionsVC animated:YES completion:nil];
}

-(BOOL)isProjectOutdatedAtIndex:(NSUInteger)index {
    Project *project = self.userProjectsArray[index];
    
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if ([fileSaver getDictionary:@"OutdatedProjectIDsDic"][@"OutdatedProjectIDsarray"]) {
        NSArray *outdatedProjectsIDs = [fileSaver getDictionary:@"OutdatedProjectIDsDic"][@"OutdatedProjectIDsarray"];
        if ([outdatedProjectsIDs containsObject:project.identifier]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

-(BOOL)userHasDownloadProjectAtIndex:(NSUInteger)index {
    /*Project *project = self.userProjectsArray[index];
    
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if ([fileSaver getDictionary:@"downloadedProjectsIDs"][@"projectIDsArray"]) {
        NSMutableArray *savedProjectIDs = [fileSaver getDictionary:@"downloadedProjectsIDs"][@"projectIDsArray"];
        for (int i = 0; i < [savedProjectIDs count]; i++) {
            NSNumber *identifier = savedProjectIDs[i];
            if ([project.identifier intValue] == [identifier intValue]) {
                return YES;
            }
        }
        return NO;
    } else {
        return NO;
    }*/
    Project *project = self.userProjectsArray[index];
    
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if ([fileSaver getDictionary:@"downloadedProjectsIDs"][@"projectIDsArray"]) {
        NSMutableArray *savedProjectIDs = [fileSaver getDictionary:@"downloadedProjectsIDs"][@"projectIDsArray"];
        if ([savedProjectIDs containsObject:project.identifier]) {
            return YES;
        }
        /*for (int i = 0; i < [savedProjectIDs count]; i++) {
         NSNumber *identifier = savedProjectIDs[i];
         if ([project.identifier intValue] == [identifier intValue]) {
         return YES;
         }
         }*/
        if ([[UserInfo sharedInstance].role isEqualToString:@"SELLER"]) {
            if ([fileSaver getDictionary:@"OutdatedProjectIDsDic"][@"OutdatedProjectIDsarray"]) {
                NSArray *outdatedProjectIDs = [fileSaver getDictionary:@"OutdatedProjectIDsDic"][@"OutdatedProjectIDsarray"];
                if ([outdatedProjectIDs containsObject:project.identifier]) {
                    return YES;
                }
                /*for (int i = 0; i < [outdatedProjectIDs count]; i++) {
                 NSNumber *outdatedID = outdatedProjectIDs[i];
                 if ([project.identifier intValue] == [outdatedID intValue]) {
                 return YES;
                 }
                 }*/
            }
        }
        return NO;
        
    } else {
        return NO;
    }
}

-(UIImage *)getLogoImageFromProjectAtIndex:(NSUInteger)index {
    Project *project = self.userProjectsArray[index];
    return [project projectLogoImage];
}

-(UIImage *)imageFromProjectAtIndex:(NSUInteger)index {
    Project *project = self.userProjectsArray[index];
    return [project projectMainImage];
}

-(void)goToProjectAtIndex:(NSUInteger)index {
    /*ProyectoViewController *proyectoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Proyecto"];
    proyectoVC.proyecto = self.usuario.arrayProyectos[index];
    proyectoVC.usuario = self.usuario;
    proyectoVC.mainImage = [self projectImageAtIndex:index];
    proyectoVC.projectNumber = index;
    [self.navigationController pushViewController:proyectoVC animated:YES];*/
}

-(NSUInteger)getNumberOfFilesToDownload {
    NSUInteger numberOfFiles = 0;
    numberOfFiles = [self.rendersArray count] + 1 + 1 +[self.groupsArray count] + [self.productsArray count] + [self.floorsArray count] + [self.plantsArray count] + [self.spacesArray count] + [self.finishesArray count] + [self.finishesImagesArray count];
    return numberOfFiles;
}

-(void)goToProjectScreenWithProjectDic:(NSDictionary *)dictionary {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    ProyectoViewController *proyectoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Proyecto"];
    proyectoVC.projectDic = dictionary;
    [self.navigationController pushViewController:proyectoVC animated:YES];
}

-(void)showDownloadingView {
    self.opacityView.hidden = NO;
    self.downloadView.hidden = NO;
}

#pragma mark - Server Stuff

-(void)searchForUpdatesInServer {
    searchingForUpdates = YES;
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"getProjectsByUser" andParameter:@""];
}

-(void)getRendersFromServer {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    downloadEntireProject = NO;
    Project *project = self.userProjectsArray[self.carousel.currentItemIndex];
    NSString *projectID = [NSString stringWithFormat:@"%d", [project.identifier intValue]];
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"getProjectById" andParameter:projectID];
}

-(void)downloadProjectFromServerAtIndex:(NSUInteger)index {
    [self showDownloadingView];
    
    fetchOnlyRenders = NO;
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    downloadEntireProject = YES;
    projectToDownloadIndex = index;
    Project *project = self.userProjectsArray[projectToDownloadIndex];
    NSString *projectID = [NSString stringWithFormat:@"%d", [project.identifier intValue]];
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"getProjectById" andParameter:projectID];
}

-(void)downloadProjectFromServer:(UIButton *)downloadButton {
    [self showDownloadingView];
    
    //Bool that indicates that we are going to download the project
    //from the server, and not access it from our core data data base
    getProjectFromTheDatabase = NO;
    fetchOnlyRenders = NO;
    
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    downloadEntireProject = YES;
    projectToDownloadIndex = downloadButton.tag - 1000.0;
    Project *project = self.userProjectsArray[projectToDownloadIndex];
    NSString *projectID = [NSString stringWithFormat:@"%d", [project.identifier intValue]];
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"getProjectById" andParameter:projectID];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    searchingForUpdates = NO;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if ([methodName isEqualToString:@"getProjectById"]) {
        if (dictionary) {
            NSLog(@"Llegó respuesta del getProjectByID");
            if (dictionary[@"code"]) {
                NSLog(@"Ocurrió algún error y no se devolvió la info");
            } else {
                NSLog(@"Respuesta del getProjectByID: %@", dictionary);
                if (!downloadEntireProject) {
                    //Download only the renders for the slideshow
                    NSArray *arrayWithNulls = dictionary[@"renders"];
                    self.rendersArray = [arrayWithNulls arrayByReplacingNullsWithBlanks];
                    [self startSavingProcessInCoreData];
                    
                } else {
                    //Download entire project
                    self.videoArray = [dictionary[@"videos"] arrayByReplacingNullsWithBlanks];
                    self.rendersArray = [dictionary[@"renders"] arrayByReplacingNullsWithBlanks];
                    self.urbanizationDic = [dictionary[@"urbanization"] dictionaryByReplacingNullWithBlanks];
                    self.groupsArray = [dictionary[@"groups"] arrayByReplacingNullsWithBlanks];
                    self.floorsArray = [dictionary[@"floors"] arrayByReplacingNullsWithBlanks];
                    self.productsArray = [dictionary[@"products"] arrayByReplacingNullsWithBlanks];
                    self.plantsArray = [dictionary[@"plants"] arrayByReplacingNullsWithBlanks];
                    self.spacesArray = [dictionary[@"spaces"] arrayByReplacingNullsWithBlanks];
                    self.finishesArray = [dictionary[@"finishes"] arrayByReplacingNullsWithBlanks];
                    self.finishesImagesArray = [dictionary[@"finishImages"] arrayByReplacingNullsWithBlanks];
                    [self startSavingProcessInCoreData];
                }
                
            }
        }  else {
            NSLog(@"NO llegó respuesta del getProjectById");
        }
        
    } else if ([methodName isEqualToString:@"getProjectsByUser"]) {
        if (dictionary) {
            NSLog(@"Llegó correctamente la respuesta del getProjectsByUser: %@", dictionary);
            self.currentUserName = dictionary[@"user"][@"username"];
            NSLog(@"*** current user: %@", self.currentUserName);
            self.referenceProjectsArray = [dictionary[@"projects"] arrayByReplacingNullsWithBlanks];
            self.projectMainRendersArray = [dictionary[@"renders"] arrayByReplacingNullsWithBlanks];
            [self compareProjectsUpdateDatesUsingReferenceDic:dictionary];
        } else {
            NSLog(@"Llegó Null la respuesta del getProjectsByUser: %@", dictionary);
        }
        
    } else {
        NSLog(@"La respuesta no corresponde con los métodos enviados");
    }
}

-(void)serverError:(NSError *)error {
    self.downloadView.hidden = YES;
    self.opacityView.hidden = YES;
    
    NSLog(@"error en el server con código %d: %@ %@", error.code, error, [error localizedDescription]);
    if (error.code == -1009 && !searchingForUpdates) {
        //Network Error
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You need to be connected to internet to download the latest project version." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        
    }
    searchingForUpdates = NO;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void)compareProjectsUpdateDatesUsingReferenceDic:(NSDictionary *)userProjectsDic {
    NSArray *referenceProjectsArray = userProjectsDic[@"projects"];
    for (int i = 0; i < [self.userProjectsArray count]; i++) {
        Project *project = self.userProjectsArray[i];
        for (int j = 0; j < [referenceProjectsArray count]; j++) {
            NSDictionary *referenceProjectDic = [referenceProjectsArray[j] dictionaryByReplacingNullWithBlanks];
            if ([referenceProjectDic[@"id"] intValue] == [project.identifier intValue]) {
                //We found the projects to compare the dates (the project that we have
                //store in CoreData with the downloaded project from the server)
                [self compareUpdateDateOfProject:project withReferenceProject:referenceProjectDic];
                break;
            }
        }
    }
}

-(void)compareUpdateDateOfProject:(Project *)project withReferenceProject:(NSDictionary *)referenceProjectDic {
    //Check if the project has been download
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if ([fileSaver getDictionary:@"downloadedProjectsIDs"][@"projectIDsArray"]) {
        NSMutableArray *savedProjectIDs = [fileSaver getDictionary:@"downloadedProjectsIDs"][@"projectIDsArray"];
        NSArray *outdatedProjectIDs = [fileSaver getDictionary:@"OutdatedProjectIDsDic"][@"OutdatedProjectIDsarray"];
        if ([savedProjectIDs containsObject:project.identifier] || [outdatedProjectIDs containsObject:project.identifier]) {
            NSLog(@"El proyecto con id %@ esta descargado", project.identifier);
            
            //Check if the project is updated
            if ([project.lastUpdate isEqualToString:referenceProjectDic[@"last_update"]]) {
                //The project is updated, do nothing
                NSLog(@"EL proyecto con id %@ está actualizado", project.identifier);
                NSLog(@"Última actualizacion descargada: %@\nÚltima actualización disponible: %@", project.lastUpdate, referenceProjectDic[@"last_update"]);
            } else {
                //The project is not updated
                NSLog(@"El proyecto con id %@ está desactualizado", project.identifier);
                NSLog(@"Última actualizacion descargada: %@\nÚltima actualización disponible: %@", project.lastUpdate, referenceProjectDic[@"last_update"]);
                
                //Post a notification in case the user is on the project view controller
                //of the outdated project.
                [[NSNotificationCenter defaultCenter] postNotificationName:@"OutdatedProjectNotification"
                                                                    object:nil
                                                                  userInfo:@{@"OutdatedProjectIdentifier": project.identifier}];
                
                //Remove the project id from fileSaver
                [savedProjectIDs removeObject:project.identifier];
                [fileSaver setDictionary:@{@"projectIDsArray": savedProjectIDs} withName:@"downloadedProjectsIDs"];
                
                //Save a file with FileSaver indicating that the project is donwloaded, but outdated
                //This is neccesary because a user with "Seller" role can enter the project, even
                //if it is outdated.
                if ([fileSaver getDictionary:@"OutdatedProjectIDsDic"][@"OutdatedProjectIDsarray"]) {
                    //The dic with the outdated projects ids exist
                    NSMutableArray *outdatedIDsArray = [NSMutableArray arrayWithArray:[fileSaver getDictionary:@"OutdatedProjectIDsDic"][@"OutdatedProjectIDsarray"]];
                    if (![outdatedIDsArray containsObject:project.identifier]) {
                        NSLog(@"Guardé el proyecto %d en el listado existente de desactualizados", [project.identifier intValue]);
                        [outdatedIDsArray addObject:project.identifier];
                    }
                    [fileSaver setDictionary:@{@"OutdatedProjectIDsarray": outdatedIDsArray} withName:@"OutdatedProjectIDsDic"];
                    
                } else {
                    //The dic doenst exist, so create a new one
                    NSLog(@"Guardé el proyecto %d en el listado de desactualizados por primera vez", [project.identifier intValue]);
                    NSMutableArray *outdatedIDsArray = [[NSMutableArray alloc] init];
                    [outdatedIDsArray addObject:project.identifier];
                    [fileSaver setDictionary:@{@"OutdatedProjectIDsarray": outdatedIDsArray} withName:@"OutdatedProjectIDsDic"];
                }
                
                [self carouselDidEndScrollingAnimation:self.carousel];
                [self startUpdatingProjectProcessInCoreDataUsingProjectDic:referenceProjectDic];
            }
            
        } else {
            NSLog(@"El proyecto con id %@ no se ha descargado aún", project.identifier);
        }
        
    } else {
        NSLog(@"No se ha descargado ningún proyecto aún");
    }
}

-(NSString *)getImageURLOfProjectWithID:(NSNumber *)projectIdentifier {
    NSString *imageURL = nil;
    for (int i = 0; i < [self.projectMainRendersArray count]; i++) {
        NSDictionary *renderDic = self.projectMainRendersArray[i];
        if ([renderDic[@"project"] intValue] == [projectIdentifier intValue]) {
            //imageURL = [@"http://ekoobot.com/new_bot/web/" stringByAppendingString:renderDic[@"url"]];
            imageURL = renderDic[@"url"];
            break;
        }
    }
    return imageURL;
}

#pragma mark - CoreData Stuff

-(void)startUpdatingProjectProcessInCoreDataUsingProjectDic:(NSDictionary *)newProjectDic {
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
                if (self.databaseDocument.documentState == UIDocumentStateNormal) {
                    NSManagedObjectContext *context = self.databaseDocument.managedObjectContext;
                    Project *project = [Project projectWithServerInfo:newProjectDic inManagedObjectContext:context];
                    project.imageURL = [self getImageURLOfProjectWithID:project.identifier];
                    project.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:project.imageURL]];
                    for (int i = 0; i < [self.userProjectsArray count]; i++) {
                        Project *theProject = self.userProjectsArray[i];
                        if ([theProject.identifier isEqualToNumber:project.identifier]) {
                            [self.userProjectsArray replaceObjectAtIndex:i withObject:project];
                            break;
                        }
                    }
                    //Save the new project info in FileSaver
                    FileSaver *fileSaver = [[FileSaver alloc] init];
                    if ([fileSaver getDictionary:@"UserInfoDic"]) {
                        NSMutableDictionary *userInfoDic = [NSMutableDictionary dictionaryWithDictionary:[fileSaver getDictionary:@"UserInfoDic"]];
                        [userInfoDic setValue:self.referenceProjectsArray forKey:@"Projects"];
                        [fileSaver setDictionary:userInfoDic withName:@"UserInfoDic"];
                    }
                    
                    if ([fileSaver getDictionary:self.currentUserName]) {
                        NSMutableDictionary *currentUserDic = [NSMutableDictionary dictionaryWithDictionary:[fileSaver getDictionary:self.currentUserName]];
                        [currentUserDic setValue:self.referenceProjectsArray forKey:@"Projects"];
                        [fileSaver setDictionary:currentUserDic withName:self.currentUserName];
                    }
                    [self.carousel reloadData];
                }
                
            } else {
                NSLog(@"Could not open the document at %@", url);
            }
        }];
    } else {
        //The documents does not exist on disk, so create it
        [self.databaseDocument saveToURL:self.databaseDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            if (success) {
                if (self.databaseDocument.documentState == UIDocumentStateNormal) {
                    NSManagedObjectContext *context = self.databaseDocument.managedObjectContext;
                    Project *project = [Project projectWithServerInfo:newProjectDic inManagedObjectContext:context];
                    project.imageURL = [self getImageURLOfProjectWithID:project.identifier];
                    project.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:project.imageURL]];
                    for (int i = 0; i < [self.userProjectsArray count]; i++) {
                        Project *theProject = self.userProjectsArray[i];
                        if ([theProject.identifier isEqualToNumber:project.identifier]) {
                            [self.userProjectsArray replaceObjectAtIndex:i withObject:project];
                            break;
                        }
                    }
                    //Save the new project info in FileSaver
                    FileSaver *fileSaver = [[FileSaver alloc] init];
                    if ([fileSaver getDictionary:@"UserInfoDic"]) {
                        NSMutableDictionary *userInfoDic = [NSMutableDictionary dictionaryWithDictionary:[fileSaver getDictionary:@"UserInfoDic"]];
                        [userInfoDic setValue:self.referenceProjectsArray forKey:@"Projects"];
                        [fileSaver setDictionary:userInfoDic withName:@"UserInfoDic"];
                    }
                    if ([fileSaver getDictionary:self.currentUserName]) {
                        NSMutableDictionary *currentUserDic = [NSMutableDictionary dictionaryWithDictionary:[fileSaver getDictionary:self.currentUserName]];
                        [currentUserDic setValue:self.referenceProjectsArray forKey:@"Projects"];
                        [fileSaver setDictionary:currentUserDic withName:self.currentUserName];
                    }
                    [self.carousel reloadData];
                }
                
            } else {
                NSLog(@"could not create the document at %@", url);
            }
        }];
    }
}

-(void)startDeletionProcessInCoreData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
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
                [self databaseDocumentIsReadyForDeletion];
            } else {
                NSLog(@"Could not open the document at %@", url);
            }
        }];
    } else {
        //The documents does not exist on disk, so create it
        [self.databaseDocument saveToURL:self.databaseDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            if (success) {
                [self databaseDocumentIsReadyForDeletion];
            } else {
                NSLog(@"Could not open the document at %@", url);
            }
        }];
    }
}

-(void)startSavingProcessInCoreData {
    if (getProjectFromTheDatabase) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
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
                if (!getProjectFromTheDatabase) {
                    [self databaseDocumentIsReadyForSaving];
                } else {
                    [self databaseDocumentIsReadyForFetchingEntities];
                }
            } else {
                NSLog(@"Could not open the document at %@", url);
            }
        }];
    } else {
        //The documents does not exist on disk, so create it
        [self.databaseDocument saveToURL:self.databaseDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            if (success) {
                if (!getProjectFromTheDatabase) {
                    [self databaseDocumentIsReadyForSaving];
                } else {
                    [self databaseDocumentIsReadyForFetchingEntities];
                }
            } else {
                NSLog(@"Could not open the document at %@", url);
            }
        }];
    }
}

-(void)databaseDocumentIsReadyForDeletion {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    Project *project = self.userProjectsArray[self.carousel.currentItemIndex];
    NSString *projectID = [NSString stringWithFormat:@"%d", [project.identifier intValue]];
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    if (self.databaseDocument.documentState == UIDocumentStateNormal) {
        NSManagedObjectContext *context = self.databaseDocument.managedObjectContext.parentContext;
        
        [context performBlockAndWait:^(){
            
            //Delete all the project finishes images from documents directory
            NSArray *imagePathsForRenders = [Render imagesPathsForRendersWithProjectID:projectID inManagedObjectContext:context];
            NSArray *imagePathsForFinishImages = [FinishImage imagesPathsForFinishImagesWithProjectID:projectID inManagedObjectContext:context];
            NSArray *imagePathsForUrbanizationImages = [Urbanization imagesPathsForUrbanizationWithProjectID:projectID inManagedObjectContext:context];
            NSArray *imagePathsForFloorImages = [Floor imagesPathsForFloorWithProjectID:projectID inManagedObjectContext:context];
            NSArray *imagePathsForPlantImages = [Plant imagesPathsForPlantsWithProjectID:projectID inManagedObjectContext:context];
            NSArray *imagePathsForSpaceImages = [Space imagesPathsForSpacesWithProjectID:projectID inManagedObjectContext:context];
            
            [ImageSaver deleteImagesAtPaths:imagePathsForFinishImages];
            [ImageSaver deleteImagesAtPaths:imagePathsForRenders];
            [ImageSaver deleteImagesAtPaths:imagePathsForUrbanizationImages];
            [ImageSaver deleteImagesAtPaths:imagePathsForFloorImages];
            [ImageSaver deleteImagesAtPaths:imagePathsForPlantImages];
            [ImageSaver deleteImagesAtPaths:imagePathsForSpaceImages];
            
            //Delete all videos from documents directory
            NSArray *videoPaths = [Video videoPathsForVideosWithProjectID:projectID inManagedObjectContext:context];
            NSLog(@"Número de video paths: %d", [videoPaths count]);
            for (int i = 0; i < [videoPaths count]; i++) {
                NSString *videoPath = [docDir stringByAppendingPathComponent:videoPaths[i]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
                    NSLog(@"Borrando video del proyecto %@ en la ruta %@", project.identifier, videoPath);
                    [[NSFileManager defaultManager] removeItemAtPath:videoPath error:NULL];
                } else {
                    NSLog(@"No había video del proyecto %@ en la ruta %@", project.identifier, videoPath);
                }
            }
            
            //Delete objects from CoreData
            [Render deleteRendersForProjectWithID:projectID inManagedObjectContext:context];
            [Urbanization deleteUrbanizationsForProjectWithID:projectID inManagedObjectContext:context];
            [Video deleteVideosForProjectWithID:projectID inManagedObjectContext:context];
            [Group deleteGroupsForProjectWithID:projectID inManagedObjectContext:context];
            [Floor deleteFloorsForProjectWithID:projectID inManagedObjectContext:context];
            [Product deleteProductsForProjectWithID:projectID inManagedObjectContext:context];
            [Plant deletePlantsForProjectWithID:projectID inManagedObjectContext:context];
            [Space deleteSpacesForProjectWithID:projectID inManagedObjectContext:context];
            [Finish deleteFinishesForProjectWithID:projectID inManagedObjectContext:context];
            [FinishImage deleteFinishesImagesForProjectWithID:projectID inManagedObjectContext:context];
            [context save:NULL];
        }];
    }
    
    //Erase the project id from the ids array stored in filesaver
    FileSaver *fileSaver = [[FileSaver alloc] init];
    NSMutableArray *projectIDsArray = [fileSaver getDictionary:@"downloadedProjectsIDs"][@"projectIDsArray"];
    for (int i = 0; i < [projectIDsArray count]; i++) {
        NSNumber *identifier = projectIDsArray[i];
        NSString *savedProjectID = [NSString stringWithFormat:@"%d", [identifier intValue]];
        if ([projectID isEqualToString:savedProjectID]) {
            [projectIDsArray removeObjectAtIndex:i];
            NSLog(@"removiendo el id %@", savedProjectID);
        }
    }
    if ([projectIDsArray count] > 0) {
        [fileSaver setDictionary:@{@"projectIDsArray": projectIDsArray} withName:@"downloadedProjectsIDs"];
    } else {
        [fileSaver setDictionary:@{@"projectIDsArray": @[]} withName:@"downloadedProjectsIDs"];
    }
    
    //Erase the outdated project key in file saver, in case it exist
    if ([fileSaver getDictionary:@"OutdatedProjectIDsDic"][@"OutdatedProjectIDsarray"]) {
        NSMutableArray *outdatedIDs = [fileSaver getDictionary:@"OutdatedProjectIDsDic"][@"OutdatedProjectIDsarray"];
        if ([outdatedIDs containsObject:project.identifier]) {
            [outdatedIDs removeObject:project.identifier];
        }
        if ([outdatedIDs count] > 0) {
            [fileSaver setDictionary:@{@"OutdatedProjectIDsarray": outdatedIDs} withName:@"OutdatedProjectIDsDic"];
        } else {
            [fileSaver setDictionary:@{@"OutdatedProjectIDsarray": @[]} withName:@"OutdatedProjectIDsDic"];
        }
    }

    [self carouselDidEndScrollingAnimation:self.carousel];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Delete Complete" message:@"The project has been deleted successfully." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)databaseDocumentIsReadyForFetchingEntities {
    NSMutableDictionary *projectDictionary = [[NSMutableDictionary alloc] init];
    Project *project = self.userProjectsArray[self.carousel.currentItemIndex];
    NSString *projectID = [NSString stringWithFormat:@"%d", [project.identifier intValue]];
    
    if (self.databaseDocument.documentState == UIDocumentStateNormal) {
        if (!fetchOnlyRenders) {
            //Get our context
            NSManagedObjectContext *context = self.databaseDocument.managedObjectContext;
            NSArray *rendersArray = [Render rendersForProjectWithID:projectID inManagedObjectContext:context];
            NSArray *urbanizationsArray = [Urbanization urbanizationsArrayForProjectWithID:projectID inManagedObjectContext:context];
            NSArray *videosArray = [Video videosArrayForProjectWithID:projectID inManagedObjectContext:context];
            NSArray *groupsArray = [Group groupsArrayForProjectWithID:projectID inManagedObjectContext:context];
            NSArray *floorsArray = [Floor floorsArrayForProjectWithID:projectID inManagedObjectContext:context];
            NSArray *productsArray = [Product productsArrayForProjectWithID:projectID inManagedObjectContext:context];
            NSArray *plantsArray = [Plant plantsArrayForProjectWithID:projectID inManagedObjectContext:context];
            NSArray *spacesArray = [Space spacesArrayForProjectWithID:projectID inManagedObjectContext:context];
            NSArray *finishesArray = [Finish finishesArrayForProjectWithID:projectID inManagedOBjectContext:context];
            NSArray *finishesImagesArray = [FinishImage finishesImagesArrayForProjectWithID:projectID inManagedObjectContext:context];
            
            //Save all core data objects in our dictionary
            [projectDictionary setObject:self.userProjectsArray[self.carousel.currentItemIndex] forKey:@"project"];
            [projectDictionary setObject:rendersArray forKey:@"renders"];
            [projectDictionary setObject:urbanizationsArray forKey:@"urbanizations"];
            [projectDictionary setObject:videosArray forKey:@"videos"];
            [projectDictionary setObject:groupsArray forKey:@"groups"];
            [projectDictionary setObject:floorsArray forKey:@"floors"];
            [projectDictionary setObject:productsArray forKey:@"products"];
            [projectDictionary setObject:plantsArray forKey:@"plants"];
            [projectDictionary setObject:spacesArray forKey:@"spaces"];
            [projectDictionary setObject:finishesArray forKey:@"finishes"];
            [projectDictionary setObject:finishesImagesArray forKey:@"finishImages"];
            
            [self goToProjectScreenWithProjectDic:projectDictionary];
            
        } else {
            NSManagedObjectContext *context = self.databaseDocument.managedObjectContext;
            NSMutableArray *rendersArray = [Render rendersForProjectWithID:projectID inManagedObjectContext:context];
            [self goToSlideshowWithRendersArray:rendersArray];
        }
    }
}

-(void)updateLabel:(NSNumber *)aNumber {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fileDownloaded" object:nil userInfo:@{@"Progress": aNumber}];
    //self.progressLabel.text = [NSString stringWithFormat:@"%f", [aNumber floatValue]];
}

-(void)databaseDocumentIsReadyForSaving {
    if (self.databaseDocument.documentState == UIDocumentStateNormal) {
        
        //Get the total number of files to download
        __block float filesDownloadedCounter = 0;
        __block float progressCompleted;
        __block NSNumber *number = nil;
        float numberOfFiles = [self getNumberOfFilesToDownload];
        NSLog(@"Número de archivos a descargar: %f", numberOfFiles);
        
        //Dic to store all the core data objects and pass them to the next view controller
        NSMutableDictionary *projectDictionary = [[NSMutableDictionary alloc] init];
        NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        
        NSManagedObjectContext *context = self.databaseDocument.managedObjectContext.parentContext;
        [context performBlock:^(){
            //Save render objects in core data
            NSMutableArray *rendersArray = [[NSMutableArray alloc] initWithCapacity:[self.rendersArray count]]; //Of Renders
            for (int i = 0; i < [self.rendersArray count]; i++) {
                if (!downloadWasCancelled && !connectionError) {
                    NSDictionary *renderInfoDic = self.rendersArray[i];
                    Render *render = [Render renderWithServerInfo:renderInfoDic inManagedObjectContext:context];
                    [context save:NULL];
                    [rendersArray addObject:render];
                    
                    //Save Render image in Documents Directory
                    NSString *jpegFilePath = [docDir stringByAppendingPathComponent:render.renderPath];
                    [ImageSaver saveImageWithURL:render.mainURL atPath:jpegFilePath];
                    
                    filesDownloadedCounter ++;
                    progressCompleted = filesDownloadedCounter / numberOfFiles;
                    NSLog(@"progresooo: %f", progressCompleted);
                    number = @(progressCompleted);
                    [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
                }
            }
            
            //Save urbanization object in core data
            NSMutableArray *urbanizationsArray = [[NSMutableArray alloc] init];
            if (!downloadWasCancelled && !connectionError) {
                Urbanization *urbanization = [Urbanization urbanizationWithServerInfo:self.urbanizationDic inManagedObjectContext:context];
                [context save:NULL];
                [urbanizationsArray addObject:urbanization];
                
                //Save Urbanization image in Documents Directory
                NSString *jpegFilePath = [docDir stringByAppendingPathComponent:urbanization.imagePath];
                [ImageSaver saveImageWithURL:urbanization.imageURL atPath:jpegFilePath];
                
                filesDownloadedCounter ++;
                progressCompleted = filesDownloadedCounter / numberOfFiles;
                NSLog(@"progresooo: %f", progressCompleted);
                number = @(progressCompleted);
                [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
            }
            
            NSMutableArray *videosArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < [self.videoArray count]; i++) {
                if (!downloadWasCancelled && !connectionError) {
                    Video *video = [Video videoWithServerInfo:self.videoArray[i] nManagedObjectContext:context];
                    [context save:NULL];
                    [videosArray addObject:video];
                    filesDownloadedCounter ++;
                    progressCompleted = filesDownloadedCounter / numberOfFiles;
                    NSLog(@"progresooo: %f", progressCompleted);
                    number = @(progressCompleted);
                    [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
                }
            }
            
            //Save group objects in Core Data
            NSMutableArray *groupsArray = [[NSMutableArray alloc] initWithCapacity:[self.groupsArray count]];
            for (int i = 0; i < [self.groupsArray count]; i++) {
                if (!downloadWasCancelled && !connectionError) {
                    Group *group = [Group groupWithServerInfo:self.groupsArray[i] inManagedObjectContext:context];
                    [context save:NULL];
                    [groupsArray addObject:group];
                    
                    filesDownloadedCounter ++;
                    progressCompleted = filesDownloadedCounter / numberOfFiles;
                    NSLog(@"progresooo: %f", progressCompleted);
                    number = @(progressCompleted);
                    [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
                }
            }
            
            //Save Floor products in Core Data
            NSMutableArray *floorsArray = [[NSMutableArray alloc] initWithCapacity:[self.floorsArray count]];
            for (int i = 0; i < [self.floorsArray count]; i++) {
                if (!downloadWasCancelled && !connectionError) {
                    Floor *floor = [Floor floorWithServerInfo:self.floorsArray[i] inManagedObjectContext:context];
                    [context save:NULL];
                    [floorsArray addObject:floor];
                    
                    //Save floor images in Documents Dir
                    NSString *jpegFilePath = [docDir stringByAppendingPathComponent:floor.imagePath];
                    [ImageSaver saveImageWithURL:floor.imageURL atPath:jpegFilePath];
                    
                    filesDownloadedCounter ++;
                    progressCompleted = filesDownloadedCounter / numberOfFiles;
                    number = @(progressCompleted);
                    [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
                }
            }
            
            //Save product objects in Core Data
            NSMutableArray *producstArray = [[NSMutableArray alloc] initWithCapacity:[self.productsArray count]];
            for (int i = 0; i < [self.productsArray count]; i++) {
                if (!downloadWasCancelled && !connectionError) {
                    Product *product = [Product productWithServerInfo:self.productsArray[i] inManagedObjectContext:context];
                    [context save:NULL];
                    [producstArray addObject:product];
                    
                    filesDownloadedCounter ++;
                    progressCompleted = filesDownloadedCounter / numberOfFiles;
                    number = @(progressCompleted);
                    [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
                }
            }
            
            //Save plants objects in Core Data
            NSMutableArray *plantsArray = [[NSMutableArray alloc] initWithCapacity:[self.plantsArray count]];
            for (int i = 0; i < [self.plantsArray count]; i++) {
                if (!downloadWasCancelled && !connectionError) {
                    Plant *plant = [Plant plantWithServerInfo:self.plantsArray[i] inManagedObjectContext:context];
                    [context save:NULL];
                    [plantsArray addObject:plant];
                    
                    //Save plant images in Documents Dir
                    NSString *jpegFilePath = [docDir stringByAppendingPathComponent:plant.imagePath];
                    [ImageSaver saveImageWithURL:plant.imageURL atPath:jpegFilePath];
                    
                    filesDownloadedCounter ++;
                    progressCompleted = filesDownloadedCounter / numberOfFiles;
                    number = @(progressCompleted);
                    [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
                }
            }
            
            //Save spaces object in Core Data
            NSMutableArray *spacesArray = [[NSMutableArray alloc] initWithCapacity:[self.spacesArray count]];
            for (int i = 0; i < [self.spacesArray count]; i++) {
                if (!downloadWasCancelled && !connectionError) {
                    Space *space = [Space spaceWithServerInfo:self.spacesArray[i] inManagedObjectContext:context];
                    [context save:NULL];
                    [spacesArray addObject:space];
                    
                    //Save space images in Documents Dir
                    NSString *jpegFilePath = [docDir stringByAppendingPathComponent:space.thumbPath];
                    [ImageSaver saveImageWithURL:space.thumb atPath:jpegFilePath];
                    
                    filesDownloadedCounter ++;
                    progressCompleted = filesDownloadedCounter / numberOfFiles;
                    number = @(progressCompleted);
                    [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
                }
            }
            
            //Save finishes in Core Data
            NSMutableArray *finishesArray = [[NSMutableArray alloc] initWithCapacity:[self.finishesArray count]];
            for (int i = 0; i < [self.finishesArray count]; i++) {
                if (!downloadWasCancelled && !connectionError) {
                    Finish *finish = [Finish finishWithServerInfo:self.finishesArray[i] inManagedObjectContext:context];
                    [context save:NULL];
                    [finishesArray addObject:finish];
                    
                    filesDownloadedCounter ++;
                    progressCompleted = filesDownloadedCounter / numberOfFiles;
                    number = @(progressCompleted);
                    [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
                }
            }
            
            //Save finishes images in Core Data
            NSMutableArray *finishesImagesArray = [[NSMutableArray alloc] initWithCapacity:[self.finishesImagesArray count]];
            NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];

            for (int i = 0; i < [self.finishesImagesArray count]; i++) {
                if (!downloadWasCancelled && !connectionError) {
                    FinishImage *finishImage = [FinishImage finishImageWithServerInfo:self.finishesImagesArray[i] inManagedObjectContext:context];
                    [context save:NULL];
                    [finishesImagesArray addObject:finishImage];
                    
                    //Save image in documents directory
                    NSString *jpegFilePath = [docDir stringByAppendingPathComponent:finishImage.imagePath];
                    [ImageSaver saveFinishImage:finishImage atPath:jpegFilePath];
                    
                    filesDownloadedCounter ++;
                    progressCompleted = filesDownloadedCounter / numberOfFiles;
                    number = @(progressCompleted);
                    [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
                }
            }
            
            NSLog(@"Terminé de guardar toda la vaina");
            
            if (!downloadWasCancelled && !connectionError) {
                //Save all core data objects in our dictionary
                [projectDictionary setObject:self.userProjectsArray[self.carousel.currentItemIndex] forKey:@"project"];
                [projectDictionary setObject:rendersArray forKey:@"renders"];
                [projectDictionary setObject:urbanizationsArray forKey:@"urbanizations"];
                [projectDictionary setObject:videosArray forKey:@"videos"];
                [projectDictionary setObject:groupsArray forKey:@"groups"];
                [projectDictionary setObject:floorsArray forKey:@"floors"];
                [projectDictionary setObject:producstArray forKey:@"products"];
                [projectDictionary setObject:plantsArray forKey:@"plants"];
                [projectDictionary setObject:spacesArray forKey:@"spaces"];
                [projectDictionary setObject:finishesArray forKey:@"finishes"];
                [projectDictionary setObject:finishesImagesArray forKey:@"finishImages"];
                
                [self performSelectorOnMainThread:@selector(finishSavingProcessOnMainThread:) withObject:projectDictionary waitUntilDone:NO];
            
            } else {
                if (downloadWasCancelled) {
                    [self performSelectorOnMainThread:@selector(showDownloadCanceledAlert) withObject:nil waitUntilDone:NO];
                } else if (connectionError) {
                    [self performSelectorOnMainThread:@selector(showConnectionErrorAlert) withObject:nil waitUntilDone:NO];
                }
            }
        }];
        NSLog(@"me salí del bloqueee");
    }
}

/*-(void)saveFinishImage:(FinishImage *)finishImage atPath:(NSString *)jpegFilePath {
    NSLog(@"Entré a guardar la imagen");
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    if (!fileExist) {
        NSLog(@"La imagen no existía en documents directory, así que la guardaré");
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:finishImage.imageURL]];
        
        if ([finishImage.imageURL rangeOfString:@".jpg"].location == NSNotFound) {
            //PVR Image
            NSLog(@"Guardando imagen PVR");
            [data writeToFile:jpegFilePath atomically:YES];
        } else {
            //JPG Image
            UIImage *image = [UIImage imageWithData:data];
            if ([finishImage.finalSize intValue] != [finishImage.size intValue]) {
                NSLog(@"Cambiaré el tamaño de la imagen");
                UIImage *newImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake([finishImage.finalSize intValue], [finishImage.finalSize intValue])];
                NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(newImage, 1.0)];
                [imageData writeToFile:jpegFilePath atomically:YES];
                
            } else {
                NSLog(@"No tuve que cambiar el tamaño de la imagen");
                NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
                [imageData writeToFile:jpegFilePath atomically:YES];
            }
        }
        
    } else {
        NSLog(@"La imagen ya existía, así que no la guardé en documents directory");
    }
}*/

/*-(void)saveImageInDocumentsDirectoryAtPath:(NSString *)jpegFilePath usingImageURL:(NSString *)finishImageURL {
    NSLog(@"Entré a guardar la imagen");
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    if (!fileExist) {
        NSLog(@"La imagen no existía en documents directory, así que la guardaré");
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:finishImageURL]];
        UIImage *image = [UIImage imageWithData:data];
        //UIImage *newImage = [self transformImage:image positionInCube:position];
        NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
        [imageData writeToFile:jpegFilePath atomically:YES];
    } else {
        NSLog(@"La imagen ya existía, así que no la guardé en documents directory");
    }
}*/

-(void)showConnectionErrorAlert {
    downloadWasCancelled = NO;
    connectionError = NO;
    
    self.downloadView.hidden = YES;
    self.downloadView.progress = 0;
    self.opacityView.hidden = YES;
    [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"ErrorConexionDescarga", nil) delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)showDownloadCanceledAlert {
    downloadWasCancelled = NO;
    connectionError = NO;
    
    self.downloadView.hidden = YES;
    self.downloadView.progress = 0;
    self.opacityView.hidden = YES;
    [[[UIAlertView alloc] initWithTitle:nil message:@"Download Cancelled" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)finishSavingProcessOnMainThread:(NSDictionary *)projectDic {
    //In case this project was downloaded but outdated, remove the outdated key from file saver
    FileSaver *fileSaver = [[FileSaver alloc] init];
    Project *project = self.userProjectsArray[projectToDownloadIndex];
    
    if ([fileSaver getDictionary:@"OutdatedProjectIDsDic"][@"OutdatedProjectIDsarray"]) {
        NSMutableArray *outdatedIDs = [NSMutableArray arrayWithArray:[fileSaver getDictionary:@"OutdatedProjectIDsDic"][@"OutdatedProjectIDsarray"]];
        if ([outdatedIDs containsObject:project.identifier]) {
            [outdatedIDs removeObject:project.identifier];
        }
        [fileSaver setDictionary:@{@"OutdatedProjectIDsarray": outdatedIDs} withName:@"OutdatedProjectIDsDic"];
    }
    
    //Save a key with file saver indicating that this project has been downloaded
    if ([fileSaver getDictionary:@"downloadedProjectsIDs"][@"projectIDsArray"]) {
        //Get the array with the project's ids and add the new downloaded project id
        NSMutableArray *projectIDsArray = [NSMutableArray arrayWithArray:[fileSaver getDictionary:@"downloadedProjectsIDs"][@"projectIDsArray"]];
        Project *project = self.userProjectsArray[self.carousel.currentItemIndex];
        if (![projectIDsArray containsObject:project.identifier]) {
            [projectIDsArray addObject:project.identifier];
            [fileSaver setDictionary:@{@"projectIDsArray": projectIDsArray} withName:@"downloadedProjectsIDs"];
            NSLog(@"agregué el id %@ a filesaver", project.identifier);
        }
        
    } else {
        //Create an array to store the downloaded project ids
        NSMutableArray *projectIDsArray = [[NSMutableArray alloc] init];
        Project *project = self.userProjectsArray[self.carousel.currentItemIndex];
        [projectIDsArray addObject:project.identifier];
        [fileSaver setDictionary:@{@"projectIDsArray": projectIDsArray} withName:@"downloadedProjectsIDs"];
        NSLog(@"cree un nuevo arreglo en filesaver con el projectID %@", project.identifier);
    }
    [self carouselDidEndScrollingAnimation:self.carousel];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadCompleted" object:nil userInfo:nil];
    [self goToProjectScreenWithProjectDic:projectDic];
}

#pragma mark - iCarouselDataSource

-(NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [self.userProjectsArray count];
}

-(CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform {
    const CGFloat centerItemZoom = 1.5;
    const CGFloat centerItemSpacing = 1.23;
    
    CGFloat spacing = [self carousel:carousel valueForOption:iCarouselOptionSpacing withDefault:1.0f];
    CGFloat absClampedOffset = MIN(1.0, fabs(offset));
    CGFloat clampedOffset = MIN(1.0, MAX(-1.0, offset));
    CGFloat scaleFactor = 1.0 + absClampedOffset * (1.0/centerItemZoom - 1.0);
    offset = (scaleFactor * offset + scaleFactor * (centerItemSpacing - 1.0) * clampedOffset) * carousel.itemWidth * spacing;
    
    if (carousel.vertical)
    {
        transform = CATransform3DTranslate(transform, 0.0f, offset, -absClampedOffset);
    }
    else
    {
        transform = CATransform3DTranslate(transform, offset, 0.0f, -absClampedOffset);
    }
    
    transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1.0f);
    return transform;
}

-(UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    if (!view) {
        view = [[UIView alloc] initWithFrame:screenBounds];
        view.backgroundColor = [UIColor blackColor];
        
        UIImageView *projectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, view.frame.size.width, view.frame.size.height)];
        projectImageView.tag = 1;
        projectImageView.clipsToBounds = YES;
        projectImageView.contentMode = UIViewContentModeScaleAspectFill;
        projectImageView.backgroundColor = [UIColor grayColor];
        projectImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        projectImageView.layer.borderWidth = 2.0;
        
        UILabel *projectNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 20.0, view.frame.size.width/2.0 - 20.0, 30.0)];
        projectNameLabel.tag = 2;
        projectNameLabel.textColor = [UIColor whiteColor];
        projectNameLabel.font = [UIFont boldSystemFontOfSize:18.0];
        projectNameLabel.textAlignment = NSTextAlignmentLeft;
        projectNameLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        projectNameLabel.layer.shadowOffset = CGSizeMake(2.0, 2.0);
        projectNameLabel.layer.shadowOpacity = 0.6;
        projectNameLabel.layer.shadowRadius = 2.0;
        
        //Project Terms and Conditions button
        UIButton *termsAndConditionsButton = [UIButton buttonWithType:UIButtonTypeSystem];
        termsAndConditionsButton.frame = CGRectMake(view.frame.size.width - 40.0, 20.0, 30.0, 30.0);
        termsAndConditionsButton.tag = 2000 + index;
        [termsAndConditionsButton setBackgroundImage:[UIImage imageNamed:@"NewInfoIcon.png"] forState:UIControlStateNormal];
        [termsAndConditionsButton addTarget:self action:@selector(goToTermsVC) forControlEvents:UIControlEventTouchUpInside];
        
        //Project Logo ImageView
        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(view.frame.size.width - 82.0, view.frame.size.height - 82.0, 80.0, 80.0)];
        logoImageView.backgroundColor = [UIColor darkGrayColor];
        logoImageView.clipsToBounds = YES;
        logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        logoImageView.tag = 3;
        
        //Add subviews
        [view addSubview:projectImageView];
        [view addSubview:projectNameLabel];
        [view addSubview:logoImageView];
        [view addSubview:termsAndConditionsButton];
    }
    
    //Download button
    UIButton *downloadButton = [[UIButton alloc] initWithFrame:CGRectMake(view.frame.size.width/2.0 - 30.0, 20.0, 60.0, 60.0)];
    [downloadButton setBackgroundImage:[UIImage imageNamed:@"NewDownloadIcon.png"] forState:UIControlStateNormal];
    downloadButton.tag = 1000 + index;
    
    if ([[UserInfo sharedInstance].role isEqualToString:@"CLIENT"]) {
        [downloadButton addTarget:self action:@selector(goToTermsVCFromDownloadButton) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [downloadButton addTarget:self action:@selector(downloadProjectFromServer:) forControlEvents:UIControlEventTouchUpInside];
    }    [view addSubview:downloadButton];
    
    ((UIImageView *)[view viewWithTag:1]).image = [self imageFromProjectAtIndex:index];
    ((UILabel *)[view viewWithTag:2]).text = self.projectNamesArray[index];
    ((UIImageView *)[view viewWithTag:3]).image = [self getLogoImageFromProjectAtIndex:index];

    return view;
}

#pragma mark - iCarouselDelegate

-(void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    BOOL projectIsDownloaded = [self userHasDownloadProjectAtIndex:carousel.currentItemIndex];
    BOOL projectIsOutdated = [self isProjectOutdatedAtIndex:carousel.currentItemIndex];

    NSLog(@"%hhd", projectIsDownloaded);
    if (projectIsDownloaded) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^(){
                             self.deleteButton.alpha = 1.0;
                             self.slideShowButton.alpha = 1.0;
                             self.messageButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                             self.logoutButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                             [carousel.currentItemView viewWithTag:1000 + carousel.currentItemIndex].alpha = 0.0;
                             [carousel.currentItemView viewWithTag:2000 + carousel.currentItemIndex].alpha = 1.0;
                         } completion:^(BOOL finished){}];
        
    } else if (!projectIsOutdated) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^(){
                             self.deleteButton.alpha = 0.0;
                             self.slideShowButton.alpha = 0.0;
                             self.messageButton.transform = CGAffineTransformMakeTranslation(30.0 + 48.0, 0.0);
                             self.logoutButton.transform = CGAffineTransformMakeTranslation(-15.0-48.0, 0.0);
                             [carousel.currentItemView viewWithTag:1000 + carousel.currentItemIndex].alpha = 1.0;
                             [carousel.currentItemView viewWithTag:2000 + carousel.currentItemIndex].alpha = 0.0;
                         } completion:^(BOOL finished){}];
    } else {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^(){
                             self.deleteButton.alpha = 0.0;
                             self.slideShowButton.alpha = 0.0;
                             self.messageButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                             self.logoutButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                             [carousel.currentItemView viewWithTag:1000 + carousel.currentItemIndex].alpha = 1.0;
                             [carousel.currentItemView viewWithTag:2000 + carousel.currentItemIndex].alpha = 0.0;
                         } completion:^(BOOL finished){}];

    }
}

-(CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        /*case iCarouselOptionFadeMin:
            return -1.0;
            
        case iCarouselOptionFadeMax:
            return 1.0;
            
        case iCarouselOptionFadeRange:
            return 1.0;
            
        case iCarouselOptionFadeMinAlpha:
            return 0.0;*/
            
        case iCarouselOptionSpacing:
            return 1.0;
            
        case iCarouselOptionOffsetMultiplier:
            return 0.8;
            
        default:
            return value;
    }
}

-(void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    fetchOnlyRenders = NO;
    BOOL userCanGoToProjectDetails = [self userHasDownloadProjectAtIndex:index];
    if (userCanGoToProjectDetails) {
        getProjectFromTheDatabase = YES;
        [self startSavingProcessInCoreData];
        //NSDictionary *projectDic = [self getProjectDicForProjectAtIndex:index];
        //[self goToProjectScreenWithProjectDic:projectDic];
    } else {
        getProjectFromTheDatabase = NO;
        [self downloadProjectFromServerAtIndex:index];
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self logout];
    }
}

#pragma mark - TermsAndConditionsDelegate

-(void)userDidAcceptTerms {
    NSLog(@"El usuario acepto los terminoooooos");
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tag = 1000 + self.carousel.currentItemIndex;
    
    [self downloadProjectFromServer:button];
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"button index: %d", buttonIndex);
    if (buttonIndex == 0) {
        [self startDeletionProcessInCoreData];
    }
}

#pragma mark - DownloadViewDelegate

-(void)cancelButtonWasTappedInDownloadView:(DownloadView *)downloadView {
    NSLog(@"*** Cancelé la download");
    downloadWasCancelled = YES;
}

-(void)downloadViewWillDisappear:(DownloadView *)downloadView {
    self.opacityView.hidden = YES;
}

-(void)downloadViewDidDisappear:(DownloadView *)downloadView {
    //self.opacityView.hidden = YES;
    //self.downloadView.hidden = YES;
    //self.downloadView.progress = 0;
}

-(void)downloadWasCompletedInDownloadView:(DownloadView *)downloadView {
    self.opacityView.hidden = YES;
    self.downloadView.hidden = YES;
    self.downloadView.progress = 0;
}

#pragma mark - Notification Handlers

-(void)ProjectUpdatedNotificationReceived:(NSNotification *)notification {
    NSLog(@"*************************** Me llegó la notificación de que actualizaron un proyecto ***********************************");
    self.databaseDocument = nil;
    [self carouselDidEndScrollingAnimation:self.carousel];
}

-(void)errorDownloadingReceived:(NSNotification *)notification {
    NSLog(@"Me llegó la notificación de errrrrrrooooooooorrrr");
    connectionError = YES;
}

/*-(void)downloadFinished:(NSNotification *)notification {
    [self carouselDidEndScrollingAnimation:self.carousel];
    [self startProjectImageSavingProcessAtIndex:projectToDownloadIndex];
}*/

/*-(void)alertViewAppear {
    NSString *message=NSLocalizedString(@"ErrorDescarga", nil);
    [[[UIAlertView alloc]initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
}*/

@end
