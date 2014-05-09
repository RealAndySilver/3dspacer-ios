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

@interface MainCarouselViewController () <iCarouselDataSource, iCarouselDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) iCarousel *carousel;
@property (strong, nonatomic) UILabel *projectNameLabel;
@property (strong, nonatomic) NSMutableArray *projectsNamesArray;
@property (strong, nonatomic) UIPageControl *pageControl;
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
    self.navigationItem.title = @"Página Principal";
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.view.backgroundColor = [UIColor blackColor];
    [self setupUI];
}

-(void)setupUI {
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
    self.projectNameLabel.font = [UIFont systemFontOfSize:20.0];
    [self.view addSubview:self.projectNameLabel];
    
    //PageControl setup
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = [self.usuario.arrayProyectos count];
    [self.view addSubview:self.pageControl];
    
    //Logout button
    UIBarButtonItem *logoutBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(showLogoutAlert)];
    self.navigationItem.leftBarButtonItem = logoutBarButton;
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.carousel.frame = CGRectMake(0.0, 64.0, self.view.bounds.size.width, self.view.bounds.size.height - 64.0);
    self.projectNameLabel.frame = CGRectMake(self.view.bounds.size.width/2.0 - 200.0, 110.0, 400.0, 30.0);
    self.pageControl.frame = CGRectMake(self.view.bounds.size.width/2.0 - 150.0, self.view.bounds.size.height - 80.0, 300.0, 30.0);
}

#pragma mark - Custom methods 

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
        NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
        if (image) {
            [data2 writeToFile:jpegFilePath atomically:YES];
        }
        return image;
    }
    else {
        UIImage *image = [UIImage imageWithContentsOfFile:jpegFilePath];
        return image;
    }
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

#pragma mark - iCarouselDataSource 

-(NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [self.usuario.arrayProyectos count];
}

-(UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    if (!view) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 500.0, 500.0)];
        
        UIImageView *projectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 500.0, 500.0)];
        projectImageView.tag = 1;
        projectImageView.clipsToBounds = YES;
        projectImageView.contentMode = UIViewContentModeScaleAspectFill;
        projectImageView.backgroundColor = [UIColor grayColor];
        [view addSubview:projectImageView];
    }
    
    ((UIImageView *)[view viewWithTag:1]).image = [self imageFromProyectAtIndex:index];
    return view;
}

-(CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionFadeMin:
            return -0.2;
            
        case iCarouselOptionFadeMax:
            return 0.2;
            
        case iCarouselOptionFadeRange:
            return 1.0;
            
            /*case iCarouselOptionFadeMinAlpha:
             return 0.2;*/
            
        case iCarouselOptionSpacing:
            return 0.5;
            
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
    ProyectoViewController *proyectoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Proyecto"];
    proyectoVC.proyecto = self.usuario.arrayProyectos[index];
    proyectoVC.usuario = self.usuario;
    [self.navigationController pushViewController:proyectoVC animated:YES];
}

#pragma mark - iCarouselDelegate

-(void)carouselDidScroll:(iCarousel *)carousel {
    NSLog(@"Scrolling");
    self.projectNameLabel.text = self.projectsNamesArray[carousel.currentItemIndex];
    self.pageControl.currentPage = carousel.currentItemIndex;
}

@end
