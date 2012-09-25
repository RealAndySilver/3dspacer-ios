//
//  FirstViewController.h
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 4/17/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Usuario.h"
#import "ComprobarUsuario.h"
#import "ListadoDeProyectosVC.h"
#import "ServerCommunicator.h"
#import "EraseViewController.h"
#import "FileSaver.h"


@interface RootViewController : UIViewController<UITextFieldDelegate> {
    IBOutlet UIView *loginViewContainer;
    IBOutlet UITextField *usuarioTF;
    IBOutlet UITextField *passwordTF;
    IBOutlet UIButton *loginButton;
    IBOutlet UILabel *ekoobot3dLabel;
    IBOutlet UIActivityIndicatorView *spinner;
    ServerCommunicator *sc;
    BOOL keyboardIsMoved;
    NSString *contrasenaString;
    NSString *usuarioString;
    
}

@end                        