//
//  Espacio3D.h
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 6/22/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Caras.h"

@interface Espacio3D : NSObject{
    NSString *idEspacio;
    NSString *nombre;
    NSString *coordenadaX;
    NSString *coordenadaY;
    NSMutableArray *arrayVariaciones;
    NSMutableArray *arrayCaras;

}

@property(nonatomic,retain)NSString *idEspacio,*nombre,*coordenadaX,*coordenadaY;
@property(nonatomic,retain)NSMutableArray *arrayVariaciones,*arrayCaras;
@property(nonatomic)BOOL existe;

-(id)initWithDictionary:(NSDictionary*)dictionary;
@end
