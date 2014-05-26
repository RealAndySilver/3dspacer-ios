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

@interface HomeScreenViewController () <iCarouselDataSource, iCarouselDelegate>
@property (strong, nonatomic) iCarousel *carousel;
@property (strong, nonatomic) NSMutableArray *projectNamesArray;
@property (strong, nonatomic) UIButton *slideShowButton;
@property (strong, nonatomic) UIButton *logoutButton;
@property (strong, nonatomic) UIButton *messageButton;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIWindow *secondWindow;
@property (strong, nonatomic) ProgressView *progressView;
@end

@implementation HomeScreenViewController {
    CGRect screenBounds;
    NSUInteger projectToDownloadIndex;
}

#pragma mark - Lazy Instantiation

-(NSMutableArray *)projectNamesArray {
    if (!_projectNamesArray) {
        _projectNamesArray = [[NSMutableArray alloc] initWithCapacity:[self.usuario.arrayProyectos count]];
        for (Proyecto *proyecto in self.usuario.arrayProyectos) {
            [_projectNamesArray addObject:proyecto.nombre];
        }
    }
    return _projectNamesArray;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinished:) name:@"updates" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertViewAppear) name:@"alert" object:nil];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    CGRect screen = [UIScreen mainScreen].bounds;
    screenBounds = CGRectMake(0.0, 0.0, screen.size.height, screen.size.width);
    NSLog(@"screen boundsss:%@", NSStringFromCGRect(screenBounds));
    self.view.backgroundColor = [UIColor blackColor];
    [self startMainProjectImagesSavingProcess];
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)setupUI {
    //Background ImageView
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:screenBounds];
    backgroundImageView.image = [UIImage imageNamed:@"CarouselBackground.png"];
    [self.view addSubview:backgroundImageView];
    
    //Carousel
    self.carousel = [[iCarousel alloc] initWithFrame:screenBounds];
    self.carousel.delegate = self;
    self.carousel.dataSource = self;
    self.carousel.type = iCarouselTypeRotary;
    self.carousel.scrollSpeed = 0.5;
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
    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 15.0 - 40.0, screenBounds.size.height - 60.0, 40.0, 40.0)];
    [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.deleteButton];
    
    
    //Meesage button
    self.messageButton = [[UIButton alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 15.0 - 40.0 - 30.0 - 40.0, screenBounds.size.height - 60.0, 40.0, 40.0)];
    [self.messageButton setBackgroundImage:[UIImage imageNamed:@"Message.png"] forState:UIControlStateNormal];
    [self.messageButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.messageButton];
    
    //Add button
    self.logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 + 15.0 + 40.0 + 30.0, screenBounds.size.height - 60.0, 40.0, 40.0)];
    [self.logoutButton setBackgroundImage:[UIImage imageNamed:@"Add.png"] forState:UIControlStateNormal];
    [self.logoutButton addTarget:self action:@selector(showLogoutAlert) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.logoutButton];
    
    //Slideshow button
    self.slideShowButton = [[UIButton alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 + 15.0, screenBounds.size.height - 60.0, 40.0, 40.0)];
    [self.slideShowButton setBackgroundImage:[UIImage imageNamed:@"Slideshow.png"] forState:UIControlStateNormal];
    [self.slideShowButton addTarget:self action:@selector(startSlideshowProcess) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.slideShowButton];
    
    Proyecto *proyecto = self.usuario.arrayProyectos[0];
    if (![proyecto.arrayAdjuntos count] > 0) {
        self.slideShowButton.hidden = YES;
    }
    
    //ProgressView
    self.progressView=[[ProgressView alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.height, self.navigationController.view.frame.size.width)];
    
    [self.navigationController.view addSubview:self.progressView];
    [self.view bringSubviewToFront:self.progressView];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

#pragma mark - Actions 

-(void)goToProjectsList {
    ProjectsListViewController *projectsListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProjectsList"];
    [self.navigationController pushViewController:projectsListVC animated:YES];
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
}

-(void)downloadProject:(NSMutableDictionary*)dic{
    NSLog(@"entré a descargar el proyectooo");
    Proyecto *proyecto=[dic objectForKey:@"Project"];
    if ([proyecto.data isEqualToString:@"1"]) {
        [self.progressView setViewAlphaToOne];
        [ProjectDownloader downloadProject:[dic objectForKey:@"Project"] yTag:[[dic objectForKey:@"Tag"]intValue] sender:self.progressView usuario:[dic objectForKey:@"Usuario"]];
        [self.progressView setViewAlphaToCero];
    }
}

#pragma mark - Custom Methods

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

-(void)goToProjectAtIndex:(NSUInteger)index {
    /*ProyectoViewController *proyectoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Proyecto"];
    proyectoVC.proyecto = self.usuario.arrayProyectos[index];
    proyectoVC.usuario = self.usuario;
    proyectoVC.mainImage = [self projectImageAtIndex:index];
    proyectoVC.projectNumber = index;
    [self.navigationController pushViewController:proyectoVC animated:YES];*/
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

-(void)startMainProjectImagesSavingProcess {
    dispatch_queue_t ImageSaving = dispatch_queue_create("ImageSaving", NULL);
    dispatch_async(ImageSaving, ^(){
        [self saveMainProjectImagesInBackground];
        [self saveProjectLogoImagesInBackground];
    });
}

-(void)saveProjectLogoImagesInBackground {
    for (int i = 0; i < [self.usuario.arrayProyectos count]; i++) {
        Proyecto *proyecto = self.usuario.arrayProyectos[i];
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *jpegFilePath = [NSString stringWithFormat:@"%@/logo%@%@",docDir,proyecto.idProyecto,[IAmCoder encodeURL:proyecto.logo]];
        [ProjectDownloader addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:docDir]];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
        
        if (!fileExists) {
            NSURL *urlImagen=[NSURL URLWithString:proyecto.logo];
            NSData *data=[NSData dataWithContentsOfURL:urlImagen];
            UIImage *image = [UIImage imageWithData:data];
            NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
            if (image) {
                [data2 writeToFile:jpegFilePath atomically:YES];
            }
        }
    }
}

-(void)saveMainProjectImagesInBackground {
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

-(UIImage *)projectImageAtIndex:(NSUInteger)index {
    Proyecto *proyecto = self.usuario.arrayProyectos[index];
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/cover%@%@.jpeg",docDir,proyecto.idProyecto,[IAmCoder encodeURL:proyecto.imagen]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    
    if (!fileExists) {
        NSLog(@"No existe la imagen en el documents directory así que la convertiré desde NSData");
        NSURL *urlImagen=[NSURL URLWithString:proyecto.imagen];
        NSData *data=[NSData dataWithContentsOfURL:urlImagen];
        UIImage *image = [UIImage imageWithData:data];
        return image;
    }
    else {
        UIImage *image = [UIImage imageWithContentsOfFile:jpegFilePath];
        return image;
    }
}

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

-(void)updateProjectAtIndex:(NSUInteger)index {
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

-(UIImage *)getLogoImageFromProjectAtIndex:(NSUInteger)index {
    Proyecto *proyecto = self.usuario.arrayProyectos[index];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/logo%@%@",docDir,proyecto.idProyecto,[IAmCoder encodeURL:proyecto.logo]];
    [ProjectDownloader addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:docDir]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    
    if (!fileExists) {
        //NSLog(@"no existe proj img %@",jpegFilePath);
        NSURL *urlImagen = [NSURL URLWithString:proyecto.logo];
        NSData *data = [NSData dataWithContentsOfURL:urlImagen];
        UIImage *image = [UIImage imageWithData:data];
        return image;
    }
    else {
        UIImage *image = [UIImage imageWithContentsOfFile:jpegFilePath];
        return image;
    }
}

#pragma mark - iCarouselDataSource

-(NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [self.usuario.arrayProyectos count];
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
    }
    
    //Download button
    UIButton *downloadButton = [[UIButton alloc] initWithFrame:CGRectMake(view.frame.size.width/2.0 - 30.0, 10.0, 60.0, 60.0)];
    [downloadButton setBackgroundImage:[UIImage imageNamed:@"downloadBtn.png"] forState:UIControlStateNormal];
    downloadButton.tag = 1000 + index;
    [downloadButton addTarget:self action:@selector(updateProject:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:downloadButton];
    
    ((UIImageView *)[view viewWithTag:1]).image = [self projectImageAtIndex:index];
    ((UILabel *)[view viewWithTag:2]).text = self.projectNamesArray[index];
    ((UIImageView *)[view viewWithTag:3]).image = [self getLogoImageFromProjectAtIndex:index];

    return view;
}

#pragma mark - iCarouselDelegate

-(void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    NSLog(@"terminé de moverme");
    Proyecto *proyecto = self.usuario.arrayProyectos[carousel.currentItemIndex];
    if ([proyecto.arrayAdjuntos count] > 0) {
        self.slideShowButton.hidden = NO;
    } else {
        self.slideShowButton.hidden = YES;
    }
    
    BOOL projectIsDownloaded = [self userCanPassToProjectAtIndex:carousel.currentItemIndex];
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
            return 1.5;
            
        default:
            return value;
    }
}

-(void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    BOOL userCanGoToProjectDetails = [self userCanPassToProjectAtIndex:index];
    if (userCanGoToProjectDetails) {
        [self startProjectImageSavingProcessAtIndex:index];
    } else {
        [self updateProjectAtIndex:index];
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self logout];
    }
}

#pragma mark - Notification Handlers

-(void)downloadFinished:(NSNotification *)notification {
    [self carouselDidEndScrollingAnimation:self.carousel];
    [self startProjectImageSavingProcessAtIndex:projectToDownloadIndex];
}

-(void)alertViewAppear {
    NSString *message=NSLocalizedString(@"ErrorDescarga", nil);
    [[[UIAlertView alloc]initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
}

@end
