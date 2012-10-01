//
//  FirstViewController.m
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 4/17/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

#pragma mark -
#pragma mark Ciclo de Vida
#define NOMBREUSER @"cata"
#define PASSWORD @"1234"

- (void)viewDidLoad{
    [super viewDidLoad];
    usuarioTF.delegate=self;
    passwordTF.delegate=self;
    sc=[[ServerCommunicator alloc]init];    
    sc.caller=self;
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden= YES;
    spinner.alpha=0;
    usuarioTF.text=NOMBREUSER;
    passwordTF.text=PASSWORD;
    [self inicializarRootViewControllerConAnimaciones];
    keyboardIsMoved = NO;
    NavController *navController = (NavController *)self.navigationController;
    [navController setOrientationType:1];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || 
    (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)viewWillDisappear:(BOOL)animated{
    [spinner stopAnimating];
}

#pragma mark -
#pragma mark Carga de Objetos en Login

- (void)inicializarRootViewControllerConAnimaciones{
    /*[self animarView:loginViewContainer
          DesdeAlpha:0.0 
               hasta:1.0 
          desdeLaPos:loginViewContainer.frame 
               hasta:loginViewContainer.frame 
       conDuracionDe:4.0];*/
}

#pragma mark -
#pragma mark Accion de Boton

- (void)irAlSiguienteViewConUsuario:(id)usuario yCopia:(id)copia{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    ListadoDeProyectosVC *lVC=[[ListadoDeProyectosVC alloc]init];
    lVC=[self.storyboard instantiateViewControllerWithIdentifier:@"ListadoDeProyectosVC"];
    lVC.usuarioActual=usuario;
    lVC.usuarioCopia=copia;
    [self.navigationController pushViewController:lVC animated:NO];
}

- (void)alertSimpleConTitulo:(NSString*)elTitulo yMensaje:(NSString*)mensaje{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:elTitulo 
                                                 message:mensaje 
                                                delegate:nil 
                                       cancelButtonTitle:@"OK" 
                                       otherButtonTitles:nil, nil];
    [alert show];
}

- (void)startSpinner{
    spinner.alpha=1;
    [spinner startAnimating];
}

#pragma mark -
#pragma mark Eventos de Text Fields




- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self comprobarUsuario];
    return YES;
}

#pragma mark -
#pragma mark Comprobacion de usuario
- (void)comprobarUsuario{
    contrasenaString=passwordTF.text;
    usuarioString=usuarioTF.text;
    if ([usuarioString isEqualToString:@"admin"]&&[contrasenaString isEqualToString:@"admin"]) {
        EraseViewController *eVC=[[EraseViewController alloc]init];
        eVC=[self.storyboard instantiateViewControllerWithIdentifier:@"Erase"];
        [self.navigationController pushViewController:eVC animated:YES];
    }
    else{
    NSString *parameters=[NSString stringWithFormat:@"<ns:getData><username>%@</username><password>%@</password></ns:getData>",usuarioString,contrasenaString];
    [sc callServerWithMethod:@"" andParameter:parameters];
    
        NSThread *secThread=[[NSThread alloc]initWithTarget:self 
                                                   selector:@selector(startSpinner) 
                                                     object:nil];
        [secThread start];
    }
}

#pragma mark -
#pragma mark IBActions

- (IBAction)goToNext{
    [self comprobarUsuario];
}

#pragma mark -
#pragma mark Animaciones

- (void)animarView:(UIView*)view 
       DesdeAlpha:(float)alphaInicial 
            hasta:(float)alphaFinal 
       desdeLaPos:(CGRect)posIni 
            hasta:(CGRect)posFinal 
    conDuracionDe:(float)segundos{
    
    view.frame=posIni;
    view.alpha=alphaInicial;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:segundos];
    view.frame=posFinal;
    view.alpha=alphaFinal;
    [UIView commitAnimations];
}

-(void)receivedDataFromServer:(id)sender{
    sc=sender;
    if ([sc.resDic objectForKey:@"usuario"]) {
        Usuario *usuario=[[Usuario alloc]initWithDictionary:[sc.resDic objectForKey:@"usuario"]];
        Usuario *usuarioCopia=[[Usuario alloc]initWithDictionary:[sc.resDic objectForKey:@"usuario"]];
        FileSaver *fileSaver=[[FileSaver alloc]init];
        
        [fileSaver setDictionary:[sc.resDic objectForKey:@"usuario"]
                      withUserId:[[sc.resDic objectForKey:@"usuario"]objectForKey:@"id_usuario"]];
        
        [fileSaver setUserName:usuarioTF.text
                      password:passwordTF.text
                         andId:[[sc.resDic objectForKey:@"usuario"]objectForKey:@"id_usuario"]];
        
        [self irAlSiguienteViewConUsuario:usuario yCopia:usuarioCopia];
    }
    else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Nombre de usuario o contraseña incorrectos" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        spinner.alpha=0;
        [spinner stopAnimating];
    }
    
}
-(void)receivedDataFromServerWithError:(id)sender{
    FileSaver *fileSaver=[[FileSaver alloc]init];
    NSLog(@"saver %@",[fileSaver getUserWithName:usuarioTF.text andPassword:passwordTF.text]);
    if(![fileSaver getUserWithName:usuarioTF.text andPassword:passwordTF.text]){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Nombre de usuario o contraseña incorrectos" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        spinner.alpha=0;
        [spinner stopAnimating];
    }
    else{
        NSString *idLocal=[fileSaver getUserWithName:usuarioString andPassword:contrasenaString];
        Usuario *usuario=[[Usuario alloc]initWithDictionary:[fileSaver getDictionary:idLocal]];
        Usuario *usuarioCopia=[[Usuario alloc]initWithDictionary:[fileSaver getDictionary:idLocal]];

        [self irAlSiguienteViewConUsuario:usuario yCopia:usuarioCopia];
    }
    
    
}
@end