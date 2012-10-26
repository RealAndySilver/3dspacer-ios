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
@synthesize nombreProyecto,usuario,contrasena,proyectoID,currentUser;
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
    [self.navigationItem setHidesBackButton:YES];
    if ([currentUser.tipo isEqualToString:@"sellers"]) {
        methodName=@"setRegister";
        self.navigationItem.title=@"Enviar Proyecto";
    }
    else{
        methodName=@"sendSuggest";
        self.navigationItem.title=@"Recomendar Proyecto";
    }
    
    
    nombreTF.delegate=self;
    emailTF.delegate=self;
    comentarioTV.delegate=self;
    server=[[ServerCommunicator alloc]init];
    server.caller=self;
    tituloProyectoLabel.text=nombreProyecto;
	// Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    initialFrame=container.frame;
    finalFrame=CGRectMake(161, 0, 710, 494);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark actions
-(IBAction)send:(id)sender{
    NSLog(@"--------------> %@ %@",usuario,contrasena);
    if ([currentUser.tipo isEqualToString:@"sellers"]) {
        
        if (![nombreTF.text isEqualToString:@""]) {
            if (![emailTF.text isEqualToString:@""]) {
                if (![comentarioTV.text isEqualToString:@""]) {
                    NSLog(@"Usuario :%@ \nContrasena : %@",usuario,contrasena);
                    NSString *params=[NSString stringWithFormat:@"<ns:setRegister><username>%@</username><password>%@</password><register><name>%@</name><email>%@</email><comments>%@</comments><project>%@</project></register></ns:setRegister>",usuario,contrasena,nombreTF.text,emailTF.text,comentarioTV.text,proyectoID];
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
    else{
        if (![nombreTF.text isEqualToString:@""]) {
            if (![emailTF.text isEqualToString:@""]) {
                if (![comentarioTV.text isEqualToString:@""]) {
                    NSLog(@"Usuario :%@ \nContrasena : %@",usuario,contrasena);
                    NSString *params=[NSString stringWithFormat:@"<ns:sendSuggest><username>%@</username><password>%@</password><register><name>%@</name><email>%@</email><comments>%@</comments><project>%@</project></register></ns:sendSuggest>",usuario,contrasena,nombreTF.text,emailTF.text,comentarioTV.text,proyectoID];
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
}
-(IBAction)cancel:(id)sender{
    [self customLogoutAlert];
}
- (void)customLogoutAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cancelar Envía"
                                                    message:@"¿Está seguro que desea cancelar?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancelar"
                                          otherButtonTitles:@"OK",nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"OK"])
    {
        [self goBack];
    }
}
-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)receivedDataFromServerRegister:(id)sender{
    server=sender;
    //NSLog(@"Resultado %@",server.resDic );
    NSString *tempMethod=[NSString stringWithFormat:@"ns1:%@Response",methodName];
    NSDictionary *dic=[[server.resDic objectForKey:tempMethod]objectForKey:@"return"];
}
-(void)receivedDataFromServerWithError:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Su mensaje no pudo ser enviado.\nPor favor intente de nuevo."
                                                   delegate:nil
                                          cancelButtonTitle:@"Cancelar"
                                          otherButtonTitles:nil,nil];
    [alert show];
}
#pragma text delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    touchFlag=YES;
    [self animarHasta:finalFrame];
}
-(void)textViewDidBeginEditing:(UITextView *)textView{
    touchFlag=YES;
    [self animarHasta:finalFrame];
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    touchFlag=NO;
    [self performSelector:@selector(delayed) withObject:nil afterDelay:0.01];
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    touchFlag=NO;
    [self performSelector:@selector(delayed) withObject:nil afterDelay:0.01];
}
-(void)delayed{
    if (!touchFlag) {
        [self animarHasta:initialFrame];
    }
}
#pragma mark animacion
-(void)animarHasta:(CGRect)hasta{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    container.frame=hasta;
    [UIView commitAnimations];
}
@end
