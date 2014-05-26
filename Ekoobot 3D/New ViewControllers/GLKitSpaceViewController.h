//
//  GLKitSpaceViewController.h
//  Ekoobot 3D
//
//  Created by Developer on 5/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface GLKitSpaceViewController : GLKViewController
@property (strong, nonatomic) NSMutableArray *arregloDeEspacios3D;
@property (assign, nonatomic) NSUInteger espacioSeleccionado;
@property (strong, nonatomic) NSDictionary *projectDic;
@end
