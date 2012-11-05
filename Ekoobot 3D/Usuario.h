//
//  Usuario.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 4/17/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Proyecto.h"

@interface Usuario : NSObject{
    NSString *idUsuario;
    NSString *nombre;
    NSString *usuario;
    NSString *contrasena;
    NSString *tipo;
    NSString *estado;
    NSMutableArray *arrayProyectos;
}

@property(nonatomic,retain)NSString *idUsuario,*nombre,*usuario,*contrasena,*tipo,*estado,*terminos;
@property(nonatomic,retain)NSMutableArray *arrayProyectos;

- (id)initWithDictionary:(NSDictionary*)dictionary;

@end