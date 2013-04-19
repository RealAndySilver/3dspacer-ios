//
//  Producto.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 6/22/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Planta.h"

@interface Producto : NSObject{
    NSString *coordenadaX;
    NSString *coordenadaY;
    NSString *tipo;
    NSString *idProducto;
    NSString *area;
    NSString *norte;
    NSString *nombre;
    NSMutableArray *arrayPlantas;
}

@property(nonatomic,retain)NSString *coordenadaX,*coordenadaY,*tipo,*idProducto,*area,*nombre,*norte;
@property(nonatomic,retain)NSMutableArray *arrayPlantas;
@property(nonatomic)BOOL existe;

-(id)initWithDictionary:(NSDictionary*)dictionary;
@end
