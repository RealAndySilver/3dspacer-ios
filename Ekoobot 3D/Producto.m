//
//  Producto.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 6/22/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import "Producto.h"

@implementation Producto

@synthesize coordenadaX,coordenadaY,arrayPlantas,tipo,idProducto,existe,area,nombre;
- (id)init{
    if (self=[super init]) {
        coordenadaX = @"";
        coordenadaY = @"";
        tipo = @"";
        idProducto = @"";
        area=@"";
        existe=NO;
        nombre=@"";
        arrayPlantas =[[NSMutableArray alloc]init];
    }
    return self;
}
-(id)initWithDictionary:(NSDictionary*)dictionary{
    coordenadaX = [dictionary objectForKey:@"x_coord"];
    coordenadaY = [dictionary objectForKey:@"y_coord"];
    tipo = [dictionary objectForKey:@"tipo"];
    area = [dictionary objectForKey:@"area"];
    idProducto = [dictionary objectForKey:@"id_producto"];
    nombre = [dictionary objectForKey:@"nombre"];
    //NSLog(@"Dic %@",dictionary);
    //existe=[[dictionary objectForKey:@"existe"]boolValue];
    //NSLog(@"existen? %d",existe);
    /*for (int i=0; i<[[dictionary objectForKey:@"plantas"]count]; i++) {
        NSString *key=[NSString stringWithFormat:@"%i",i];
        Planta *planta=[[Planta alloc]init];
        planta=[planta initWithDictionary:[[dictionary objectForKey:@"plantas"]objectForKey:key]];
        [arrayPlantas addObject:planta];   
    }*/
    if ([[[dictionary objectForKey:@"plantas"]objectForKey:@"item"]isKindOfClass:[NSArray class]]) {
        NSArray *array=[[dictionary objectForKey:@"plantas"]objectForKey:@"item"];
        for (int i=0; i<[array count]; i++){
            Planta *planta=[[Planta alloc]init];
            planta=[planta initWithDictionary:[[array objectAtIndex:i]objectForKey:@"planta"]];
            [arrayPlantas addObject:planta];
        }
    }
    else if ([[[dictionary objectForKey:@"plantas"]objectForKey:@"item"]isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dicClass=[[dictionary objectForKey:@"plantas"]objectForKey:@"item"];
        Planta *planta=[[Planta alloc]init];
        planta=[planta initWithDictionary:[dicClass objectForKey:@"planta"]];
        [arrayPlantas addObject:planta];
    }
    return self;
}
@end
