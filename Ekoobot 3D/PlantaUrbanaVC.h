//
//  PlantaUrbanaGeneralVC.h
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 4/19/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
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

@interface PlantaUrbanaVC : UIViewController<UIScrollViewDelegate> {
    Proyecto *proyecto;
    UIScrollView *scrollViewUrbanismo;
    UIImageView *imageViewUrbanismo;
    IBOutlet UIActivityIndicatorView *spinner;
    MBProgressHUD *hud;
    BOOL zoomCheck;
    float maximumZoomScale;
}
@property Proyecto *proyecto;

@end