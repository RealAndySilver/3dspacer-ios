//
//  SlideshowViewController.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 4/08/13.
//  Copyright (c) 2013 Ekoomedia. All rights reserved.
//

#import "SlideshowViewController.h"
#import "NavController.h"
#import "AppDelegate.h"

@interface SlideshowViewController ()

@end

@implementation SlideshowViewController
@synthesize imagePathArray,window;

-(void)lockScreenToLandscape {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.screenIsAllOrientations = NO;
    appDelegate.screenIsLandscapeLeftOnly = NO;
    appDelegate.screenIsLandscapeRightOnly = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [self lockScreenToLandscape];
    self.navigationController.navigationBarHidden = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(play:) name:@"play" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop:) name:@"stop" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAnimationTime:) name:@"setAnimation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setTransitionTime:) name:@"setTransition" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(next:) name:@"next" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(last:) name:@"previous" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transitionType:) name:@"transitionType" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissWindow) name:@"back" object:nil];

    
    NSLog(@"Window bounds %fx%f",window.bounds.size.width,window.bounds.size.height);
    if (window.bounds.size.width>0)
        slideshow = [[KASlideShow alloc] initWithFrame:CGRectMake(0,0,window.bounds.size.width,window.bounds.size.height)];
    else{
        slideshow = [[KASlideShow alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.height,self.view.bounds.size.width)];
    }
    [slideshow setDelay:2]; // Delay between transitions
    [slideshow setTransitionDuration:2]; // Transition duration
    [slideshow setTransitionType:KASlideShowTransitionFade]; // Choose a transition type (fade or slide)
    [slideshow setImagesContentMode:UIViewContentModeScaleAspectFill]; // Choose a content mode for images to display
    /*for (NSString *path in imagePathArray) {
        [slideshow addImage:[UIImage imageWithContentsOfFile:path]];
    }*/
    
    for (UIImage *renderImage in self.imagesArray) {
        [slideshow addImage:renderImage];
    }
    if(!window.bounds.size.width>0){
        [slideshow start];
    }
    [self.view addSubview:slideshow];
}
-(void)dismissWindow{
    window.screen=nil;
    [window resignKeyWindow];
    window.hidden=YES;
    [window removeFromSuperview];
    window=nil;
}

-(void)unlockScreenToAllOrientations {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.screenIsAllOrientations = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NavController *navController = (NavController *)self.navigationController;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self unlockScreenToAllOrientations];
        [navController setOrientationType:1];
    }
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
#pragma mark - notification or delegate controls for screen
-(void)play:(UIButton*)button{
    [slideshow start];
    NSLog(@"Slideshow playing");
}
-(void)stop:(UIButton*)button{
    [slideshow stop];
    NSLog(@"Slideshow Stoping");
}
-(void)next:(UIButton*)button{
    [slideshow next];
    NSLog(@"Slideshow nexting");
}
-(void)last:(UIButton*)button{
    [slideshow previous];
    NSLog(@"Slideshow previousing");
}
-(void)transitionType:(NSNotification*)notification{
    UISegmentedControl *segment=notification.object;
    if (segment.selectedSegmentIndex==KASlideShowTransitionFade) {
        [slideshow setTransitionType:KASlideShowTransitionFade];
        NSLog(@"Slideshow type fade");
    }
    else{
        [slideshow setTransitionType:KASlideShowTransitionSlide];
        NSLog(@"Slideshow type slide");
    }
}
-(void)setAnimationTime:(NSNotification*)notification{
    UIStepper *stepper=notification.object;
    [slideshow setTransitionDuration:stepper.value];
    NSLog(@"Duración de la animación %.0f",stepper.value);
}
-(void)setTransitionTime:(NSNotification*)notification{
    UIStepper *stepper=notification.object;
    [slideshow setDelay:stepper.value];
    NSLog(@"Duración de la transición %.0f",stepper.value);
}
@end

