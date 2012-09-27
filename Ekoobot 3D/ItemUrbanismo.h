//
//  ItemUrbanismo.h
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 6/22/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Grupo.h"

@interface ItemUrbanismo : NSObject{
    NSString *idUrbanismo;
    NSString *tipo;
    NSString *coordenadaX;
    NSString *coordenadaY;
    NSString *imagenUrbanismo;
    NSMutableArray *arrayGrupos;
}

@property(nonatomic,retain)NSString *tipo,*coordenadaX,*coordenadaY,*idUrbanismo,*imagenUrbanismo;
@property(nonatomic,retain)NSMutableArray *arrayGrupos;
@property(nonatomic)BOOL existe;

- (id)initWithDictionary:(NSDictionary*)dictionary;

@end