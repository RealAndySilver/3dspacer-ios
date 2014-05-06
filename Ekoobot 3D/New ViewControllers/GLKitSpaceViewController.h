//
//  GLKitSpaceViewController.h
//  Ekoobot 3D
//
//  Created by Developer on 5/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "Espacio3D.h"

@interface GLKitSpaceViewController : GLKViewController
//@property (strong, nonatomic) Espacio3D *espacio3D;
@property (strong, nonatomic) NSMutableArray *arregloDeEspacios3D;
@property (assign, nonatomic) NSUInteger espacioSeleccionado;
@end
