//
//  ZoomViewController.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 10/12/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "ZoomViewController.h"

@interface ZoomViewController ()

@end

@implementation ZoomViewController
@synthesize path;

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Zoom", nil);
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackTranslucent;
    
    maximumZoomScale=3.0;
    minimumZoomScale=1;
    [self loadScrollView];
    
    zoomCheck=YES;
    // Do any additional setup after loading the view.
}
-(void)didReceiveMemoryWarning{
    //[self crearObjetos];
}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [scrollViewImagen setZoomScale:1.2 animated:NO];
    
}
-(void)viewDidAppear:(BOOL)animated{
    //[scrollViewUrbanismo setZoomScale:0.3 animated:NO];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
    (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)loadScrollView{
    scrollViewImagen=[[UIScrollView alloc]init];
    scrollViewImagen.frame=CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
    [self.view addSubview:scrollViewImagen];
    [scrollViewImagen setMinimumZoomScale:minimumZoomScale];
    [scrollViewImagen setMaximumZoomScale:maximumZoomScale];
    [scrollViewImagen setCanCancelContentTouches:NO];
    scrollViewImagen.clipsToBounds = YES;
    [scrollViewImagen setDelegate:self];
    imageViewZoomImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, scrollViewImagen.frame.size.width, scrollViewImagen.frame.size.height)];
    imageViewZoomImage.image=[UIImage imageWithContentsOfFile:path];
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


@end
