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
@synthesize orient;
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
    return UIInterfaceOrientationMaskLandscape;
}
-(void)setInterfaceOrientation:(BOOL)orientation{
    orient=orientation;
}
@end
