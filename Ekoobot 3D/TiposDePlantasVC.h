//
//  TiposDePlantasVC.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 6/19/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Producto.h"
#import "CustomButton.h"
#import "Espacio3DVC.h"
#import "MBProgressHud.h"
#import "BrujulaViewController.h"

@interface TiposDePlantasVC : UIViewController<UIScrollViewDelegate,UIAlertViewDelegate>{
    Producto *producto;
    UIScrollView *scrollView;
    IBOutlet UIActivityIndicatorView *spinner;
    MBProgressHUD *hud;
    NSMutableArray *arrayNombresPlantas;
    NSMutableArray *scrollArray;
    int scrollVar;
}

@property (nonatomic,retain)Producto *producto;
@property(nonatomic,retain)UIPageControl *pageCon;

@end
