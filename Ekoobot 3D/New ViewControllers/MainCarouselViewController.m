//
//  MainCarouselViewController.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 8/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "MainCarouselViewController.h"
#import "iCarousel.h"
#import "IAmCoder.h"
#import "ProyectoViewController.h"
#import "SendInfoViewController.h"
#import "SlideshowViewController.h"
#import "SlideControlViewController.h"
#import "MBProgressHud.h"
#import "ProjectsListViewController.h"
#import "Project+AddOn.h"
#import "Project+ParseInfoFromServer.h"
#import "TermsAndConditionsViewController.h"
#import "UserInfo.h"
#import "ServerCommunicator.h"
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
#import "Video+AddOns.h"
#import "DownloadView.h"
#import "UIImage+Resize.h"

@interface MainCarouselViewController () <iCarouselDataSource, iCarouselDelegate, UIAlertViewDelegate, ServerCommunicatorDelegate, UIActionSheetDelegate, DownloadViewDelegate, TermsAndConditionsDelegate>
@property (strong, nonatomic) iCarousel *carousel;
@property (strong, nonatomic) UILabel *projectNameLabel;
@property (strong, nonatomic) NSMutableArray *projectsNamesArray;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UIWindow *secondWindow;
@property (strong, nonatomic) UIButton *slideShowButton;
@property (strong, nonatomic) UIButton *messageButton;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIButton *logoutButton;
@property (strong, nonatomic) UIManagedDocument *databaseDocument;
@property (strong, nonatomic) NSURL *databaseDocumentURL;

//Project objects
@property (strong, nonatomic) NSDictionary *projectDic;
@property (strong, nonatomic) NSArray *rendersArray;
@property (strong, nonatomic) NSDictionary *urbanizationDic;
@property (strong, nonatomic) NSArray *videoArray;
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
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@end

@implementation MainCarouselViewController {
    NSUInteger projectToDownloadIndex;
    BOOL downloadEntireProject;
    BOOL getProjectFromTheDatabase;
    BOOL fetchOnlyRenders;
    BOOL downloadWasCancelled;
    BOOL searchingForUpdates;
}

#pragma mark - Lazy Instantiation

-(NSURL *)databaseDocumentURL {
    if (!_databaseDocumentURL) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        NSString *documentName = @"MyDocument";
        _databaseDocumentURL = [documentsDirectory URLByAppendingPathComponent:documentName];
    }
    return _databaseDocumentURL;
}

-(UIManagedDocument *)databaseDocument {
    if (!_databaseDocument) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        NSString *documentName = @"MyDocument";
        NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
        _databaseDocument = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    return _databaseDocument;
}

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
        _downloadView = [[DownloadView alloc] initWithFrame:CGRectMake(1024.0/2.0 - 350/2.0, 768.0/2.0 - 250.0/2.0, 350.0, 250.0)];
        _downloadView.delegate = self;
    }
    return _downloadView;
}

-(NSMutableArray *)projectsNamesArray {
    if (!_projectsNamesArray) {
        _projectsNamesArray = [[NSMutableArray alloc] initWithCapacity:[self.userProjectsArray count]];
        for (int i = 0; i < [self.userProjectsArray count]; i++) {
            Project *project = self.userProjectsArray[i];
            [_projectsNamesArray addObject:project.name];
        }
    }
    return _projectsNamesArray;
}

#pragma mark - View Lifecycle

/*-(void)savePVROnDocuments {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *pvr1FileName = @"PVR1.pvr";
    NSString *pvr1FilePath = [docDir stringByAppendingPathComponent:pvr1FileName];
    
    NSString *PVR1Path = [[NSBundle mainBundle] pathForResource:@"encoded1" ofType:@"pvr"];
    NSData *PVR1Data = [NSData dataWithContentsOfFile:PVR1Path];
    if (![[NSFileManager defaultManager] fileExistsAtPath:pvr1FilePath]) {
        [PVR1Data writeToFile:pvr1FilePath atomically:NO];
    }
}*/

-(void)viewDidLoad {
    [super viewDidLoad];
    //[self savePVROnDocuments];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ProjectUpdatedNotificationReceived:)
                                                 name:@"ProjectUpdatedNotification"
                                               object:nil];
    self.view.backgroundColor = [UIColor grayColor];
    [self setupUI];
    [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(searchForUpdatesInServer) userInfo:nil repeats:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)setupUI {
    self.progressLabel.hidden = YES;
    
    CGRect screenRect = CGRectMake(0.0, 0.0, 1024.0, 768.0);
    
    //Background ImageView
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024.0, 768.0)];
    backgroundImageView.image = [UIImage imageNamed:@"NewBackground.jpg"];
    [self.view addSubview:backgroundImageView];
    
    //Setup Carousel
    self.carousel = [[iCarousel alloc] init];
    self.carousel.type = iCarouselTypeCustom;
    self.carousel.scrollSpeed = 0.3;
    self.carousel.backgroundColor = [UIColor clearColor];
    self.carousel.dataSource = self;
    self.carousel.delegate = self;
    self.carousel.bounceDistance = 0.3;
    self.carousel.pagingEnabled = YES;
    [self.view addSubview:self.carousel];
    //[self.view bringSubviewToFront:self.progressLabel];
    
    //Setup Project Name Label
    self.projectNameLabel = [[UILabel alloc] init];
    self.projectNameLabel.text = self.projectsNamesArray[0];
    self.projectNameLabel.textAlignment = NSTextAlignmentCenter;
    self.projectNameLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    self.projectNameLabel.font = [UIFont boldSystemFontOfSize:25.0];
    [self.view addSubview:self.projectNameLabel];
    
    //Delete button
    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(screenRect.size.width/2.0 - 15.0 + 40.0, screenRect.size.height - 110.0, 35.0, 35.0)];
    [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"NewDeleteIcon.png"] forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deleteProject) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.deleteButton];
    
    //Meesage button
    self.messageButton = [[UIButton alloc] initWithFrame:CGRectMake(screenRect.size.width/2.0 - 15.0 - 40.0 - 30.0 - 40.0, screenRect.size.height - 110.0, 35.0, 35.0)];
    [self.messageButton setBackgroundImage:[UIImage imageNamed:@"NewShareIcon.png"] forState:UIControlStateNormal];
    [self.messageButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.messageButton];
    
    //Slideshow button
    self.slideShowButton = [[UIButton alloc] initWithFrame:CGRectMake(screenRect.size.width/2.0 - 15.0 - 40.0, screenRect.size.height - 110.0, 35.0, 35.0)];
    [self.slideShowButton setBackgroundImage:[UIImage imageNamed:@"NewTVIcon.png"] forState:UIControlStateNormal];
    [self.slideShowButton addTarget:self action:@selector(startSlideshowProcess) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.slideShowButton];
    
    //Logout button
    self.logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(screenRect.size.width/2.0 - 15.0 + 40.0 + 30.0 + 40.0, screenRect.size.height - 110.0, 35.0, 35.0)];
    [self.logoutButton setBackgroundImage:[UIImage imageNamed:@"NewLogoutIcon.png"] forState:UIControlStateNormal];
    [self.logoutButton addTarget:self action:@selector(showLogoutAlert) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.logoutButton];
    
    [self.view addSubview:self.opacityView];
    [self.view addSubview:self.downloadView];
    self.opacityView.hidden = YES;
    self.downloadView.hidden = YES;
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.carousel.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.projectNameLabel.frame = CGRectMake(self.view.bounds.size.width/2.0 - 200.0, 65.0, 400.0, 30.0);
    self.pageControl.frame = CGRectMake(self.view.bounds.size.width/2.0 - 150.0, self.view.bounds.size.height - 60.0, 300.0, 30.0);
}

#pragma mark - Custom methods 

-(UIImage *)getLogoImageFromProjectAtIndex:(NSUInteger)index {
    Project *project = self.userProjectsArray[index];
    return [project projectLogoImage];
}

-(UIImage *)imageFromProyectAtIndex:(NSUInteger)index {
    Project *project = self.userProjectsArray[index];
    return [project projectMainImage];
}

#pragma mark - Actions

-(void)deleteProject {
    [[[UIActionSheet alloc] initWithTitle:@"¿Are you sure you want to delete this project?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil] showInView:self.view];
}

-(void)startSlideshowProcess {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  
    BOOL userCanPassToSlideshowDirectly = [self userHasDownloadProjectAtIndex:self.carousel.currentItemIndex];
    if (userCanPassToSlideshowDirectly) {
        getProjectFromTheDatabase = YES;
        fetchOnlyRenders = YES;
        [self startSavingProcessInCoreData];
    } else {
        [self getRendersFromServer];
    }
}

-(void)goToSlideshow {
    SlideshowViewController *ssVC=[[SlideshowViewController alloc]init];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //ssVC.imagePathArray = [self arrayOfImagePathsFromProjectAtIndex:self.carousel.currentItemIndex];
    ssVC.imagesArray = nil;
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

-(void)showDownloadingView {
    self.opacityView.hidden = NO;
    self.downloadView.hidden = NO;
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
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)goToProjectsList {
    ProjectsListViewController *projectsListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProjectsList"];
    [self.navigationController pushViewController:projectsListVC animated:YES];
}

-(void)goToTermsVC {
    Project *project = self.userProjectsArray[self.carousel.currentItemIndex];
    
    TermsAndConditionsViewController *termsAndConditionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsAndConditions"];
    termsAndConditionsVC.termsString = project.terms;
    termsAndConditionsVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    termsAndConditionsVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:termsAndConditionsVC animated:YES completion:nil];
}

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

#pragma mark - Server Stuff

-(void)searchForUpdatesInServer {
    searchingForUpdates = YES;
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"getProjectsByUser" andParameter:@""];
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

-(void)getRendersFromServer {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    downloadEntireProject = NO;
    Project *project = self.userProjectsArray[self.carousel.currentItemIndex];
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
                NSLog(@"Ocurrió algún error y no se devolvió la info: %@", dictionary);
                self.downloadView.hidden = YES;
                self.opacityView.hidden = YES;
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error en el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                
            } else {
                NSLog(@"Respuesta del getProjectByID: %@", dictionary);
                if (!downloadEntireProject) {
                    //Download only the renders for the slideshow
                    NSArray *arrayWithNulls = dictionary[@"renders"];
                    self.rendersArray = [arrayWithNulls arrayByReplacingNullsWithBlanks];
                    [self startSavingProcessInCoreData];
                    
                } else {
                    //Download entire project
                    self.projectDic = [dictionary[@"project"] dictionaryByReplacingNullWithBlanks];
                    self.rendersArray = [dictionary[@"renders"] arrayByReplacingNullsWithBlanks];
                    self.urbanizationDic = [dictionary[@"urbanization"] dictionaryByReplacingNullWithBlanks];
                    self.videoArray = [dictionary[@"videos"] arrayByReplacingNullsWithBlanks];
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
        } else {
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
        [[[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"ErrorConexion", nil) delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];

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
        if ([savedProjectIDs containsObject:project.identifier]) {
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

#pragma mark - CoreData Stuff

-(NSString *)getImageURLOfProjectWithID:(NSNumber *)projectIdentifier {
    NSString *imageURL = nil;
    for (int i = 0; i < [self.projectMainRendersArray count]; i++) {
        NSDictionary *renderDic = self.projectMainRendersArray[i];
        if ([renderDic[@"project"] intValue] == [projectIdentifier intValue]) {
            imageURL = [@"http://ekoobot.com/new_bot/web/" stringByAppendingString:renderDic[@"url"]];
            break;
        }
    }
    return imageURL;
}

-(void)startUpdatingProjectProcessInCoreDataUsingProjectDic:(NSDictionary *)newProjectDic {
    //Get the Datababase Document path
    /*NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = @"MyDocument";
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
    self.databaseDocument = [[UIManagedDocument alloc] initWithFileURL:url];*/
    
    //Check if the document exist
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:[self.databaseDocumentURL path]];
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
                NSLog(@"Could not open the document at %@", self.databaseDocumentURL);
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
                NSLog(@"could not create the document at %@", self.databaseDocumentURL);
            }
        }];
    }
}

-(void)startDeletionProcessInCoreData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //Get the Datababase Document path
    /*NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = @"MyDocument";
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
    self.databaseDocument = [[UIManagedDocument alloc] initWithFileURL:url];*/
    
    //Check if the document exist
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:[self.databaseDocumentURL path]];
    if (fileExist) {
        //Open The Database Document
        [self.databaseDocument openWithCompletionHandler:^(BOOL success){
            if (success) {
                [self databaseDocumentIsReadyForDeletion];
            } else {
                NSLog(@"Could not open the document at %@", self.databaseDocumentURL);
            }
        }];
    } else {
        //The documents does not exist on disk, so create it
        [self.databaseDocument saveToURL:self.databaseDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            if (success) {
                [self databaseDocumentIsReadyForDeletion];
            } else {
                NSLog(@"Could not open the document at %@", self.databaseDocumentURL);
            }
        }];
    }
}

-(void)startSavingProcessInCoreData {
    if (getProjectFromTheDatabase) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    //Get the Datababase Document path
    /*NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = @"MyDocument";
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
    self.databaseDocument = [[UIManagedDocument alloc] initWithFileURL:url];*/
    
    //Check if the document exist
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:[self.databaseDocumentURL path]];
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
                NSLog(@"Could not open the document at %@", self.databaseDocumentURL);
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
                NSLog(@"Could not open the document at %@", self.databaseDocumentURL);
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
            NSArray *imagePathsForFinishImages = [FinishImage imagesPathsForFinishImagesWithProjectID:projectID inManagedObjectContext:context];
            NSLog(@"Número de imagepaths: %d", [imagePathsForFinishImages count]);
            for (int i = 0; i < [imagePathsForFinishImages count]; i++) {
                NSString *finishImagePath = [docDir stringByAppendingPathComponent:imagePathsForFinishImages[i]];
                BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:finishImagePath];
                if (fileExist) {
                    [[NSFileManager defaultManager] removeItemAtPath:finishImagePath error:NULL];
                    NSLog(@"Borrando finish image del proyecto %@ en la ruta %@", project.identifier, finishImagePath);
                } else {
                    NSLog(@"No había archivo del proyecto %@ en la ruta %@", project.identifier, finishImagePath);
                }
            }
            
            //Delete al videos from documents directory
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
    [self carouselDidEndScrollingAnimation:self.carousel];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Delete Complete" message:@"The project has been deleted successfully." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)databaseDocumentIsReadyForFetchingEntities {
    NSMutableDictionary *projectDictionary = [[NSMutableDictionary alloc] init];
    Project *project = self.userProjectsArray[projectToDownloadIndex];
    NSLog(@"proyect id: %@", project.identifier);
    NSString *projectID = [NSString stringWithFormat:@"%d", [project.identifier intValue]];
    
    if (self.databaseDocument.documentState == UIDocumentStateNormal) {
        if (!fetchOnlyRenders) {
            //Get our context
            NSManagedObjectContext *context = self.databaseDocument.managedObjectContext;
            context.undoManager = nil;
            
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
            [projectDictionary setObject:self.userProjectsArray[projectToDownloadIndex] forKey:@"project"];
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
    self.progressLabel.text = [NSString stringWithFormat:@"%f", [aNumber floatValue]];
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
        
        NSManagedObjectContext *context = self.databaseDocument.managedObjectContext.parentContext;
        [context performBlock:^(){
            
            //Save project dic in core data
            Project *project;
            if (!downloadWasCancelled) {
                project = [Project projectWithServerInfo:self.projectDic inManagedObjectContext:context];
                [context save:NULL];
            }
        
            //Save render objects in core data
            NSMutableArray *rendersArray = [[NSMutableArray alloc] initWithCapacity:[self.rendersArray count]]; //Of Renders
            for (int i = 0; i < [self.rendersArray count]; i++) {
                if (!downloadWasCancelled) {
                    NSDictionary *renderInfoDic = self.rendersArray[i];
                    Render *render = [Render renderWithServerInfo:renderInfoDic inManagedObjectContext:context];
                    [context save:NULL];
                    [rendersArray addObject:render];
                    filesDownloadedCounter ++;
                    progressCompleted = filesDownloadedCounter / numberOfFiles;
                    NSLog(@"progresooo: %f", progressCompleted);
                    number = @(progressCompleted);
                    [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
                }
            }
            
            //Save urbanization object in core data
            NSMutableArray *urbanizationsArray = [[NSMutableArray alloc] init];
            if (!downloadWasCancelled) {
                Urbanization *urbanization = [Urbanization urbanizationWithServerInfo:self.urbanizationDic inManagedObjectContext:context];
                [context save:NULL];
                [urbanizationsArray addObject:urbanization];
                filesDownloadedCounter ++;
                progressCompleted = filesDownloadedCounter / numberOfFiles;
                NSLog(@"progresooo: %f", progressCompleted);
                number = @(progressCompleted);
                [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
            }
            
            NSMutableArray *videosArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < [self.videoArray count]; i++) {
                if (!downloadWasCancelled) {
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
                if (!downloadWasCancelled) {
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
                if (!downloadWasCancelled) {
                    Floor *floor = [Floor floorWithServerInfo:self.floorsArray[i] inManagedObjectContext:context];
                    [context save:NULL];
                    [floorsArray addObject:floor];
                    
                    filesDownloadedCounter ++;
                    progressCompleted = filesDownloadedCounter / numberOfFiles;
                    number = @(progressCompleted);
                    [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
                }
            }
            
            //Save product objects in Core Data
            NSMutableArray *producstArray = [[NSMutableArray alloc] initWithCapacity:[self.productsArray count]];
            for (int i = 0; i < [self.productsArray count]; i++) {
                if (!downloadWasCancelled) {
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
                if (!downloadWasCancelled) {
                    Plant *plant = [Plant plantWithServerInfo:self.plantsArray[i] inManagedObjectContext:context];
                    [context save:NULL];
                    [plantsArray addObject:plant];
                    
                    filesDownloadedCounter ++;
                    progressCompleted = filesDownloadedCounter / numberOfFiles;
                    number = @(progressCompleted);
                    [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
                }
            }
            
            //Save spaces object in Core Data
            NSMutableArray *spacesArray = [[NSMutableArray alloc] initWithCapacity:[self.spacesArray count]];
            for (int i = 0; i < [self.spacesArray count]; i++) {
                if (!downloadWasCancelled) {
                    Space *space = [Space spaceWithServerInfo:self.spacesArray[i] inManagedObjectContext:context];
                    [context save:NULL];
                    [spacesArray addObject:space];
                    
                    filesDownloadedCounter ++;
                    progressCompleted = filesDownloadedCounter / numberOfFiles;
                    number = @(progressCompleted);
                    [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
                }
            }
            
            //Save finishes in Core Data
            NSMutableArray *finishesArray = [[NSMutableArray alloc] initWithCapacity:[self.finishesArray count]];
            for (int i = 0; i < [self.finishesArray count]; i++) {
                if (!downloadWasCancelled) {
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
                if (!downloadWasCancelled) {
                    FinishImage *finishImage = [FinishImage finishImageWithServerInfo:self.finishesImagesArray[i] inManagedObjectContext:context];
                    [context save:NULL];
                    [finishesImagesArray addObject:finishImage];
                    
                    //Save image in documents directory
                    NSString *jpegFilePath = [docDir stringByAppendingPathComponent:finishImage.imagePath];
                    [self saveFinishImage:finishImage atPath:jpegFilePath];
                    //[self saveImageInDocumentsDirectoryAtPath:jpegFilePath usingImageURL:finishImage.imageURL];
                    
                    filesDownloadedCounter ++;
                    progressCompleted = filesDownloadedCounter / numberOfFiles;
                    number = @(progressCompleted);
                    [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
                }
            }
            
            NSLog(@"Terminé de guardar toda la vaina");
            
            if (!downloadWasCancelled) {
                //Save all core data objects in our dictionary
                //[projectDictionary setObject:self.userProjectsArray[self.carousel.currentItemIndex] forKey:@"project"];
                [projectDictionary setObject:project forKey:@"project"];
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
                [self performSelectorOnMainThread:@selector(showDownloadCanceledAlert) withObject:nil waitUntilDone:NO];
            }
        }];
        NSLog(@"me salí del bloqueee");
    }
}

-(void)saveFinishImage:(FinishImage *)finishImage atPath:(NSString *)jpegFilePath {
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
}

/*-(void)saveImageInDocumentsDirectoryAtPath:(NSString *)jpegFilePath usingImageURL:(NSString *)finishImageURL {
    NSLog(@"Entré a guardar la imagen");
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    if (!fileExist) {
        NSLog(@"La imagen no existía en documents directory, así que la guardaré");
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:finishImageURL]];
        
        if ([finishImageURL rangeOfString:@".jpg"].location == NSNotFound) {
            //PVR Image
            NSLog(@"Guardando imagen PVR");
            [data writeToFile:jpegFilePath atomically:YES];
        } else {
            //JPG Image
            UIImage *image = [UIImage imageWithData:data];
            //UIImage *newImage = [self transformImage:image positionInCube:position];
            NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
            [imageData writeToFile:jpegFilePath atomically:YES];
        }
        
    } else {
        NSLog(@"La imagen ya existía, así que no la guardé en documents directory");
    }
}*/

/*-(UIImage *)transformImage:(UIImage *)image positionInCube:(NSString *)positionInCube {
    
    if ([positionInCube isEqualToString:@"back"]) {
     
        
    } else if ([positionInCube isEqualToString:@"left"]) {
        image = [image rotateImage:image onDegrees:90.0];
        image = [image flippedImageByAxis:MVImageFlipYAxis];
        
    } else if ([positionInCube isEqualToString:@"front"]) {
        image = [image flippedImageByAxis:MVImageFlipYAxis];
        
    } else if ([positionInCube isEqualToString:@"right"]) {
        image = [image rotateImage:image onDegrees:90.0];
        image = [image flippedImageByAxis:MVImageFlipXAxisAndYAxis];
        
    } else if ([positionInCube isEqualToString:@"top"]) {
        image = [image flippedImageByAxis:MVImageFlipXAxisAndYAxis];
        
    } else if ([positionInCube isEqualToString:@"down"] || [positionInCube isEqualToString:@"bottom"]) {
        image = [image flippedImageByAxis:MVImageFlipYAxis];
    }
    return image;
}*/

-(void)showDownloadCanceledAlert {
    downloadWasCancelled = NO;
    self.downloadView.hidden = YES;
    self.downloadView.progress = 0;
    self.opacityView.hidden = YES;
    [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"DescargaCancelada", nil) delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)finishSavingProcessOnMainThread:(NSDictionary *)projectDic {
    //Save a key with file saver indicating that this project has been downloaded
    FileSaver *fileSaver = [[FileSaver alloc] init];
    Project *project = self.userProjectsArray[projectToDownloadIndex];

    if ([fileSaver getDictionary:@"downloadedProjectsIDs"][@"projectIDsArray"]) {
        //Get the array with the project's ids and add the new downloaded project id
        NSMutableArray *projectIDsArray = [NSMutableArray arrayWithArray:[fileSaver getDictionary:@"downloadedProjectsIDs"][@"projectIDsArray"]];
        //Project *project = self.userProjectsArray[self.carousel.currentItemIndex];
        //Project *project = self.userProjectsArray[projectToDownloadIndex];
        if (![projectIDsArray containsObject:project.identifier]) {
            [projectIDsArray addObject:project.identifier];
            [fileSaver setDictionary:@{@"projectIDsArray": projectIDsArray} withName:@"downloadedProjectsIDs"];
            NSLog(@"agregué el id %@ a filesaver", project.identifier);
        }
        
    } else {
        //Create an array to store the downloaded project ids
        NSMutableArray *projectIDsArray = [[NSMutableArray alloc] init];
        //Project *project = self.userProjectsArray[self.carousel.currentItemIndex];
        [projectIDsArray addObject:project.identifier];
        [fileSaver setDictionary:@{@"projectIDsArray": projectIDsArray} withName:@"downloadedProjectsIDs"];
        NSLog(@"cree un nuevo arreglo en filesaver con el projectID %@", project.identifier);
    }
    [self carouselDidEndScrollingAnimation:self.carousel];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadCompleted" object:nil userInfo:nil];
    [self goToProjectScreenWithProjectDic:projectDic];
}

-(NSUInteger)getNumberOfFilesToDownload {
    NSUInteger numberOfFiles = 0;
    numberOfFiles = [self.rendersArray count] + 1 + 1 + [self.groupsArray count] + [self.productsArray count] + [self.floorsArray count] + [self.plantsArray count] + [self.spacesArray count] + [self.finishesArray count] + [self.finishesImagesArray count]; // + 2 because of the video dic and the urbanization dic
    return numberOfFiles;
}

-(void)goToProjectScreenWithProjectDic:(NSDictionary *)dictionary {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    ProyectoViewController *proyectoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Proyecto"];
    proyectoVC.projectDic = dictionary;
    [self.navigationController pushViewController:proyectoVC animated:YES];
}

-(void)goToSlideshowWithRendersArray:(NSMutableArray *)rendersArray {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    NSMutableArray *renderImagesArray = [NSMutableArray arrayWithCapacity:[rendersArray count]];
    for (int i = 0; i < [rendersArray count]; i++) {
        Render *render = rendersArray[i];
        [renderImagesArray addObject:[render renderImage]];
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

-(BOOL)userHasDownloadProjectAtIndex:(NSUInteger)index {
    Project *project = self.userProjectsArray[index];
    
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
    }
}

#pragma mark - iCarouselDataSource

-(NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    //return [self.usuario.arrayProyectos count];
    return [self.userProjectsArray count];
}

-(UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    if (!view) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 260.0, 428.0)];
        view.layer.shadowColor = [UIColor blackColor].CGColor;
        view.layer.shadowOffset = CGSizeMake(5.0, 5.0);
        view.layer.shadowOpacity = 0.9;
        view.layer.shadowRadius = 5.0;
        
        //Main Project ImageView
        UIImageView *projectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 260.0, 428.0)];
        projectImageView.tag = 1;
        projectImageView.clipsToBounds = YES;
        projectImageView.contentMode = UIViewContentModeScaleAspectFill;
        projectImageView.backgroundColor = [UIColor grayColor];
        projectImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        projectImageView.layer.borderWidth = 4.0;
        
        //Project Logo ImageView
        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(view.frame.size.width/2.0, view.frame.size.height - 84.0, view
                                                                                   .frame.size.width/2.0 - 4.0, 80)];
        logoImageView.backgroundColor = [UIColor darkGrayColor];
        logoImageView.clipsToBounds = YES;
        logoImageView.contentMode = UIViewContentModeScaleAspectFill;
        logoImageView.tag = 2;
        
        //Project Terms and Conditions button
        UIButton *termsAndConditionsButton = [UIButton buttonWithType:UIButtonTypeSystem];
        termsAndConditionsButton.frame = CGRectMake(view.frame.size.width - 40.0, 10.0, 30.0, 30.0);
        termsAndConditionsButton.tag = 2000 + index;
        [termsAndConditionsButton setBackgroundImage:[UIImage imageNamed:@"NewInfoIcon.png"] forState:UIControlStateNormal];
        [termsAndConditionsButton addTarget:self action:@selector(goToTermsVC) forControlEvents:UIControlEventTouchUpInside];
        
        //Add subviews
        [view addSubview:projectImageView];
        [view addSubview:logoImageView];
        [view addSubview:termsAndConditionsButton];
    }
    
    //Download button
    UIButton *downloadButton = [[UIButton alloc] initWithFrame:CGRectMake(view.frame.size.width/2.0 - 40.0, 20.0, 80.0, 93.0)];
    [downloadButton setBackgroundImage:[UIImage imageNamed:@"NewDownloadIcon.png"] forState:UIControlStateNormal];
    downloadButton.tag = 1000 + index;
    
    if ([[UserInfo sharedInstance].role isEqualToString:@"CLIENT"]) {
        [downloadButton addTarget:self action:@selector(goToTermsVCFromDownloadButton) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [downloadButton addTarget:self action:@selector(downloadProjectFromServer:) forControlEvents:UIControlEventTouchUpInside];
    }
    [view addSubview:downloadButton];
    
    ((UIImageView *)[view viewWithTag:2]).image = [self getLogoImageFromProjectAtIndex:index];
    ((UIImageView *)[view viewWithTag:1]).image = [self imageFromProyectAtIndex:index];
    return view;
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

-(CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        /*case iCarouselOptionFadeMin:
            return -1.0;
            
        case iCarouselOptionFadeMax:
            return 1.0;
            
        case iCarouselOptionFadeRange:
            return 1.0;
            
        case iCarouselOptionFadeMinAlpha:
             return 0.8;*/
            
        case iCarouselOptionSpacing:
            //return 0.5;
            return 1.6;
        
        case iCarouselOptionOffsetMultiplier:
            return 0.7;
            
        default:
            return value;
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self logout];
    }
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"button index: %d", buttonIndex);
    if (buttonIndex == 0) {
        [self startDeletionProcessInCoreData];
    }
}

-(void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"Index selected: %d", index);
    fetchOnlyRenders = NO;
    BOOL userCanGoToProjectDetails = [self userHasDownloadProjectAtIndex:index];
    if (userCanGoToProjectDetails) {
        getProjectFromTheDatabase = YES;
        projectToDownloadIndex = index;
        [self startSavingProcessInCoreData];
     
    } else {
        getProjectFromTheDatabase = NO;
        [self downloadProjectFromServerAtIndex:index];
    }
}

-(void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    projectToDownloadIndex = self.carousel.currentItemIndex;
    
    BOOL projectIsDownloaded = [self userHasDownloadProjectAtIndex:carousel.currentItemIndex];
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
        
    } else {
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
    }
}

#pragma mark - iCarouselDelegate

-(void)carouselDidScroll:(iCarousel *)carousel {
    //NSLog(@"Scrolling");
    self.projectNameLabel.text = self.projectsNamesArray[carousel.currentItemIndex];
    self.pageControl.currentPage = carousel.currentItemIndex;
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
    self.opacityView.hidden = YES;
    self.downloadView.hidden = YES;
    self.downloadView.progress = 0;
}

#pragma mark - TermsAndConditionsDelegate

-(void)userDidAcceptTerms {
    NSLog(@"El usuario acepto los terminoooooos");
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tag = 1000 + self.carousel.currentItemIndex;
    
    [self downloadProjectFromServer:button];
}

#pragma mark - Notification Handlers

-(void)ProjectUpdatedNotificationReceived:(NSNotification *)notification {
    NSLog(@"*************************** Me llegó la notificación de que actualizaron un proyecto ***********************************");
    [self carouselDidEndScrollingAnimation:self.carousel];
}

@end
