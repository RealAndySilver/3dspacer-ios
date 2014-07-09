//
//  BrujulaViewController.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 11/12/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "BrujulaViewController.h"
#import "CMMotionManager+Shared.h"

@interface BrujulaViewController ()

@end

@implementation BrujulaViewController
@synthesize path,externalImageView,gradosExtra;

- (void)viewDidLoad{
    [super viewDidLoad];
    
    NavController *navController = (NavController *)self.navigationController;
    //[navController setInterfaceOrientation:NO]; ********************************
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    adicionalGrados=DegreesToRadians(gradosExtra);
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if(orientation ==3){
            NSLog(@"OrientacionLandscape numero %i",orientation);
            diferenciaRotacion=0;
        }
        else if(orientation==4){
            NSLog(@"OrientacionLandscapeElse numero %i",orientation);
            diferenciaRotacion=0.5;
        }
    }
    self.navigationItem.title = NSLocalizedString(@"Compass View", nil);
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
    scrollViewRotar=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width)];
    scrollViewRotar.center=CGPointMake(self.view.frame.size.height/2, self.view.frame.size.width/2);
    scrollViewRotar.backgroundColor=[UIColor clearColor];
    scrollViewRotar.layer.cornerRadius=0;
    [scrollViewRotar setClipsToBounds:NO];
    scrollViewRotar.layer.masksToBounds=NO;
    [self.view addSubview:scrollViewRotar];
    maximumZoomScale=3.0;
    minimumZoomScale=1;
    [self loadScrollView];
    
        //_motionManager = [self motionManager];
    //[_motionManager setDeviceMotionUpdateInterval:1/60];
    //[_motionManager startDeviceMotionUpdates];
    //[_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical];
    
    zoomCheck=YES;
    /*timer=[[NSTimer alloc]init];
    timer =[NSTimer scheduledTimerWithTimeInterval:1/60 target:self selector:@selector(update) userInfo:nil repeats:YES];*/
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        brujula=[[BrujulaView alloc]initWithFrame:CGRectMake(self.view.frame.size.height-80, 60, 70, 70)];
    } else {
        brujula=[[BrujulaView alloc]initWithFrame:CGRectMake(self.view.frame.size.height-80, 60, 55, 55)];
    }
    [self.view addSubview:brujula];
    //[self.navigationItem setHidesBackButton:YES];
    // Do any additional setup after loading the view.
    
    [self startDeviceMotion];

}

-(void)update{
    if (brujula.isOn) {
        //_motionManager.showsDeviceMovementDisplay = YES;
        //attitude = _motionManager.deviceMotion.attitude;
        CGAffineTransform swingTransform = CGAffineTransformIdentity;
        swingTransform = CGAffineTransformRotate(swingTransform, [self radiansToDegrees:DegreesToRadians(attitude.yaw)+diferenciaRotacion]-adicionalGrados);
        CGAffineTransform swingTransform2 = CGAffineTransformIdentity;
        swingTransform2 = CGAffineTransformRotate(swingTransform2, [self radiansToDegrees:DegreesToRadians(attitude.yaw)+diferenciaRotacion]);
        scrollViewImagen.transform = swingTransform;
        brujula.cursor.transform = swingTransform2;
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
        //_motionManager.showsDeviceMovementDisplay = NO;
        CGAffineTransform swingTransform = CGAffineTransformIdentity;
        swingTransform = CGAffineTransformRotate(swingTransform, [self radiansToDegrees:DegreesToRadians(0)]);
        scrollViewImagen.transform = swingTransform;
        brujula.cursor.transform = swingTransform;
    }
    
}
- (float)radiansToDegrees:(float)number{
    return  number * 57.295780;
}
-(void)didReceiveMemoryWarning{
    //[self crearObjetos];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [scrollViewImagen setZoomScale:minimumZoomScale animated:NO];
    //[brujula changeState];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //[scrollViewUrbanismo setZoomScale:0.3 animated:NO];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //_motionManager.showsDeviceMovementDisplay = NO;
    //[timer invalidate];
    //timer = nil;
    //[_motionManager stopMagnetometerUpdates];
    //[_motionManager stopDeviceMotionUpdates];
    //_motionManager=nil;
    [[CMMotionManager sharedMotionManager] stopDeviceMotionUpdates];
    attitude=nil;
    NavController *navController = (NavController *)self.navigationController;
    //[navController setInterfaceOrientation:YES]; **********************************
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    NSLog(@"Orientation");
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
    (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)loadScrollView{
    scrollViewImagen=[[UIScrollView alloc]init];
    scrollViewImagen.frame=CGRectMake(0, 0, scrollViewRotar.frame.size.width, scrollViewRotar.frame.size.height);
    [scrollViewRotar addSubview:scrollViewImagen];
    [scrollViewImagen setClipsToBounds:NO];
    scrollViewImagen.layer.masksToBounds=NO;
    [scrollViewImagen setMinimumZoomScale:minimumZoomScale];
    [scrollViewImagen setMaximumZoomScale:maximumZoomScale];
    [scrollViewImagen setCanCancelContentTouches:NO];
    [scrollViewImagen setDelegate:self];
    [scrollViewImagen setShowsHorizontalScrollIndicator:NO];
    [scrollViewImagen setShowsVerticalScrollIndicator:NO];
    imageViewZoomImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, scrollViewImagen.frame.size.width, scrollViewImagen.frame.size.height)];
    //imageViewZoomImage.image=[UIImage imageWithContentsOfFile:path];
    imageViewZoomImage.image=externalImageView.image;
    imageViewZoomImage.contentMode = UIViewContentModeScaleAspectFill;

    [scrollViewImagen addSubview:imageViewZoomImage];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [scrollViewImagen addGestureRecognizer:doubleTap];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [scrollViewImagen addGestureRecognizer:singleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *subView = [scrollView.subviews objectAtIndex:0];
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    scrollView.contentInset = UIEdgeInsetsZero;
}
-(UIView *)viewForZoomingInScrollView:(UIScrollView*)scrollview{
    return imageViewZoomImage;
}
- (void)handleDoubleTap:(UIGestureRecognizer *)recognizer {
    NSLog(@"doubletap ");
    if(zoomCheck){
        CGPoint Pointview=[recognizer locationInView:scrollViewImagen];
        CGFloat newZoomscal=maximumZoomScale;
        
        newZoomscal=MIN(newZoomscal, maximumZoomScale);
        
        CGSize scrollViewSize=scrollViewImagen.bounds.size;
        
        CGFloat w=scrollViewSize.width/newZoomscal;
        CGFloat h=scrollViewSize.height /newZoomscal;
        CGFloat x= Pointview.x-(w/2.0);
        CGFloat y = Pointview.y-(h/2.0);
        
        CGRect rectTozoom=CGRectMake(x, y, w, h);
        [scrollViewImagen zoomToRect:rectTozoom animated:YES];
        
        [scrollViewImagen setZoomScale:maximumZoomScale animated:YES];
        zoomCheck=NO;
    }
    else{
        [scrollViewImagen setZoomScale:1.0 animated:YES];
        zoomCheck=YES;
    }
}

/*-(CMMotionManager *)motionManager{
    CMMotionManager *motionManager = nil;
    id appDelegate = [UIApplication sharedApplication].delegate;
    if ([appDelegate respondsToSelector:@selector(motionManager)]) {
        motionManager = [appDelegate motionManager];
    }
    return motionManager;
}*/

-(void)startDeviceMotion {
    CMMotionManager *motionManager = [CMMotionManager sharedMotionManager];
    if (motionManager.isDeviceMotionAvailable) {
        motionManager.deviceMotionUpdateInterval = 1.0/60.0;
        [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical
                                                           toQueue:[NSOperationQueue mainQueue]
                                                       withHandler:^(CMDeviceMotion *motion, NSError *error){
                                                           attitude = motion.attitude;
                                                           //NSLog(@"Z: %f", attitude.yaw);
                                                           [self update];
                                                       }];
    }
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
