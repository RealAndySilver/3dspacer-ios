//
//  PlantaUrbanaGeneralVC.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 4/19/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Espacio3DVC.h"
#import "Usuario.h"
#import "Proyecto.h"
#import "Producto.h"
#import "ItemUrbanismo.h"
#import "TipoDePiso.h"
#import "TiposDePisosVC.h"
#import "Producto.h"
#import "Planta.h"
#import "MBProgressHud.h"
#import "BrujulaView.h"

@interface PlantaUrbanaVC : UIViewController<UIScrollViewDelegate> {
    Proyecto *proyecto;
    UIImageView *imageViewUrbanismo;
    IBOutlet UIActivityIndicatorView *spinner;
    MBProgressHUD *hud;
    BOOL zoomCheck;
    float maximumZoomScale;
    float minimumZoomScale;
    CMAttitude *attitude;
    CMMotionManager *_motionManager;
    NSTimer *timer;
    BrujulaView *brujula;
    float diferenciaRotacion;
}
@property Proyecto *proyecto;
@property(nonatomic,retain)UIScrollView *scrollViewUrbanismo;

@end