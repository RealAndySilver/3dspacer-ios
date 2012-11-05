//
//  SendInfoViewController.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 17/10/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerCommunicator.h"
#import "FileSaver.h"
#import "Usuario.h"
#import "NavController.h"
@interface SendInfoViewController : UIViewController<UIAlertViewDelegate,UITextFieldDelegate,UITextViewDelegate>{
    ServerCommunicator *server;
    IBOutlet UILabel *tituloProyectoLabel;
    IBOutlet UITextField *nombreTF;
    IBOutlet UITextField *emailTF;
    IBOutlet UITextView *comentarioTV;
    IBOutlet UIButton *sendBtn;
    IBOutlet UIButton *cancelButton;
    IBOutlet UIView *container;
    CGRect initialFrame;
    CGRect finalFrame;
    NSString *methodName;
    BOOL touchFlag;
}
@property(nonatomic,retain)NSString *nombreProyecto,*usuario,*contrasena,*proyectoID;
@property(nonatomic,retain)Usuario *currentUser;
@end
