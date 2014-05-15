//
//  TermsViewController.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 17/10/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
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
    textView.text=usuario.terminos;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark actions
-(IBAction)accept:(id)sender{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=NSLocalizedString(@"Cargando", nil);
    [self performSelector:@selector(go:) withObject:sender afterDelay:0.1];
    }
-(void)go:(id)sender{
    [rVC irAlSiguienteViewConUsuario:usuario yCopia:usuarioCopia];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)decline:(id)sender{
    [rVC stopSpinner];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark autorotation
-(BOOL)shouldAutorotate{
    return YES;
}
-(NSUInteger)supportedInterfaceOrientations{
        return UIInterfaceOrientationMaskPortrait;
}
@end
