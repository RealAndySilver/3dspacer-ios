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
#define NOMBREUSER @"ekoomedia"
#define PASSWORD @"1234"

- (void)viewDidLoad{
    [super viewDidLoad];
    usuarioTF.delegate=self;
    passwordTF.delegate=self;
    sc=[[ServerCommunicator alloc]init];    
    sc.caller=self;
    littleBoxView=[[UIView alloc]initWithFrame:CGRectMake(infoButton.frame.origin.x+40, infoButton.frame.origin.y-90,200, 200)];
    littleBoxView.backgroundColor=[UIColor underPageBackgroundColor];
    littleBoxView.layer.cornerRadius=10.0f;
    littleBoxView.layer.masksToBounds=YES;
    littleBoxView.alpha=0;
    littleBoxView.layer.masksToBounds=YES;
    littleBoxView.layer.shouldRasterize=YES;
    littleBoxView.layer.shadowOffset=CGSizeMake(0, -1);
    littleBoxView.layer.shadowColor=[UIColor blackColor].CGColor;
    littleBoxView.layer.shadowOpacity = 1;
    littleBoxView.layer.shadowRadius=2;
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(10, 50, littleBoxView.frame.size.width-30, littleBoxView.frame.size.height/2)];
    label.numberOfLines=3;
    label.textAlignment=UITextAlignmentCenter;
    label.backgroundColor=[UIColor clearColor];
    label.textColor=[UIColor whiteColor];
    label.font=[UIFont fontWithName:@"Helvetica" size:15];
    label.text=@"Creado por Ekoomedia Ltda. ©2012 Ekoobot 3D.";
    label.layer.masksToBounds=YES;
    label.layer.shouldRasterize=YES;
    label.layer.shadowOffset=CGSizeMake(0, -1);
    label.layer.shadowColor=[UIColor blackColor].CGColor;
    label.layer.shadowOpacity = 1;
    label.layer.shadowRadius=0.5;
    [littleBoxView addSubview:label];
    [rotationSubView addSubview:littleBoxView];
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
    NSLog(@"Aca toy");
    NavController *navController = (NavController *)self.navigationController;
    [navController setOrientationType:2];
    [navController forceLandscapeMode];
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
-(void)stopSpinner{
    spinner.alpha=0;
    [spinner stopAnimating];
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
-(IBAction)littleBox:(id)sender{
    if (littleBoxView.alpha==0) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        littleBoxView.alpha=1;
        [UIView commitAnimations];
    }
    else{
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        littleBoxView.alpha=0;
        [UIView commitAnimations];
    }
    
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
        
        usuario.usuario=usuarioTF.text;
        usuarioCopia.usuario=usuarioTF.text;
        usuario.contrasena=passwordTF.text;
        usuarioCopia.contrasena=passwordTF.text;
        
        TermsViewController *tVC=[[TermsViewController alloc]init];
        tVC=[self.storyboard instantiateViewControllerWithIdentifier:@"Terms"];
        tVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        //tVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        tVC.modalPresentationStyle = UIModalPresentationFormSheet;
        tVC.usuario=usuario;
        tVC.usuarioCopia=usuarioCopia;
        tVC.VC=self;
        [self.navigationController presentModalViewController:tVC animated:YES];
        
        //[self irAlSiguienteViewConUsuario:usuario yCopia:usuarioCopia];
        
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

        usuario.usuario=usuarioTF.text;
        usuarioCopia.usuario=usuarioTF.text;
        usuario.contrasena=passwordTF.text;
        usuarioCopia.contrasena=passwordTF.text;
        [self irAlSiguienteViewConUsuario:usuario yCopia:usuarioCopia];
    }
}
@end