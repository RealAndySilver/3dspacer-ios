//
//  Planta.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 6/22/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Espacio3D.h"
@interface Planta : NSObject{
    NSString *idPlanta;
    NSString *imagenPlanta;
    NSString *norte;
    NSMutableArray *arrayEspacios3D;
}

@property(nonatomic,retain)NSString *imagenPlanta,*idPlanta,*nombre,*norte;
@property(nonatomic,retain)NSMutableArray *arrayEspacios3D;
@property(nonatomic)BOOL existe;

-(id)initWithDictionary:(NSDictionary*)dictionary;
@end
