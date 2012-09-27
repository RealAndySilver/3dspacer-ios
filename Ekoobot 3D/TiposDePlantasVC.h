//
//  TiposDePlantasVC.h
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 6/19/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Producto.h"
#import "CustomButton.h"
#import "Espacio3DVC.h"
#import "MBProgressHud.h"

@interface TiposDePlantasVC : UIViewController<UIScrollViewDelegate,UIAlertViewDelegate>{
    Producto *producto;
    UIScrollView *scrollView;
    IBOutlet UIActivityIndicatorView *spinner;
    MBProgressHUD *hud;
}

@property (nonatomic,retain)Producto *producto;
@property(nonatomic,retain)UIPageControl *pageCon;

@end
