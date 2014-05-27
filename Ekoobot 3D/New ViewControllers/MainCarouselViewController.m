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
//#import "ProjectDownloader.h"
#import "MBProgressHud.h"
#import "ProjectsListViewController.h"
//#import "TermsViewController.h"
//#import "ProgressView.h"
#import "Project+AddOn.h"
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
#import "DownloadView.h"

@interface MainCarouselViewController () <iCarouselDataSource, iCarouselDelegate, UIAlertViewDelegate, ServerCommunicatorDelegate, UIActionSheetDelegate, DownloadViewDelegate>
@property (strong, nonatomic) iCarousel *carousel;
@property (strong, nonatomic) UILabel *projectNameLabel;
@property (strong, nonatomic) NSMutableArray *projectsNamesArray;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UIWindow *secondWindow;
@property (strong, nonatomic) UIButton *slideShowButton;
@property (strong, nonatomic) UIButton *messageButton;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIButton *logoutButton;
//@property (strong, nonatomic) ProgressView *progressView;
@property (strong, nonatomic) UIManagedDocument *databaseDocument;

//Project objects
@property (strong, nonatomic) NSArray *rendersArray;
@property (strong, nonatomic) NSDictionary *urbanizationDic;
@property (strong, nonatomic) NSArray *groupsArray;
@property (strong, nonatomic) NSArray *floorsArray;
@property (strong, nonatomic) NSArray *productsArray;
@property (strong, nonatomic) NSArray *plantsArray;
@property (strong, nonatomic) NSArray *spacesArray;
@property (strong, nonatomic) NSArray *finishesArray;
@property (strong, nonatomic) NSArray *finishesImagesArray;

@property (strong, nonatomic) UIView *opacityView;
@end

@implementation MainCarouselViewController {
    NSUInteger projectToDownloadIndex;
    BOOL downloadEntireProject;
    BOOL getProjectFromTheDatabase;
    BOOL fetchOnlyRenders;
}

#pragma mark - Lazy Instantiation

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

-(void)viewDidLoad {
    [super viewDidLoad];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinished:) name:@"updates" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertViewAppear) name:@"alert" object:nil];
    //[self performSelectorInBackground:@selector(saveMainProjectImages) withObject:nil];
    self.view.backgroundColor = [UIColor grayColor];
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)setupUI {
    CGRect screenRect = CGRectMake(0.0, 0.0, 1024.0, 768.0);
    
    //Background ImageView
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024.0, 768.0)];
    backgroundImageView.image = [UIImage imageNamed:@"NewBackground.jpg"];
    [self.view addSubview:backgroundImageView];
    
    //Setup Carousel
    self.carousel = [[iCarousel alloc] init];
    self.carousel.type = iCarouselTypeRotary;
    self.carousel.scrollSpeed = 0.5;
    self.carousel.backgroundColor = [UIColor clearColor];
    self.carousel.dataSource = self;
    self.carousel.delegate = self;
    [self.view addSubview:self.carousel];
    
    //Setup Project Name Label
    self.projectNameLabel = [[UILabel alloc] init];
    self.projectNameLabel.text = self.projectsNamesArray[0];
    self.projectNameLabel.textAlignment = NSTextAlignmentCenter;
    self.projectNameLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    self.projectNameLabel.font = [UIFont boldSystemFontOfSize:25.0];
    [self.view addSubview:self.projectNameLabel];
    
    //Ekoomedia Logo
    /*UIImageView *ekoomediaLogo = [[UIImageView alloc] initWithFrame:CGRectMake(screenRect.size.width - 100.0, 20.0, 80.0, 80.0)];
    ekoomediaLogo.image = [UIImage imageNamed:@"logo.png"];
    ekoomediaLogo.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:ekoomediaLogo];*/
    
    //Delete button
    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(screenRect.size.width/2.0 - 15.0 - 40.0, screenRect.size.height - 80.0, 30.0, 30.0)];
    [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"NewDeleteIcon.png"] forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deleteProject) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.deleteButton];
    
    //Meesage button
    self.messageButton = [[UIButton alloc] initWithFrame:CGRectMake(screenRect.size.width/2.0 - 15.0 - 40.0 - 30.0 - 40.0, screenRect.size.height - 80.0, 30.0, 30.0)];
    [self.messageButton setBackgroundImage:[UIImage imageNamed:@"NewShareIcon.png"] forState:UIControlStateNormal];
    [self.messageButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.messageButton];
    
    //Slideshow button
    self.slideShowButton = [[UIButton alloc] initWithFrame:CGRectMake(screenRect.size.width/2.0 - 15.0 + 40.0, screenRect.size.height - 80.0, 30.0, 30.0)];
    [self.slideShowButton setBackgroundImage:[UIImage imageNamed:@"NewTVIcon.png"] forState:UIControlStateNormal];
    [self.slideShowButton addTarget:self action:@selector(startSlideshowProcess) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.slideShowButton];
    
    //Logout button
    self.logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(screenRect.size.width/2.0 - 15.0 + 40.0 + 30.0 + 40.0, screenRect.size.height - 80.0, 30.0, 30.0)];
    [self.logoutButton setBackgroundImage:[UIImage imageNamed:@"NewLogoutIcon.png"] forState:UIControlStateNormal];
    [self.logoutButton addTarget:self action:@selector(showLogoutAlert) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.logoutButton];
    
    /*Proyecto *proyecto = self.usuario.arrayProyectos[0];
    if (![proyecto.arrayAdjuntos count] > 0) {
        self.slideShowButton.hidden = YES;
    }*/
    
    //ProgressView
    /*self.progressView=[[ProgressView alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.height, self.navigationController.view.frame.size.width)];
    
    [self.navigationController.view addSubview:self.progressView];
    [self.view bringSubviewToFront:self.progressView];*/
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.carousel.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.projectNameLabel.frame = CGRectMake(self.view.bounds.size.width/2.0 - 200.0, 65.0, 400.0, 30.0);
    self.pageControl.frame = CGRectMake(self.view.bounds.size.width/2.0 - 150.0, self.view.bounds.size.height - 60.0, 300.0, 30.0);
}

#pragma mark - Custom methods 

/*-(void)saveMainProjectImages {
    for (int i = 0; i < [self.usuario.arrayProyectos count]; i++) {
        Proyecto *proyecto = self.usuario.arrayProyectos[i];
        NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *jpegFilePath = [NSString stringWithFormat:@"%@/cover%@%@.jpeg",docDir,proyecto.idProyecto,[IAmCoder encodeURL:proyecto.imagen]];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
        
        if (!fileExists) {
            //NSLog(@"no existe proj img %@",jpegFilePath);
            NSURL *urlImagen=[NSURL URLWithString:proyecto.imagen];
            NSData *data=[NSData dataWithContentsOfURL:urlImagen];
            UIImage *image = [UIImage imageWithData:data];
            NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
            if (image) {
                [data2 writeToFile:jpegFilePath atomically:YES];
            }
        }
    }
}*/

-(UIImage *)getLogoImageFromProjectAtIndex:(NSUInteger)index {
    /*Proyecto *proyecto = self.usuario.arrayProyectos[index];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/logo%@%@",docDir,proyecto.idProyecto,[IAmCoder encodeURL:proyecto.logo]];
    [ProjectDownloader addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:docDir]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    
    if (!fileExists) {
        //NSLog(@"no existe proj img %@",jpegFilePath);
        NSURL *urlImagen=[NSURL URLWithString:proyecto.logo];
        NSData *data=[NSData dataWithContentsOfURL:urlImagen];
        UIImage *image = [UIImage imageWithData:data];
        NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
        if (image) {
            [data2 writeToFile:jpegFilePath atomically:YES];
        }
        return image;
    }
    else {
        UIImage *image = [UIImage imageWithContentsOfFile:jpegFilePath];
        return image;
    }*/
    
    Project *project = self.userProjectsArray[index];
    return [project projectLogoImage];
}

-(UIImage *)imageFromProyectAtIndex:(NSUInteger)index {
    /*Proyecto *proyecto = self.usuario.arrayProyectos[index];
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/cover%@%@.jpeg",docDir,proyecto.idProyecto,[IAmCoder encodeURL:proyecto.imagen]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    
    if (!fileExists) {
        //NSLog(@"no existe proj img %@",jpegFilePath);
        NSURL *urlImagen=[NSURL URLWithString:proyecto.imagen];
        NSData *data=[NSData dataWithContentsOfURL:urlImagen];
        UIImage *image = [UIImage imageWithData:data];
        NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
        if (image) {
            [data2 writeToFile:jpegFilePath atomically:YES];
        }
        return image;
    }
    else {
        UIImage *image = [UIImage imageWithContentsOfFile:jpegFilePath];
        return image;
    }*/
    Project *project = self.userProjectsArray[index];
    return [project projectMainImage];
}

/*-(NSArray *)arrayOfImagePathsFromProjectAtIndex:(NSUInteger)index {
    NSMutableArray *projectImagesArray = [[NSMutableArray alloc] init];
    Proyecto *proyecto = self.usuario.arrayProyectos[index];
    
    for (int i = 0; i < [proyecto.arrayAdjuntos count]; i++) {
        Adjunto *adjunto = proyecto.arrayAdjuntos[i];
        if ([adjunto.tipo isEqualToString:@"image"]) {
            NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            [ProjectDownloader addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:docDir]];
            NSString *jpegFilePath = [NSString stringWithFormat:@"%@/render%@%@.jpg",docDir,proyecto.idProyecto,[IAmCoder encodeURL:adjunto.imagen]];
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
            if (fileExists) {
                [projectImagesArray addObject:jpegFilePath];
            } else {
                
                NSURL *urlImagen=[NSURL URLWithString:adjunto.imagen];
                NSData *data=[NSData dataWithContentsOfURL:urlImagen];
                UIImage *image = [UIImage imageWithData:data];
                NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
                if (image) {
                    [data2 writeToFile:jpegFilePath atomically:YES];
                    [projectImagesArray addObject:jpegFilePath];
                }
            }
        }
    }
    return projectImagesArray;
}*/

#pragma mark - Actions 

-(void)deleteProject {
    [[[UIActionSheet alloc] initWithTitle:@"¿Are you sure you want to delete this project?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil] showInView:self.view];
}

/*-(void)startProjectImageSavingProcessAtIndex:(NSUInteger)index {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_queue_t imageSavingTask = dispatch_queue_create("ProjectImageSaving", NULL);
    dispatch_async(imageSavingTask, ^(){
        [self saveProjectImagesInBackgroundAtIndex:index];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self goToProjectAtIndex:index];
        });
    });
}*/

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

/*-(void)saveProjectImagesInBackgroundAtIndex:(NSUInteger)index {
    Proyecto *proyecto = self.usuario.arrayProyectos[index];
    
    for (int i = 0; i < [proyecto.arrayAdjuntos count]; i++) {
        Adjunto *adjunto = proyecto.arrayAdjuntos[i];
        if ([adjunto.tipo isEqualToString:@"image"]) {
            NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            [ProjectDownloader addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:docDir]];
            NSString *jpegFilePath = [NSString stringWithFormat:@"%@/render%@%@.jpg",docDir,proyecto.idProyecto,[IAmCoder encodeURL:adjunto.imagen]];
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
            if (fileExists) {
                
            } else {
                
                NSURL *urlImagen=[NSURL URLWithString:adjunto.imagen];
                NSData *data=[NSData dataWithContentsOfURL:urlImagen];
                UIImage *image = [UIImage imageWithData:data];
                NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
                if (image) {
                    [data2 writeToFile:jpegFilePath atomically:YES];
                }
            }
        }
    }
}*/

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
    /*Proyecto *proyecto = self.usuario.arrayProyectos[self.carousel.currentItemIndex];
    SendInfoViewController *sendInfoVC=[[SendInfoViewController alloc]init];
    sendInfoVC=[self.storyboard instantiateViewControllerWithIdentifier:@"SendInfo"];
    sendInfoVC.nombreProyecto = proyecto.nombre;
    sendInfoVC.proyectoID = proyecto.idProyecto;
    sendInfoVC.usuario = self.usuario.usuario;
    sendInfoVC.currentUser = self.usuario;
    sendInfoVC.contrasena = self.usuario.contrasena;
    sendInfoVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    sendInfoVC.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self.navigationController presentViewController:sendInfoVC animated:YES completion:nil];*/
    
    
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
    self.opacityView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.7;
    [self.view addSubview:self.opacityView];
    
    DownloadView *downloadView = [[DownloadView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0 - 150.0, self.view.bounds.size.height/2.0 - 100.0, 300.0, 200.0)];
    downloadView.delegate = self;
    [self.view addSubview:downloadView];
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

/*-(void)goToProjectAtIndex:(NSUInteger)index {
    ProyectoViewController *proyectoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Proyecto"];
    proyectoVC.proyecto = self.usuario.arrayProyectos[index];
    proyectoVC.usuario = self.usuario;
    proyectoVC.mainImage = [self imageFromProyectAtIndex:index];
    proyectoVC.projectNumber = index;
    [self.navigationController pushViewController:proyectoVC animated:YES];
}*/

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

#pragma mark - Project Download 

/*-(void)updateProjectAtIndex:(NSUInteger)index {
    projectToDownloadIndex = index;
    Proyecto *proyecto = self.usuario.arrayProyectos[projectToDownloadIndex];
    
    self.navigationController.navigationBarHidden = YES;

    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    [dic setObject:proyecto forKey:@"Project"];
    [dic setObject:@(2000 + projectToDownloadIndex) forKey:@"Tag"];
    [dic setObject:self.progressView forKey:@"Sender"];
    [dic setObject:self.usuario forKey:@"Usuario"];
    [self performSelectorInBackground:@selector(downloadProject:) withObject:dic];
}

-(void)updateProject:(UIButton *)downloadButton {
    projectToDownloadIndex = downloadButton.tag - 1000;
    Proyecto *proyecto = self.usuario.arrayProyectos[projectToDownloadIndex];
    
    self.navigationController.navigationBarHidden = YES;
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    [dic setObject:proyecto forKey:@"Project"];
    [dic setObject:@(2000 + projectToDownloadIndex) forKey:@"Tag"];
    [dic setObject:self.progressView forKey:@"Sender"];
    [dic setObject:self.usuario forKey:@"Usuario"];
    [self performSelectorInBackground:@selector(downloadProject:) withObject:dic];
}*/

/*-(void)downloadProject:(NSMutableDictionary*)dic{
    NSLog(@"entré a descargar el proyectooo");
    Proyecto *proyecto=[dic objectForKey:@"Project"];
    if ([proyecto.data isEqualToString:@"1"]) {
        [self.progressView setViewAlphaToOne];
        [ProjectDownloader downloadProject:[dic objectForKey:@"Project"] yTag:[[dic objectForKey:@"Tag"]intValue] sender:self.progressView usuario:[dic objectForKey:@"Usuario"]];
        [self.progressView setViewAlphaToCero];
    }
}*/

-(BOOL)userCanPassToProjectAtIndex:(NSUInteger)index {
    
    FileSaver *fileSaver = [[FileSaver alloc] init];
    Proyecto *proyecto = self.usuario.arrayProyectos[index];
    NSUInteger tag = 2000 + index;
    NSString *composedTag=[NSString stringWithFormat:@"%i%@",tag,proyecto.idProyecto];
    if ([proyecto.data isEqualToString:@"0"]) {
        return NO;
    }
    
    if ([fileSaver getUpdateFileWithString:composedTag]) {
        if (![proyecto.actualizado isEqualToString:[fileSaver getUpdateFileWithString:composedTag]]) {
            if ([self.usuario.tipo isEqualToString:@"sellers"]) {
                return YES;
            } else {
                return NO;
            }
        } else {
            return YES;
        }
    } else {
        return NO;
    }
}

#pragma mark - Server Stuff

-(void)downloadProjectFromServerAtIndex:(NSUInteger)index {
    //[self showDownloadingView];
    
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
    //[self showDownloadingView];
    
    //Bool that indicates that we are going to download the project
    //from the server, and not access it from our core data data base
    getProjectFromTheDatabase = NO;
    fetchOnlyRenders = NO;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
        } else {
            NSLog(@"NO llegó respuesta del getProjectById");
        }
    } else {
        NSLog(@"La respuesta no corresponde con los métodos enviados");
    }
}

-(void)serverError:(NSError *)error {
    NSLog(@"error en el server con código %d: %@ %@", error.code, error, [error localizedDescription]);
    if (error.code == -1009) {
        //Network Error
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You need to be connected to internet to download the latest project version." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];

    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

#pragma mark - CoreData Stuff

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
    
    if (self.databaseDocument.documentState == UIDocumentStateNormal) {
        NSManagedObjectContext *context = self.databaseDocument.managedObjectContext;
        [Render deleteRendersForProjectWithID:projectID inManagedObjectContext:context];
        [Urbanization deleteUrbanizationsForProjectWithID:projectID inManagedObjectContext:context];
        [Group deleteGroupsForProjectWithID:projectID inManagedObjectContext:context];
        [Floor deleteFloorsForProjectWithID:projectID inManagedObjectContext:context];
        [Product deleteProductsForProjectWithID:projectID inManagedObjectContext:context];
        [Plant deletePlantsForProjectWithID:projectID inManagedObjectContext:context];
        [Space deleteSpacesForProjectWithID:projectID inManagedObjectContext:context];
        [Finish deleteFinishesForProjectWithID:projectID inManagedObjectContext:context];
        [FinishImage deleteFinishesImagesForProjectWithID:projectID inManagedObjectContext:context];
    }
    
    //Erase the project id from the ids array stored in filesaver
    FileSaver *fileSaver = [[FileSaver alloc] init];
    NSMutableArray *projectIDsArray = [fileSaver getDictionary:@"downloadedProjectsIDs"][@"projectIDsArray"];
    for (int i = 0; i < [projectIDsArray count]; i++) {
        NSNumber *identifier = projectIDsArray[i];
        NSString *savedProjectID = [NSString stringWithFormat:@"%d", [identifier intValue]];
        if ([projectID isEqualToString:savedProjectID]) {
            [projectIDsArray removeObjectAtIndex:i];
        }
    }
    [fileSaver setDictionary:@{@"projectIDsArray": projectIDsArray} withName:@"downloadedProjectsIDs"];
    
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

-(void)databaseDocumentIsReadyForSaving {
    if (self.databaseDocument.documentState == UIDocumentStateNormal) {
        //Start using the document
        NSManagedObjectContext *context = self.databaseDocument.managedObjectContext;
        
        if (!downloadEntireProject) {
            //Save only the renders and go to the slideshow
            
            NSMutableArray *rendersArray = [[NSMutableArray alloc] initWithCapacity:[self.rendersArray count]]; //Of Renders
            for (int i = 0; i < [self.rendersArray count]; i++) {
                NSDictionary *renderInfoDic = self.rendersArray[i];
                Render *render = [Render renderWithServerInfo:renderInfoDic inManagedObjectContext:context];
                [rendersArray addObject:render];
            }
            [self goToSlideshowWithRendersArray:rendersArray];
        
        } else {
            
            //Get the total number of files to download
            float filesDownloadedCounter = 0;
            float progressCompleted;
            float numberOfFiles = [self getNumberOfFilesToDownload];
            NSLog(@"Número de archivos a descargar: %f", numberOfFiles);
            
            //Dic to store all the core data objects and pass them to the next view controller
            NSMutableDictionary *projectDictionary = [[NSMutableDictionary alloc] init];
            
            //Save all the project info
            
            //Save render objects in core data
            NSMutableArray *rendersArray = [[NSMutableArray alloc] initWithCapacity:[self.rendersArray count]]; //Of Renders
            for (int i = 0; i < [self.rendersArray count]; i++) {
                NSDictionary *renderInfoDic = self.rendersArray[i];
                Render *render = [Render renderWithServerInfo:renderInfoDic inManagedObjectContext:context];
                [rendersArray addObject:render];
                
                filesDownloadedCounter ++;
                progressCompleted = filesDownloadedCounter / numberOfFiles;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"fileDownloaded" object:nil userInfo:@{@"Progress": @(progressCompleted)}];
            }
            
            //Save urbanization object in core data
            NSMutableArray *urbanizationsArray = [[NSMutableArray alloc] init];
            Urbanization *urbanization = [Urbanization urbanizationWithServerInfo:self.urbanizationDic inManagedObjectContext:context];
            [urbanizationsArray addObject:urbanization];
            filesDownloadedCounter ++;
            progressCompleted = filesDownloadedCounter / numberOfFiles;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"fileDownloaded" object:nil userInfo:@{@"Progress": @(progressCompleted)}];
            
            //Save group objects in Core Data
            NSMutableArray *groupsArray = [[NSMutableArray alloc] initWithCapacity:[self.groupsArray count]];
            for (int i = 0; i < [self.groupsArray count]; i++) {
                Group *group = [Group groupWithServerInfo:self.groupsArray[i] inManagedObjectContext:context];
                [groupsArray addObject:group];
                
                filesDownloadedCounter ++;
                progressCompleted = filesDownloadedCounter / numberOfFiles;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"fileDownloaded" object:nil userInfo:@{@"Progress": @(progressCompleted)}];
            }
            
            //Save Floor products in Core Data
            NSMutableArray *floorsArray = [[NSMutableArray alloc] initWithCapacity:[self.floorsArray count]];
            for (int i = 0; i < [self.floorsArray count]; i++) {
                Floor *floor = [Floor floorWithServerInfo:self.floorsArray[i] inManagedObjectContext:context];
                [floorsArray addObject:floor];
                
                filesDownloadedCounter ++;
                progressCompleted = filesDownloadedCounter / numberOfFiles;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"fileDownloaded" object:nil userInfo:@{@"Progress": @(progressCompleted)}];
            }
            
            //Save product objects in Core Data
            NSMutableArray *producstArray = [[NSMutableArray alloc] initWithCapacity:[self.productsArray count]];
            for (int i = 0; i < [self.productsArray count]; i++) {
                Product *product = [Product productWithServerInfo:self.productsArray[i] inManagedObjectContext:context];
                [producstArray addObject:product];
                
                filesDownloadedCounter ++;
                progressCompleted = filesDownloadedCounter / numberOfFiles;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"fileDownloaded" object:nil userInfo:@{@"Progress": @(progressCompleted)}];
            }
            
            //Save plants objects in Core Data
            NSMutableArray *plantsArray = [[NSMutableArray alloc] initWithCapacity:[self.plantsArray count]];
            for (int i = 0; i < [self.plantsArray count]; i++) {
                Plant *plant = [Plant plantWithServerInfo:self.plantsArray[i] inManagedObjectContext:context];
                [plantsArray addObject:plant];
                
                filesDownloadedCounter ++;
                progressCompleted = filesDownloadedCounter / numberOfFiles;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"fileDownloaded" object:nil userInfo:@{@"Progress": @(progressCompleted)}];
            }
            
            //Save spaces object in Core Data
            NSMutableArray *spacesArray = [[NSMutableArray alloc] initWithCapacity:[self.spacesArray count]];
            for (int i = 0; i < [self.spacesArray count]; i++) {
                Space *space = [Space spaceWithServerInfo:self.spacesArray[i] inManagedObjectContext:context];
                [spacesArray addObject:space];
                
                filesDownloadedCounter ++;
                progressCompleted = filesDownloadedCounter / numberOfFiles;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"fileDownloaded" object:nil userInfo:@{@"Progress": @(progressCompleted)}];
            }
            
            //Save finishes in Core Data
            NSMutableArray *finishesArray = [[NSMutableArray alloc] initWithCapacity:[self.finishesArray count]];
            for (int i = 0; i < [self.finishesArray count]; i++) {
                Finish *finish = [Finish finishWithServerInfo:self.finishesArray[i] inManagedObjectContext:context];
                [finishesArray addObject:finish];
                
                filesDownloadedCounter ++;
                progressCompleted = filesDownloadedCounter / numberOfFiles;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"fileDownloaded" object:nil userInfo:@{@"Progress": @(progressCompleted)}];
            }
            
            //Save finishes images in Core Data
            NSMutableArray *finishesImagesArray = [[NSMutableArray alloc] initWithCapacity:[self.finishesImagesArray count]];
            for (int i = 0; i < [self.finishesImagesArray count]; i++) {
                FinishImage *finishImage = [FinishImage finishImageWithServerInfo:self.finishesImagesArray[i] inManagedObjectContext:context];
                [finishesImagesArray addObject:finishImage];
                
                filesDownloadedCounter ++;
                progressCompleted = filesDownloadedCounter / numberOfFiles;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"fileDownloaded" object:nil userInfo:@{@"Progress": @(progressCompleted)}];
            }
            
            //Save all core data objects in our dictionary
            [projectDictionary setObject:self.userProjectsArray[self.carousel.currentItemIndex] forKey:@"project"];
            [projectDictionary setObject:rendersArray forKey:@"renders"];
            [projectDictionary setObject:urbanizationsArray forKey:@"urbanizations"];
            [projectDictionary setObject:groupsArray forKey:@"groups"];
            [projectDictionary setObject:floorsArray forKey:@"floors"];
            [projectDictionary setObject:producstArray forKey:@"products"];
            [projectDictionary setObject:plantsArray forKey:@"plants"];
            [projectDictionary setObject:spacesArray forKey:@"spaces"];
            [projectDictionary setObject:finishesArray forKey:@"finishes"];
            [projectDictionary setObject:finishesImagesArray forKey:@"finishImages"];
            
            //Save a key with file saver indicating that this project has been downloaded
            FileSaver *fileSaver = [[FileSaver alloc] init];
            if ([fileSaver getDictionary:@"downloadedProjectsIDs"][@"projectIDsArray"]) {
                //Get the array with the project's ids and add the new downloaded project id
                NSMutableArray *projectIDsArray = [fileSaver getDictionary:@"downloadedProjectsIDs"][@"projectIDsArray"];
                Project *project = self.userProjectsArray[self.carousel.currentItemIndex];
                [projectIDsArray addObject:project.identifier];
                [fileSaver setDictionary:@{@"projectIDsArray": projectIDsArray} withName:@"downloadedProjectsIDs"];
                NSLog(@"agregué el id %@ a filesaver", project.identifier);
            
            } else {
                //Create an array to store the downloaded project ids
                NSMutableArray *projectIDsArray = [[NSMutableArray alloc] init];
                Project *project = self.userProjectsArray[self.carousel.currentItemIndex];
                [projectIDsArray addObject:project.identifier];
                [fileSaver setDictionary:@{@"projectIDsArray": projectIDsArray} withName:@"downloadedProjectsIDs"];
                NSLog(@"cree un nuevo arreglo en filesaver con el projectID %@", project.identifier);
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadCompleted" object:nil userInfo:nil];
            [self goToProjectScreenWithProjectDic:projectDictionary];
        }
    }
}

-(NSUInteger)getNumberOfFilesToDownload {
    NSUInteger numberOfFiles = 0;
    numberOfFiles = [self.rendersArray count] + 1 + [self.groupsArray count] + [self.productsArray count] + [self.floorsArray count] + [self.plantsArray count] + [self.spacesArray count] + [self.finishesArray count] + [self.finishesImagesArray count];
    return numberOfFiles;
}

-(void)goToProjectScreenWithProjectDic:(NSDictionary *)dictionary {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    ProyectoViewController *proyectoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Proyecto"];
    proyectoVC.projectDic = dictionary;
    [self.navigationController pushViewController:proyectoVC animated:YES];
    //proyectoVC.proyecto = self.usuario.arrayProyectos[index];
    //proyectoVC.usuario = self.usuario;
    //proyectoVC.mainImage = [self imageFromProyectAtIndex:index];
    //proyectoVC.projectNumber = index;
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
        view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 260.0, 460.0)];
        view.layer.shadowColor = [UIColor blackColor].CGColor;
        view.layer.shadowOffset = CGSizeMake(5.0, 5.0);
        view.layer.shadowOpacity = 0.9;
        view.layer.shadowRadius = 5.0;
        
        //Main Project ImageView
        UIImageView *projectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 260.0, 460.0)];
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
    [downloadButton addTarget:self action:@selector(downloadProjectFromServer:) forControlEvents:UIControlEventTouchUpInside];
    //[downloadButton addTarget:self action:@selector(updateProject:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:downloadButton];
    
    ((UIImageView *)[view viewWithTag:2]).image = [self getLogoImageFromProjectAtIndex:index];
    ((UIImageView *)[view viewWithTag:1]).image = [self imageFromProyectAtIndex:index];
    return view;
}

-(CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionFadeMin:
            return -1.0;
            
        case iCarouselOptionFadeMax:
            return 1.0;
            
        case iCarouselOptionFadeRange:
            return 1.0;
            
        case iCarouselOptionFadeMinAlpha:
             return 0.0;
            
        case iCarouselOptionSpacing:
            //return 0.5;
            return 2.3;
            
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

-(void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
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
    
}

-(void)downloadViewWillDisappear:(DownloadView *)downloadView {
    [self.opacityView removeFromSuperview];
    self.opacityView = nil;
}

-(void)downloadViewDidDisappear:(DownloadView *)downloadView {
    [downloadView removeFromSuperview];
    downloadView = nil;
}

#pragma mark - Notification Handlers

/*-(void)downloadFinished:(NSNotification *)notification {
    [self startProjectImageSavingProcessAtIndex:projectToDownloadIndex];
}

-(void)alertViewAppear {
    NSString *message=NSLocalizedString(@"ErrorDescarga", nil);
    [[[UIAlertView alloc]initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
}*/

@end
