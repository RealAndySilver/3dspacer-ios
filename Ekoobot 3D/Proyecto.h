//
//  Proyecto.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 4/17/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
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

@property(nonatomic,retain)NSString *idProyecto,*nombre,*logo,*imagen,*imagenUrbanismo,*peso;
@property(nonatomic,retain)NSString *actualizado;
@property(nonatomic,retain)NSString *urbanismo,*edificio;
@property(nonatomic,retain)NSString *data;

@property(nonatomic,retain)NSMutableArray *arrayItemsUrbanismo;
@property(nonatomic,retain)NSMutableArray *arrayAdjuntos;
- (id)initWithDictionary:(NSDictionary*)dictionary;

@end