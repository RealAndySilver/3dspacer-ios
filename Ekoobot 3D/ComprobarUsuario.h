//
//  ComprobarUsuario.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 4/17/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Usuario.h"
#import "ServerCommunicator.h"

@interface ComprobarUsuario : NSObject{
    ServerCommunicator *sc;
}

- (Usuario*)verificarUsuarioConNombre:(NSString *)nombre yContrasena:(NSString *)contrasena;

@end