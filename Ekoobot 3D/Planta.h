//
//  Planta.h
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 6/22/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Espacio3D.h"
@interface Planta : NSObject{
    NSString *idPlanta;
    NSString *imagenPlanta;
    NSMutableArray *arrayEspacios3D;
}

@property(nonatomic,retain)NSString *imagenPlanta,*idPlanta;
@property(nonatomic,retain)NSMutableArray *arrayEspacios3D;
@property(nonatomic)BOOL existe;

-(id)initWithDictionary:(NSDictionary*)dictionary;
@end
