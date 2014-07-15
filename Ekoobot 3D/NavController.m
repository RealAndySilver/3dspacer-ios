//
//  NavController.m
//  Ekoobot 3D
//
//  Created by Andrés Abril on 25/09/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import "NavController.h"

@interface NavController ()

@end

@implementation NavController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.orient=YES;
    self.orientationType=1;//all orientations
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)shouldAutorotate{
    return self.orient;
}
-(NSUInteger)supportedInterfaceOrientations{
    if (self.orientationType==1) {
        return UIInterfaceOrientationMaskAll;
    }
    else {
        return UIInterfaceOrientationMaskLandscape;
    }
}

-(void)setInterfaceOrientation:(BOOL)orientation{
    self.orient=orientation;
}
-(void)forceLandscapeMode{
    if(UIDeviceOrientationIsPortrait(self.interfaceOrientation)){
        int type = [[UIDevice currentDevice] orientation];
        BOOL leftRotated=NO;
        if(type ==3){
            leftRotated=NO;
        }
        else if(type==4){
            leftRotated=YES;
        }
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
            
        {
            objc_msgSend([UIDevice currentDevice], @selector(setOrientation:), UIInterfaceOrientationLandscapeLeft );
            NSLog(@"dentro del if portrait");
        }
    }
}
-(void)forceLandscapeFromLandscape{
    if(UIDeviceOrientationIsLandscape(self.interfaceOrientation)){
        int type = [[UIDevice currentDevice] orientation];
        BOOL leftRotated=NO;
        if(type ==3){
            leftRotated=NO;
        }
        else if(type==4){
            leftRotated=YES;
        }
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
            
        {
            if (leftRotated) {
                objc_msgSend([UIDevice currentDevice], @selector(setOrientation:), UIInterfaceOrientationLandscapeLeft );
                NSLog(@"dentro del 1er if landscapeleft");
                return;
            }
            else{
                objc_msgSend([UIDevice currentDevice], @selector(setOrientation:), UIInterfaceOrientationLandscapeRight );
                NSLog(@"dentro del 2ndo if landscaperight");
                return;
            }
        }
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    [self.view.layer addAnimation:[NavAnimations navAlphaAnimation] forKey:nil];
		UIViewController *viewController = [super popViewControllerAnimated:NO];
        
		return viewController;
}
@end
