//
//  Espacio3D.m
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 6/22/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "Espacio3D.h"

@implementation Espacio3D

@synthesize nombre,coordenadaX,coordenadaY,arrayVariaciones,arrayCaras,idEspacio;
- (id)init{
    if (self=[super init]) {
        idEspacio=@"";
        nombre = @"";
        coordenadaX = @"";
        coordenadaY = @"";
        arrayCaras =[[NSMutableArray alloc]init];
    }
    return self;
}
-(id)initWithDictionary:(NSDictionary*)dictionary{
    idEspacio = [dictionary objectForKey:@"id_espacio"];
    nombre = [dictionary objectForKey:@"nombre"];
    coordenadaX = [dictionary objectForKey:@"x_coord"];
    coordenadaY = [dictionary objectForKey:@"y_coord"];
    //for (int i=0; i<[[dictionary objectForKey:@"caras"]count]; i++) {
      //  NSString *key=[NSString stringWithFormat:@"%i",i];
        Caras *caras=[[Caras alloc]init];
        caras=[caras initWithDictionary:[dictionary objectForKey:@"caras"]];
        [arrayCaras addObject:caras];  
    //}
    //NSLog(@"dicc espacio %@",[dictionary objectForKey:@"caras"]);
    return self;
}
@end
