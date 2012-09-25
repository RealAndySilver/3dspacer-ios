//
//  PlantaUrbanaEspecificaVC.h
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 4/19/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TipoDePiso.h"
#import "Grupo.h"
#import "CustomButton.h"
#import "TiposDePlantasVC.h"
#import "MBProgressHud.h"

@interface TiposDePisosVC : UIViewController <UIScrollViewDelegate,UIAlertViewDelegate> {
    UIScrollView *scrollView;
    Grupo *grupo;
    MBProgressHUD *hud;
}

@property(nonatomic,retain)Grupo *grupo;
@property(nonatomic,retain)UIPageControl *pageCon;

@end