//
//  Proyecto.m
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 4/17/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "Proyecto.h"

@implementation Proyecto

@synthesize idProyecto,nombre;
@synthesize logo,imagen;
@synthesize urbanismo,imagenUrbanismo,edificio,arrayItemsUrbanismo,actualizado,arrayAdjuntos;

- (id)init{
    if (self=[super init]) {
        idProyecto = @"";
        nombre = @"";
        logo = @"";
        imagen = @"";
        urbanismo = @"";
        edificio = @"";
        imagenUrbanismo = @"";
        actualizado=@"";
        arrayItemsUrbanismo = [[NSMutableArray alloc]init];
        arrayAdjuntos = [[NSMutableArray alloc]init];

    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary{
    idProyecto = [dictionary objectForKey:@"id_proyecto"];
    nombre = [dictionary objectForKey:@"nombre"];
    logo = [dictionary objectForKey:@"logo"];
    imagen = [dictionary objectForKey:@"imagen"];
    actualizado = [dictionary objectForKey:@"actualizado"];
    ItemUrbanismo *itemUrbanismo=[[ItemUrbanismo alloc]init];
    itemUrbanismo = [itemUrbanismo initWithDictionary:[dictionary objectForKey:@"planta_urbana"]];
    [arrayItemsUrbanismo addObject:itemUrbanismo];
    if ([[[dictionary objectForKey:@"adjuntos"]objectForKey:@"item"] isKindOfClass:[NSArray class]]) {
        NSArray *array=[[dictionary objectForKey:@"adjuntos"]objectForKey:@"item"];

        for (int i=0; i<[array count]; i++){
            Adjunto *adjunto=[[Adjunto alloc]init];
            adjunto=[adjunto initWithDictionary:[[array objectAtIndex:i]objectForKey:@"adjunto"]];
            [arrayAdjuntos addObject:adjunto];
        }
    }
    else if ([[[dictionary objectForKey:@"adjuntos"]objectForKey:@"item"]isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dicClass=[[dictionary objectForKey:@"adjuntos"]objectForKey:@"item"];
        Adjunto *adjunto=[[Adjunto alloc]init];
        adjunto=[adjunto initWithDictionary:[dicClass objectForKey:@"adjunto"]];
        [arrayAdjuntos addObject:adjunto];
    }
    
    return self;
}

@end
