//
//  BrujulaViewController.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 11/12/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "BrujulaViewController.h"

@interface BrujulaViewController ()

@end

@implementation BrujulaViewController
@synthesize path;

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Zoom", nil);
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
    scrollViewRotar=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.height-100, self.view.frame.size.width-50)];
    scrollViewRotar.center=CGPointMake(self.view.frame.size.height/2, self.view.frame.size.width/2);
    scrollViewRotar.backgroundColor=[UIColor clearColor];
    scrollViewRotar.layer.cornerRadius=0;
    [self.view addSubview:scrollViewRotar];
    maximumZoomScale=3.0;
    minimumZoomScale=1;
    [self loadScrollView];
    
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.showsDeviceMovementDisplay = YES;
    
    //[_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical];
        [_motionManager setDeviceMotionUpdateInterval:1/60];
        [_motionManager startDeviceMotionUpdates];
    //[_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical];
    
    zoomCheck=YES;
    timer=[[NSTimer alloc]init];
    timer =[NSTimer scheduledTimerWithTimeInterval:1/60 target:self selector:@selector(thread) userInfo:nil repeats:YES];
    brujula=[[BrujulaView alloc]initWithFrame:CGRectMake(self.view.frame.size.height-80, 60, 70, 70)];
    [self.view addSubview:brujula];
    // Do any additional setup after loading the view.
}
-(void)thread{
    //[self performSelectorInBackground:@selector(test) withObject:nil];
    NSThread *t=[[NSThread alloc]initWithTarget:self selector:@selector(test) object:nil];
    [t start];
}
-(void)test{
    attitude = _motionManager.deviceMotion.attitude;
    NSLog(@"Updating %f",attitude.yaw);
    CGAffineTransform swingTransform = CGAffineTransformIdentity;
    swingTransform = CGAffineTransformRotate(swingTransform, [self radiansToDegrees:DegreesToRadians(attitude.yaw)]);
    scrollViewRotar.transform = swingTransform;
    brujula.cursor.transform = swingTransform;
}
- (float)radiansToDegrees:(float)number{
    return  number * 57.295780;
}
-(void)didReceiveMemoryWarning{
    //[self crearObjetos];
}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [scrollViewImagen setZoomScale:minimumZoomScale animated:NO];
}
-(void)viewDidAppear:(BOOL)animated{
    //[scrollViewUrbanismo setZoomScale:0.3 animated:NO];
}
-(void)viewWillDisappear:(BOOL)animated{
    [timer invalidate];
    timer = nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
    (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)loadScrollView{
    scrollViewImagen=[[UIScrollView alloc]init];
    scrollViewImagen.frame=CGRectMake(0, 0, scrollViewRotar.frame.size.width, scrollViewRotar.frame.size.height);
    [scrollViewRotar addSubview:scrollViewImagen];
    [scrollViewImagen setMinimumZoomScale:minimumZoomScale];
    [scrollViewImagen setMaximumZoomScale:maximumZoomScale];
    [scrollViewImagen setCanCancelContentTouches:NO];
    scrollViewImagen.clipsToBounds = YES;
    [scrollViewImagen setDelegate:self];
    imageViewZoomImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, scrollViewImagen.frame.size.width, scrollViewImagen.frame.size.height)];
    imageViewZoomImage.image=[UIImage imageWithContentsOfFile:path];
    [scrollViewImagen addSubview:imageViewZoomImage];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [scrollViewImagen addGestureRecognizer:doubleTap];
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


@end
