//
//  Caras.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 6/22/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Caras : NSObject{
    NSString *idCaras;
    NSString *atras;
    NSString *frente;
    NSString *derecha;
    NSString *izquierda;
    NSString *arriba;
    NSString *abajo;
    
    
    
}

@property(nonatomic,retain)NSString *atras,*frente,*derecha,*izquierda,*arriba,*abajo,*idCaras,*nombreCara;
@property(nonatomic,retain)NSString *idAtras,*idFrente,*idDerecha,*idIzquierda,*idArriba,*idAbajo;

-(id)initWithDictionary:(NSDictionary*)dictionary;
@end
