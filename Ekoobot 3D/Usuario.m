//
//  Usuario.m
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 4/17/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "Usuario.h"

@implementation Usuario

@synthesize idUsuario,nombre,usuario,contrasena,tipo,estado;
@synthesize arrayProyectos;

- (id)init{
    if (self=[super init]) {
        idUsuario=@"Ninguno";
        nombre=@"Ninguno";
        usuario=@"Ninguno";
        contrasena=@"Ninguno";
        tipo=@"Ninguno";
        estado=@"Ninguno";
        //arrayProyectos = [[NSMutableArray alloc]init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary{
    //NSLog(@"dictionary %@",dictionary);
    idUsuario=[dictionary objectForKey:@"id_usuario"];
    nombre=[dictionary objectForKey:@"nombre"];
    //usuario=[dictionary objectForKey:@"usuario"];
    //contrasena=[dictionary objectForKey:@"contrasena"];
    //tipo=[dictionary objectForKey:@"tipo"];
    //estado=[dictionary objectForKey:@"estado"];
    arrayProyectos = [[NSMutableArray alloc]init];
    /*for (int i=0; i<[array count]; i++) {
        //NSString *key=[NSString stringWithFormat:@"%i",i];
        Proyecto *proyecto=[[Proyecto alloc]init];
        proyecto = [proyecto initWithDictionary:[[array objectAtIndex:i]objectForKey:@"proyecto"]];
        [arrayProyectos addObject:proyecto];
    }*/
    if ([[[dictionary objectForKey:@"proyectos"]objectForKey:@"item"]isKindOfClass:[NSArray class]]) {
        NSArray *array=[[dictionary objectForKey:@"proyectos"]objectForKey:@"item"];
        for (int i=0; i<[array count]; i++){
            Proyecto *proyecto=[[Proyecto alloc]init];
            proyecto = [proyecto initWithDictionary:[[array objectAtIndex:i]objectForKey:@"proyecto"]];
            [arrayProyectos addObject:proyecto];
        }
    }
    else if ([[[dictionary objectForKey:@"proyectos"]objectForKey:@"item"]isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dicClass=[[dictionary objectForKey:@"proyectos"]objectForKey:@"item"];
        Proyecto *proyecto=[[Proyecto alloc]init];
        proyecto = [proyecto initWithDictionary:[dicClass objectForKey:@"proyecto"]];
        [arrayProyectos addObject:proyecto];
    }
    
    return self;
}

@end
