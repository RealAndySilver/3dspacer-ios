//
//  Caras.m
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 6/22/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "Caras.h"

@implementation Caras

@synthesize atras,frente,derecha,izquierda,arriba,abajo,idCaras;
@synthesize idAbajo,idArriba,idAtras,idDerecha,idFrente,idIzquierda;

-(id)init{
    if (self=[super init]) {
        idCaras = @"";
        atras = @"";
        frente = @"";
        derecha = @"";
        izquierda = @"";
        arriba = @"";
        abajo =@"";
    }
    return self;
}

-(id)initWithDictionary:(NSDictionary*)dictionary{

    if ([[dictionary objectForKey:@"item"]isKindOfClass:[NSArray class]]) {
        NSArray *array=[dictionary objectForKey:@"item"];
        for (int i=0; i<array.count; i++) {
            if ([[[array objectAtIndex:i]objectForKey:@"cara"] isEqualToString:@"front"]) {
                frente = [[array objectAtIndex:i]objectForKey:@"imagen"];
                idFrente = [[array objectAtIndex:i]objectForKey:@"id_imagen"];
                break;
            }
        }
        
        for (int i=0; i<array.count; i++) {
            if ([[[array objectAtIndex:i]objectForKey:@"cara"] isEqualToString:@"right"]) {
                derecha = [[array objectAtIndex:i]objectForKey:@"imagen"];
                idDerecha = [[array objectAtIndex:i]objectForKey:@"id_imagen"];

                break;
            }
        }
        for (int i=0; i<array.count; i++) {
            if ([[[array objectAtIndex:i]objectForKey:@"cara"] isEqualToString:@"back"]) {
                atras = [[array objectAtIndex:i]objectForKey:@"imagen"];
                idAtras = [[array objectAtIndex:i]objectForKey:@"id_imagen"];

                break;
            }
        }
        for (int i=0; i<array.count; i++) {
            if ([[[array objectAtIndex:i]objectForKey:@"cara"] isEqualToString:@"left"]) {
                izquierda = [[array objectAtIndex:i]objectForKey:@"imagen"];
                idIzquierda = [[array objectAtIndex:i]objectForKey:@"id_imagen"];

                break;
            }
        }
        for (int i=0; i<array.count; i++) {
            if ([[[array objectAtIndex:i]objectForKey:@"cara"] isEqualToString:@"top"]) {
                arriba = [[array objectAtIndex:i]objectForKey:@"imagen"];
                idArriba = [[array objectAtIndex:i]objectForKey:@"id_imagen"];
                break;
            }
        }
        for (int i=0; i<array.count; i++) {
            if ([[[array objectAtIndex:i]objectForKey:@"cara"] isEqualToString:@"down"]) {
                abajo = [[array objectAtIndex:i]objectForKey:@"imagen"];
                idAbajo = [[array objectAtIndex:i]objectForKey:@"id_imagen"];
                break;
            }
        }
    }
    return self;
}
@end