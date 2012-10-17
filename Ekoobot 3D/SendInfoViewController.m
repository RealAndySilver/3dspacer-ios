//
//  SendInfoViewController.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 17/10/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "SendInfoViewController.h"

@interface SendInfoViewController ()

@end

@implementation SendInfoViewController
@synthesize nombreProyecto;
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
    self.navigationItem.title=@"Enviar Información";
    server=[[ServerCommunicator alloc]init];
    server.caller=self;
    tituloProyectoLabel.text=nombreProyecto;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark actions
-(IBAction)send:(id)sender{
    if (![nombreTF.text isEqualToString:@""]) {
        if (![emailTF.text isEqualToString:@""]) {
            if (![comentarioTV.text isEqualToString:@""]) {
                FileSaver *file=[[FileSaver alloc]init];
                NSString *params=[NSString stringWithFormat:@"<ns:setRegister><username>%@</username><password>%@</password><register><name>%@</name><email>%@</email><project>%@</project></register></ns:setRegister>",[file getNombre],[file getPassword],nombreTF.text,emailTF.text,nombreProyecto];
                [server callServerWithMethod:@"" andParameter:params];
            }
            else{
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Debe agregar un comentario." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Debe ingresar un correo electrónico." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Debe ingresar un nombre." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

@end