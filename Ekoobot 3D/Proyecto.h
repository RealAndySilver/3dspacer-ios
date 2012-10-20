//
//  Proyecto.h
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 4/17/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemUrbanismo.h"
#import "Adjunto.h"

@interface Proyecto : NSObject{
    NSString *idProyecto;
    NSString *nombre;
    NSString *logo;
    NSString *imagen;
    NSString *urbanismo;
    NSString *edificio;
    NSString *imagenUrbanismo;
    NSMutableArray *arrayItemsUrbanismo;
}

@property(nonatomic,retain)NSString *idProyecto,*nombre,*logo,*imagen,*imagenUrbanismo;
@property(nonatomic,retain)NSString *actualizado;
@property(nonatomic,retain)NSString *urbanismo,*edificio;
@property(nonatomic,retain)NSMutableArray *arrayItemsUrbanismo;
@property(nonatomic,retain)NSMutableArray *arrayAdjuntos;
- (id)initWithDictionary:(NSDictionary*)dictionary;

@end