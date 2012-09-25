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
                break;
            }
        }
        
        for (int i=0; i<array.count; i++) {
            if ([[[array objectAtIndex:i]objectForKey:@"cara"] isEqualToString:@"right"]) {
                derecha = [[array objectAtIndex:i]objectForKey:@"imagen"];
                break;
            }
        }
        for (int i=0; i<array.count; i++) {
            if ([[[array objectAtIndex:i]objectForKey:@"cara"] isEqualToString:@"back"]) {
                atras = [[array objectAtIndex:i]objectForKey:@"imagen"];
                break;
            }
        }
        for (int i=0; i<array.count; i++) {
            if ([[[array objectAtIndex:i]objectForKey:@"cara"] isEqualToString:@"left"]) {
                izquierda = [[array objectAtIndex:i]objectForKey:@"imagen"];
                break;
            }
        }
        for (int i=0; i<array.count; i++) {
            if ([[[array objectAtIndex:i]objectForKey:@"cara"] isEqualToString:@"top"]) {
                arriba = [[array objectAtIndex:i]objectForKey:@"imagen"];
                break;
            }
        }
        for (int i=0; i<array.count; i++) {
            if ([[[array objectAtIndex:i]objectForKey:@"cara"] isEqualToString:@"down"]) {
                abajo = [[array objectAtIndex:i]objectForKey:@"imagen"];
                break;
            }
        }
    }
    return self;
}
@end