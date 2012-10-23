//
//  SendInfoViewController.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 17/10/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerCommunicator.h"
#import "FileSaver.h"
#import "Usuario.h"
@interface SendInfoViewController : UIViewController{
    ServerCommunicator *server;
    IBOutlet UILabel *tituloProyectoLabel;
    IBOutlet UITextField *nombreTF;
    IBOutlet UITextField *emailTF;
    IBOutlet UITextView *comentarioTV;
    IBOutlet UIButton *sendBtn;
}
@property(nonatomic,retain)NSString *nombreProyecto,*usuario,*contrasena,*proyectoID;
@property(nonatomic,retain)Usuario *currentUser;
@end
