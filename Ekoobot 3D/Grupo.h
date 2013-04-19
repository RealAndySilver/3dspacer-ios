//
//  Grupo.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 6/07/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TipoDePiso.h"

@interface Grupo : NSObject{
    NSString *coordenadaX;
    NSString *coordenadaY;
    NSString *nombre;
    NSString *norte;
    NSString *idGrupo;
    NSMutableArray *arrayTiposDePiso;
}
@property(nonatomic,retain)NSString *coordenadaX,*coordenadaY,*idGrupo,*nombre;
@property(nonatomic,retain)NSMutableArray *arrayTiposDePiso;
@property(nonatomic)BOOL existe;

- (id)initWithDictionary:(NSDictionary*)dictionary;
@end
