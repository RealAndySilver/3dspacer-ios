//
//  Grupo.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 6/07/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "Grupo.h"

@implementation Grupo
@synthesize coordenadaY,coordenadaX,arrayTiposDePiso,idGrupo,existe,nombre;

- (id)init{
    if (self=[super init]) {
        coordenadaX = @"";
        coordenadaY = @"";
        nombre=@"";
        idGrupo=@"";
        existe=NO;
        arrayTiposDePiso =[[NSMutableArray alloc]init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary{
    coordenadaX = [dictionary objectForKey:@"x_coord"];
    coordenadaY = [dictionary objectForKey:@"y_coord"];
    nombre=[dictionary objectForKey:@"nombre"];
    idGrupo=[dictionary objectForKey:@"id_grupo"];
    existe=[[dictionary objectForKey:@"existe"]boolValue];
    /*for (int i=0; i<[[dictionary objectForKey:@"tiposPiso"]count]; i++) {
        NSString *key=[NSString stringWithFormat:@"%i",i];
        TipoDePiso *tipoDePiso=[[TipoDePiso alloc]init];
        tipoDePiso=[tipoDePiso initWithDictionary:[[dictionary objectForKey:@"tiposPiso"]objectForKey:key]];
        [arrayTiposDePiso addObject:tipoDePiso];   
    }*/
    if ([[[dictionary objectForKey:@"pisos_tipo"]objectForKey:@"item"]isKindOfClass:[NSArray class]]) {
        NSArray *array=[[dictionary objectForKey:@"pisos_tipo"]objectForKey:@"item"];
        for (int i=0; i<[array count]; i++){
            TipoDePiso *tipoDePiso=[[TipoDePiso alloc]init];
            tipoDePiso=[tipoDePiso initWithDictionary:[[array objectAtIndex:i]objectForKey:@"piso_tipo"]];
            [arrayTiposDePiso addObject:tipoDePiso];   
        }
    }
    else if ([[[dictionary objectForKey:@"pisos_tipo"]objectForKey:@"item"]isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dicClass=[[dictionary objectForKey:@"pisos_tipo"]objectForKey:@"item"];
        TipoDePiso *tipoDePiso=[[TipoDePiso alloc]init];
        tipoDePiso=[tipoDePiso initWithDictionary:[dicClass objectForKey:@"piso_tipo"]];
        [arrayTiposDePiso addObject:tipoDePiso];
    }
    return self;
}

@end
