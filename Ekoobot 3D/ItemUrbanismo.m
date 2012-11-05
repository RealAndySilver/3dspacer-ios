//
//  ItemUrbanismo.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 6/22/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import "ItemUrbanismo.h"

@implementation ItemUrbanismo

@synthesize tipo,coordenadaX,coordenadaY,idUrbanismo,imagenUrbanismo,existe;
@synthesize arrayGrupos;

- (id)init{
    if (self=[super init]) {
        idUrbanismo = @"";
        tipo = @"";
        coordenadaX = @"";
        coordenadaY = @"";
        imagenUrbanismo = @"";
        existe=NO;
        arrayGrupos =[[NSMutableArray alloc]init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary{
    idUrbanismo = [dictionary objectForKey:@"id_urbanizacion"];
    //tipo = [dictionary objectForKey:@"tipo"];
    //coordenadaX = [dictionary objectForKey:@"coordenadaX"];
    //coordenadaY = [dictionary objectForKey:@"coordenadaY"];
    imagenUrbanismo = [dictionary objectForKey:@"planta"];
    existe=[[dictionary objectForKey:@"existe"]boolValue];
    if ([[[dictionary objectForKey:@"grupos"]objectForKey:@"item"]isKindOfClass:[NSArray class]]) {
        NSArray *array=[[dictionary objectForKey:@"grupos"]objectForKey:@"item"];
        for (int i=0; i<[array count]; i++){
        Grupo *grupo=[[Grupo alloc]init];
        grupo=[grupo initWithDictionary:[[array objectAtIndex:i]objectForKey:@"grupo"]];
        [arrayGrupos addObject:grupo];
        }
    }
    else if ([[[dictionary objectForKey:@"grupos"]objectForKey:@"item"]isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dicClass=[[dictionary objectForKey:@"grupos"]objectForKey:@"item"];
        Grupo *grupo=[[Grupo alloc]init];
        grupo=[grupo initWithDictionary:[dicClass objectForKey:@"grupo"]];
        [arrayGrupos addObject:grupo];
    }

    /*for (int i=0; i<[array count]; i++) {
        Grupo *grupo=[[Grupo alloc]init];
        //grupo=[grupo initWithDictionary:[[array objectAtIndex:i]objectForKey:@"grupo"]];
        [arrayGrupos addObject:grupo];
    }*/

    return self;
}

@end