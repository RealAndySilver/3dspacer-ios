//
//  TipoDePiso.m
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 6/22/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "TipoDePiso.h"

@implementation TipoDePiso

@synthesize imagen,arrayProductos,coordenadaY,coordenadaX,idTipoPiso,existe,nombre;
- (id)init{
    if (self=[super init]) {
        imagen = @"";
        coordenadaX = @"";
        coordenadaY = @"";
        idTipoPiso = @"";
        existe=NO;
        nombre=@"";
        arrayProductos =[[NSMutableArray alloc]init];
    }
    return self;
}
-(id)initWithDictionary:(NSDictionary*)dictionary{
    imagen = [dictionary objectForKey:@"map"];
    coordenadaX = [dictionary objectForKey:@"x_coord"];
    coordenadaY = [dictionary objectForKey:@"y_coord"];
    idTipoPiso = [dictionary objectForKey:@"id_piso_tipo"];
    nombre = [dictionary objectForKey:@"nombre"];
    existe=[[dictionary objectForKey:@"existe"]boolValue];
    /*for (int i=0; i<[[dictionary objectForKey:@"productos"]count]; i++) {
        NSString *key=[NSString stringWithFormat:@"%i",i];
        Producto *producto=[[Producto alloc]init];
        producto=[producto initWithDictionary:[[dictionary objectForKey:@"productos"]objectForKey:key]];
        [arrayProductos addObject:producto];   
    }*/
    if ([[[dictionary objectForKey:@"productos"]objectForKey:@"item"]isKindOfClass:[NSArray class]]) {
        NSArray *array=[[dictionary objectForKey:@"productos"]objectForKey:@"item"];
        for (int i=0; i<[array count]; i++){
            Producto *producto=[[Producto alloc]init];
            producto=[producto initWithDictionary:[[array objectAtIndex:i]objectForKey:@"producto"]];
            [arrayProductos addObject:producto];   
        }
    }
    else if ([[[dictionary objectForKey:@"productos"]objectForKey:@"item"]isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dicClass=[[dictionary objectForKey:@"productos"]objectForKey:@"item"];
        Producto *producto=[[Producto alloc]init];
        producto=[producto initWithDictionary:[dicClass objectForKey:@"producto"]];
        [arrayProductos addObject:producto];   
    }
    return self;
}
@end
