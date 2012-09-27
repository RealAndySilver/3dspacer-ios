//
//  Planta.m
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 6/22/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "Planta.h"

@implementation Planta

@synthesize imagenPlanta,idPlanta;
@synthesize arrayEspacios3D;
- (id)init{
    if (self=[super init]) {
        idPlanta=@"";
        imagenPlanta = @"";
        arrayEspacios3D =[[NSMutableArray alloc]init];
    }
    return self;
}
-(id)initWithDictionary:(NSDictionary*)dictionary{
    idPlanta = [dictionary objectForKey:@"id_planta"];
    imagenPlanta = [dictionary objectForKey:@"map"];
    /*for (int i=0; i<[[dictionary objectForKey:@"espacios3D"]count]; i++) {
        NSString *key=[NSString stringWithFormat:@"%i",i];
        Espacio3D *espacio3D=[[Espacio3D alloc]init];
        espacio3D=[espacio3D initWithDictionary:[[dictionary objectForKey:@"espacios3D"]objectForKey:key]];
        [arrayEspacios3D addObject:espacio3D];   
    }*/
    if ([[[dictionary objectForKey:@"espacios"]objectForKey:@"item"]isKindOfClass:[NSArray class]]) {
        NSArray *array=[[dictionary objectForKey:@"espacios"]objectForKey:@"item"];
        for (int i=0; i<[array count]; i++){
            Espacio3D *espacio3D=[[Espacio3D alloc]init];
            espacio3D=[espacio3D initWithDictionary:[[array objectAtIndex:i]objectForKey:@"espacio"]];
            [arrayEspacios3D addObject:espacio3D];

        }
    }
    else if ([[[dictionary objectForKey:@"espacios"]objectForKey:@"item"]isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dicClass=[[dictionary objectForKey:@"espacios"]objectForKey:@"item"];
        Espacio3D *espacio3D=[[Espacio3D alloc]init];
        espacio3D=[espacio3D initWithDictionary:[dicClass objectForKey:@"espacio"]];
        [arrayEspacios3D addObject:espacio3D];
    }
    return self;
}
@end
