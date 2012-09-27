//
//  TipoDePiso.h
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 6/22/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Producto.h"

@interface TipoDePiso : NSObject{
    NSString *imagen;
    NSString *coordenadaX,*coordenadaY;
    NSString *idTipoPiso;
    NSMutableArray *arrayProductos;
}

@property(nonatomic,retain)NSString *imagen;
@property(nonatomic,retain)NSString *coordenadaX,*coordenadaY,*idTipoPiso;
@property(nonatomic,retain)NSMutableArray *arrayProductos;
@property(nonatomic)BOOL existe;

-(id)initWithDictionary:(NSDictionary*)dictionary;

@end
