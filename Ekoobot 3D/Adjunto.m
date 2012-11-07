//
//  Adjunto.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 19/10/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import "Adjunto.h"

@implementation Adjunto
@synthesize actualizado,imagen,nombre,tipo,ID,thumb;
- (id)init{
    if (self=[super init]) {
        ID = @"";
        nombre = @"";
        imagen = @"";
        actualizado = @"";
        tipo = @"";
        thumb=@"";
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary{
    actualizado = [dictionary objectForKey:@"actualizado"];
    nombre = [dictionary objectForKey:@"nombre"];
    ID = [dictionary objectForKey:@"id"];
    imagen = [dictionary objectForKey:@"archivo"];
    tipo = [dictionary objectForKey:@"tipo"];
    if ([[dictionary objectForKey:@"extra"]isKindOfClass:[NSString class]]) {
        thumb = [dictionary objectForKey:@"extra"];
        NSLog(@"Thumb is %@",thumb);
    }

    return self;
}
@end
