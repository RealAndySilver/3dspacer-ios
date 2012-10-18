//
//  TermsViewController.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 17/10/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "TermsViewController.h"
#import "RootViewController.h"

@interface TermsViewController ()

@end

@implementation TermsViewController
@synthesize VC,usuario,usuarioCopia;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    rVC=VC;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark actions
-(IBAction)accept:(id)sender{
    [rVC irAlSiguienteViewConUsuario:usuario yCopia:usuarioCopia];
    [self dismissModalViewControllerAnimated:YES];
}
-(IBAction)decline:(id)sender{
    [rVC stopSpinner];
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark autorotation
-(BOOL)shouldAutorotate{
    return YES;
}
-(NSUInteger)supportedInterfaceOrientations{
        return UIInterfaceOrientationPortrait;
}
@end
