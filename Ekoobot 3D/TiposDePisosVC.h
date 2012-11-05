//
//  PlantaUrbanaEspecificaVC.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 4/19/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
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
    NSMutableArray *arrayNombrePisos;
    int scrollVar;
    NSMutableArray *scrollArray;
}

@property(nonatomic,retain)Grupo *grupo;
@property(nonatomic,retain)UIPageControl *pageCon;

@end