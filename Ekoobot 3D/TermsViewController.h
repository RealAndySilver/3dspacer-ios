//
//  TermsViewController.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 17/10/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Usuario.h"
#import "RootViewController.h"
#import "MBProgressHud.h"
@class RootViewController;
@interface TermsViewController : UIViewController{
    RootViewController *rVC;
    MBProgressHUD *hud;
}
@property(nonatomic,retain)id VC;
@property(nonatomic,retain)Usuario *usuario;
@property(nonatomic,retain)Usuario *usuarioCopia;

@end
