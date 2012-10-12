//
//  NavController.m
//  Ekoobot 3D
//
//  Created by Andrés Abril on 25/09/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "NavController.h"

@interface NavController ()

@end

@implementation NavController
@synthesize orient,orientationType;
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
    orient=YES;
    orientationType=1;//all orientations
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)shouldAutorotate{
    return orient;
}
-(NSUInteger)supportedInterfaceOrientations{
    if (orientationType==1) {
        return UIInterfaceOrientationMaskAll;
    }
    else {
        return UIInterfaceOrientationMaskLandscape;
    }
}
-(void)setInterfaceOrientation:(BOOL)orientation{
    orient=orientation;
}
-(void)forceLandscapeMode{
    if(UIDeviceOrientationIsPortrait(self.interfaceOrientation)){
        NSLog(@"dentro del 1er if");
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
        {
            objc_msgSend([UIDevice currentDevice], @selector(setOrientation:), UIInterfaceOrientationLandscapeLeft );
            NSLog(@"dentro del 2ndo if");
        }
    }
}
@end
