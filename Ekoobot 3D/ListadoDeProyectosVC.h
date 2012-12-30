//
//  SecondViewController.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 4/17/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Usuario.h"
#import "PlantaUrbanaVC.h"
#import "TiposDePisosVC.h"
#import "TiposDePlantasVC.h"
#import "ProjectDownloader.h"
#import "ProgressView.h"
#import "MBProgressHud.h"
#import <QuartzCore/QuartzCore.h>
#import "Producto.h"
#import "FileSaver.h"
#import "IAmCoder.h"
#import "UpdateView.h"
#import "VideoViewController.h"
#import "SendInfoButton.h"
#import "SendInfoViewController.h"
#import "Adjunto.h"
#import "ZoomViewController.h"
#import "NavAnimations.h"
#import "Analytic.h"
@interface ListadoDeProyectosVC : UIViewController <UIScrollViewDelegate,UIAlertViewDelegate,UIDocumentInteractionControllerDelegate> {
    UIScrollView *scrollView;
    Usuario *usuarioActual;
    ProgressView *progressView;
    NSMutableArray *arrayDeTitulos;
    MBProgressHUD *hud;
    Usuario *usuarioCopia;
    NSMutableArray *scrollArray;
    
    //parametros para el server, son necesarios ya que se borran del usuario original
    NSString *nombreDeUsuario;
    NSString *passwordUsuario;
}

@property(nonatomic,retain)Usuario *usuarioActual;
@property(nonatomic,retain)Usuario *usuarioCopia;

@property(nonatomic,retain)UIPageControl *pageCon;

@end