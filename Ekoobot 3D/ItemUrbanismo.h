//
//  ItemUrbanismo.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 6/22/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Grupo.h"

@interface ItemUrbanismo : NSObject{
    NSString *idUrbanismo;
    NSString *tipo;
    NSString *coordenadaX;
    NSString *coordenadaY;
    NSString *imagenUrbanismo;
    NSString *norte;
    NSMutableArray *arrayGrupos;
}

@property(nonatomic,retain)NSString *tipo,*coordenadaX,*coordenadaY,*idUrbanismo,*imagenUrbanismo,*norte;
@property(nonatomic,retain)NSMutableArray *arrayGrupos;
@property(nonatomic)BOOL existe;

- (id)initWithDictionary:(NSDictionary*)dictionary;

@end