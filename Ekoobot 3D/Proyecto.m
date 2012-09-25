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
@synthesize urbanismo,imagenUrbanismo,edificio,arrayItemsUrbanismo,actualizado;

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
    return self;
}

@end
