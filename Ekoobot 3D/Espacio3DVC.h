//
//  Espacio3DVC.h
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 6/21/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"
#import "Usuario.h"
#import "Proyecto.h"
#import "Caras.h"
#import "Espacio3D.h"
#import "LoadingView.h"
#import <CoreLocation/CoreLocation.h>
#import "NavController.h"


@interface Espacio3DVC : UIViewController<CLLocationManagerDelegate,UIAlertViewDelegate>{
    OpenGLView *view3D;
    Espacio3D *espacio3D;
    NSMutableArray *arregloEspacial;
    LoadingView *loading;
    CGRect glFrame;
    UIView *lowerView;
    UILabel *tituloEspacio;
    BOOL flag;
    int pastTag;
    UIBarButtonItem *rightButton;
    BOOL threeD;
    NSMutableArray *arrayCaras;
    BOOL borderFlag;//para el cambio de color del borde de los thumbs
    int initialTag;
    UIScrollView *lowerScroll;
    UIView *compassPlaceholder;
    
}
@property (nonatomic,retain)Espacio3D *espacio3D;
@property (nonatomic,retain)NSMutableArray *arregloEspacial;
@property (nonatomic,strong)UIView *compassPlaceholder;



@end
