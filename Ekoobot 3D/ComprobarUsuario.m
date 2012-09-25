//
//  ComprobarUsuario.m
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 4/17/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "ComprobarUsuario.h"

@implementation ComprobarUsuario

- (NSDictionary*)convertirPListEnDiccionario{
    sc=[[ServerCommunicator alloc]init];
    sc.caller=self;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Datos" ofType:@"plist"];
    NSDictionary *resultado=[[NSDictionary alloc]initWithContentsOfFile:path];
    return resultado;
}

/*- (Usuario*)verificarUsuarioConNombre:(NSString *)nombre yContrasena:(NSString *)contrasena{
    NSDictionary *diccionarioInicial=[self convertirPListEnDiccionario];
    for (NSString *key in diccionarioInicial) {
        if ([nombre isEqualToString:[[diccionarioInicial objectForKey:key]objectForKey:@"usuario"]]) {
            if ([contrasena isEqualToString:[[diccionarioInicial objectForKey:key]objectForKey:@"contrasena"]]) {
                NSDictionary *diccionarioParaCliente=[diccionarioInicial objectForKey:key];
                Usuario *usuario=[[Usuario alloc]initWithDictionary:diccionarioParaCliente];
                return usuario;
            }
        }
    }
    NSLog(@"Error: Usuario y/o contrasena no coinciden");
    return nil;
}*/
- (Usuario*)verificarUsuarioConNombre:(NSString *)nombre yContrasena:(NSString *)contrasena{
    [sc callServerWithMethod:@"" andParameter:@""];

    return nil;
}
-(void)receivedDataFromServer:(id)sender{
    sc=sender;
    
}
@end