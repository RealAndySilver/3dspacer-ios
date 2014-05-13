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
#import "ProjectDownloader.h"
#import "MBProgressHud.h"
#import "ProjectsListViewController.h"

@interface MainCarouselViewController () <iCarouselDataSource, iCarouselDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) iCarousel *carousel;
@property (strong, nonatomic) UILabel *projectNameLabel;
@property (strong, nonatomic) NSMutableArray *projectsNamesArray;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UIWindow *secondWindow;
@property (strong, nonatomic) UIButton *slideShowButton;
@end

@implementation MainCarouselViewController

#pragma mark - Lazy Instantiation

-(NSMutableArray *)projectsNamesArray {
    if (!_projectsNamesArray) {
        _projectsNamesArray = [NSMutableArray arrayWithCapacity:[self.usuario.arrayProyectos count]];
        for (int i = 0; i < [self.usuario.arrayProyectos count]; i++) {
            Proyecto *proyecto = self.usuario.arrayProyectos[i];
            [_projectsNamesArray addObject:proyecto.nombre];
        }
    }
    return _projectsNamesArray;
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    [self performSelectorInBackground:@selector(saveMainProjectImages) withObject:nil];
    self.navigationItem.title = @"Página Principal";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
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
    backgroundImageView.image = [UIImage imageNamed:@"CarouselBackground.png"];
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
    self.projectNameLabel.textColor = [UIColor whiteColor];
    self.projectNameLabel.font = [UIFont boldSystemFontOfSize:25.0];
    [self.view addSubview:self.projectNameLabel];
    
    //PageControl setup
    /*self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = [self.usuario.arrayProyectos count];
    [self.view addSubview:self.pageControl];*/
    
    //Logout button
    /*UIBarButtonItem *logoutBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(showLogoutAlert)];
    self.navigationItem.leftBarButtonItem = logoutBarButton;*/
    
    //Ekoomedia Logo
    UIImageView *ekoomediaLogo = [[UIImageView alloc] initWithFrame:CGRectMake(screenRect.size.width - 100.0, 20.0, 80.0, 80.0)];
    ekoomediaLogo.image = [UIImage imageNamed:@"logo.png"];
    ekoomediaLogo.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:ekoomediaLogo];
    
    //Logout button
    UIButton *logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 30.0, 100.0, 44.0)];
    [logoutButton setTitle:NSLocalizedString(@"CerrarSesion", nil) forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(showLogoutAlert) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logoutButton];
    
    //Delete button
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(screenRect.size.width/2.0 - 15.0 - 48.0 - 30.0 - 48.0, screenRect.size.height - 80.0, 48.0, 48.0)];
    [deleteButton setBackgroundImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
    [self.view addSubview:deleteButton];
    
    //Meesage button
    UIButton *messageButton = [[UIButton alloc] initWithFrame:CGRectMake(screenRect.size.width/2.0 - 15.0 - 48.0, screenRect.size.height - 80.0, 48.0, 48.0)];
    [messageButton setBackgroundImage:[UIImage imageNamed:@"Message.png"] forState:UIControlStateNormal];
    [messageButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:messageButton];
    
    //Add button
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(screenRect.size.width/2.0 + 15.0, screenRect.size.height - 80.0, 48.0, 48.0)];
    [addButton setBackgroundImage:[UIImage imageNamed:@"Add.png"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(goToProjectsList) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];
    
    //Slideshow button
    self.slideShowButton = [[UIButton alloc] initWithFrame:CGRectMake(screenRect.size.width/2.0 + 15.0 + 48.0 + 30.0, screenRect.size.height - 80.0, 48.0, 48.0)];
    [self.slideShowButton setBackgroundImage:[UIImage imageNamed:@"Slideshow.png"] forState:UIControlStateNormal];
    [self.slideShowButton addTarget:self action:@selector(startSlideshowProcess) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.slideShowButton];
    
    Proyecto *proyecto = self.usuario.arrayProyectos[0];
    if (![proyecto.arrayAdjuntos count] > 0) {
        self.slideShowButton.hidden = YES;
    }
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.carousel.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.projectNameLabel.frame = CGRectMake(self.view.bounds.size.width/2.0 - 200.0, 55.0, 400.0, 30.0);
    self.pageControl.frame = CGRectMake(self.view.bounds.size.width/2.0 - 150.0, self.view.bounds.size.height - 60.0, 300.0, 30.0);
}

#pragma mark - Custom methods 

-(void)saveMainProjectImages {
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
}

-(UIImage *)imageFromProyectAtIndex:(NSUInteger)index {
    Proyecto *proyecto = self.usuario.arrayProyectos[index];
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/cover%@%@.jpeg",docDir,proyecto.idProyecto,[IAmCoder encodeURL:proyecto.imagen]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    
    if (!fileExists) {
        //NSLog(@"no existe proj img %@",jpegFilePath);
        NSURL *urlImagen=[NSURL URLWithString:proyecto.imagen];
        NSData *data=[NSData dataWithContentsOfURL:urlImagen];
        UIImage *image = [UIImage imageWithData:data];
        /*NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
        if (image) {
            [data2 writeToFile:jpegFilePath atomically:YES];
        }*/
        return image;
    }
    else {
        UIImage *image = [UIImage imageWithContentsOfFile:jpegFilePath];
        return image;
    }
}

-(NSArray *)arrayOfImagePathsFromProjectAtIndex:(NSUInteger)index {
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
                
                /*NSURL *urlImagen=[NSURL URLWithString:adjunto.imagen];
                NSData *data=[NSData dataWithContentsOfURL:urlImagen];
                UIImage *image = [UIImage imageWithData:data];
                NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
                if (image) {
                    [data2 writeToFile:jpegFilePath atomically:YES];
                    [projectImagesArray addObject:jpegFilePath];
                }*/
            }
        }
    }
    return projectImagesArray;
}

#pragma mark - Actions 

-(void)startProjectImageSavingProcessAtIndex:(NSUInteger)index {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_queue_t imageSavingTask = dispatch_queue_create("ProjectImageSaving", NULL);
    dispatch_async(imageSavingTask, ^(){
        [self saveProjectImagesInBackgroundAtIndex:index];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self goToProjectAtIndex:index];
        });
    });
}

-(void)startSlideshowProcess {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSUInteger projectIndex = self.carousel.currentItemIndex;
    
    dispatch_queue_t imageSavingTask = dispatch_queue_create("ImageSaving", NULL);
    dispatch_async(imageSavingTask, ^(){
        [self saveProjectImagesInBackgroundAtIndex:projectIndex];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self goToSlideshow];
        });
    });
}

-(void)saveProjectImagesInBackgroundAtIndex:(NSUInteger)index {
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
}

-(void)goToSlideshow {
    SlideshowViewController *ssVC=[[SlideshowViewController alloc]init];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ssVC.imagePathArray = [self arrayOfImagePathsFromProjectAtIndex:self.carousel.currentItemIndex];
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
    Proyecto *proyecto = self.usuario.arrayProyectos[self.carousel.currentItemIndex];
    
    SendInfoViewController *sendInfoVC=[[SendInfoViewController alloc]init];
    sendInfoVC=[self.storyboard instantiateViewControllerWithIdentifier:@"SendInfo"];
    sendInfoVC.nombreProyecto = proyecto.nombre;
    sendInfoVC.proyectoID = proyecto.idProyecto;
    sendInfoVC.usuario = self.usuario.usuario;
    sendInfoVC.currentUser = self.usuario;
    sendInfoVC.contrasena = self.usuario.contrasena;
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
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)goToProjectAtIndex:(NSUInteger)index {
    ProyectoViewController *proyectoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Proyecto"];
    proyectoVC.proyecto = self.usuario.arrayProyectos[index];
    proyectoVC.usuario = self.usuario;
    proyectoVC.mainImage = [self imageFromProyectAtIndex:index];
    proyectoVC.projectNumber = index;
    [self.navigationController pushViewController:proyectoVC animated:YES];
}

-(void)goToProjectsList {
    ProjectsListViewController *projectsListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProjectsList"];
    [self.navigationController pushViewController:projectsListVC animated:YES];
}

#pragma mark - iCarouselDataSource 

-(NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [self.usuario.arrayProyectos count];
}

-(UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    if (!view) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 530.0)];
        view.layer.shadowColor = [UIColor blackColor].CGColor;
        view.layer.shadowOffset = CGSizeMake(5.0, 5.0);
        view.layer.shadowOpacity = 0.9;
        view.layer.shadowRadius = 5.0;
        
        UIImageView *projectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 530.0)];
        projectImageView.tag = 1;
        projectImageView.clipsToBounds = YES;
        projectImageView.contentMode = UIViewContentModeScaleAspectFill;
        projectImageView.backgroundColor = [UIColor grayColor];
        projectImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        projectImageView.layer.borderWidth = 4.0;
        
        [view addSubview:projectImageView];
    }
    
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

-(void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    [self startProjectImageSavingProcessAtIndex:index];
}

-(void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    NSLog(@"terminé de moverme");
    Proyecto *proyecto = self.usuario.arrayProyectos[carousel.currentItemIndex];
    if ([proyecto.arrayAdjuntos count] > 0) {
        self.slideShowButton.hidden = NO;
    } else {
        self.slideShowButton.hidden = YES;
    }
}

#pragma mark - iCarouselDelegate

-(void)carouselDidScroll:(iCarousel *)carousel {
    NSLog(@"Scrolling");
    self.projectNameLabel.text = self.projectsNamesArray[carousel.currentItemIndex];
    self.pageControl.currentPage = carousel.currentItemIndex;
}

@end
