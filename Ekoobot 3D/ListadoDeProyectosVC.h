//
//  SecondViewController.h
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 4/17/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
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
@interface ListadoDeProyectosVC : UIViewController <UIScrollViewDelegate,UIAlertViewDelegate> {
    UIScrollView *scrollView;
    Usuario *usuarioActual;
    ProgressView *progressView;
    NSMutableArray *arrayDeTitulos;
    MBProgressHUD *hud;
    Usuario *usuarioCopia;
}

@property(nonatomic,retain)Usuario *usuarioActual;
@property(nonatomic,retain)Usuario *usuarioCopia;

@property(nonatomic,retain)UIPageControl *pageCon;

@end