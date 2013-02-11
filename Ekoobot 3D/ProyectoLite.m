//
//  ProyectoLite.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 31/01/13.
//  Copyright (c) 2013 Ekoomedia. All rights reserved.
//

#import "ProyectoLite.h"

@implementation ProyectoLite
@synthesize actualizado,idProyecto;
-(id)initWithDictionary:(NSDictionary*)dic{
    if (self=[super init]) {
        actualizado=[dic objectForKey:@"actualizado"];
        idProyecto=[dic objectForKey:@"idProyecto"];
    }
    return self;
}
@end
