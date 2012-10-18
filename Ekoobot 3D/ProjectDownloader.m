//
//  ProjectDownloader.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 4/07/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "ProjectDownloader.h"
float cuenta=0;
@implementation ProjectDownloader
/*+(void)downloadProject:(Proyecto *)proyecto yTag:(int)tag{
    //[self downloadImageWithURLString:proyecto.logo ID:proyecto.idProyecto andName:@"logo"];
    //[self downloadImageWithURLString:proyecto.imagen ID:proyecto.idProyecto andName:@"cover"];
    float contarInterno=[self contar:proyecto];
    int contadorError=0;
    NSMutableArray *itemsUrbanismoArray=proyecto.arrayItemsUrbanismo;
    for (int i=0; i<itemsUrbanismoArray.count; i++) {
        [self regresarCuentaConNumero:contarInterno];
        ItemUrbanismo *itemUrbanismo=[itemsUrbanismoArray objectAtIndex:i];
        if ([itemUrbanismo.imagenUrbanismo isKindOfClass:[NSString class]]) {
            if (itemUrbanismo.existe) {
                if (contadorError==0) {
                    contadorError+=[self downloadImageWithURLString:itemUrbanismo.imagenUrbanismo ID:itemUrbanismo.idUrbanismo andName:@"imagenUrbanismo"];
                }
                else{
                    [self llamarAlertaDeError];
                    return;
                }
                
            }
        }
        NSMutableArray *arrayGrupos=itemUrbanismo.arrayGrupos;
        for (int j=0; j<arrayGrupos.count; j++) {
            [self regresarCuentaConNumero:contarInterno];
            Grupo *grupo=[arrayGrupos objectAtIndex:j];
            NSMutableArray *arrayTiposDePiso = grupo.arrayTiposDePiso;
            for (int k=0; k<arrayTiposDePiso.count; k++) {
                [self regresarCuentaConNumero:contarInterno];
                TipoDePiso *tipoDePiso=[arrayTiposDePiso objectAtIndex:k];
                if ([tipoDePiso.imagen isKindOfClass:[NSString class]]) {
                    if (tipoDePiso.existe) {
                        if (contadorError==0) {
                            contadorError+=[self downloadImageWithURLString:tipoDePiso.imagen ID:tipoDePiso.idTipoPiso andName:@"tipoDePiso"];
                        }
                        else{
                            [self llamarAlertaDeError];
                            return;
                        }
                    }
                }
                NSMutableArray *productoArray=tipoDePiso.arrayProductos;
                for (int l=0; l<productoArray.count; l++) {
                    [self regresarCuentaConNumero:contarInterno];
                    Producto *producto=[productoArray objectAtIndex:l];
                    NSMutableArray *arrayPlantas=producto.arrayPlantas;
                    for (int m = 0; m<arrayPlantas.count; m++) {
                        [self regresarCuentaConNumero:contarInterno];
                        Planta *planta=[arrayPlantas objectAtIndex:m];
                        if ([planta.imagenPlanta isKindOfClass:[NSString class]]) {
                            if (planta.existe) {
                                if (contadorError==0){
                                    contadorError+=[self downloadImageWithURLString:planta.imagenPlanta ID:planta.idPlanta andName:@"planta"];
                                }
                                else{
                                    [self llamarAlertaDeError];
                                    return;
                                }
                            }
                        }
                        NSMutableArray *arrayEspacios3D=planta.arrayEspacios3D;
                        for (int n=0; n<arrayEspacios3D.count; n++) {
                            [self regresarCuentaConNumero:contarInterno];
                            Espacio3D *espacio3D=[arrayEspacios3D objectAtIndex:n];
                            NSMutableArray *arrayCaras=espacio3D.arrayCaras;
                            for (int o=0; o<arrayCaras.count; o++) {
                                Caras *caras=[arrayCaras objectAtIndex:o];
                                if (contadorError==0) {
                                    contadorError+=[self downloadImageWithURLString:caras.arriba ID:espacio3D.idEspacio andName:@"caraArriba"];
                                }
                                else{
                                    [self llamarAlertaDeError];
                                    return;
                                }
                                
                                [self regresarCuentaConNumero:contarInterno];
                                if (contadorError==0) {
                                    contadorError+=[self downloadImageWithURLString:caras.abajo ID:espacio3D.idEspacio andName:@"caraAbajo"];
                                }
                                else{
                                    [self llamarAlertaDeError];
                                    return;
                                }
                                
                                [self regresarCuentaConNumero:contarInterno];
                                
                                if (contadorError==0) {
                                    contadorError+=[self downloadImageWithURLString:caras.izquierda ID:espacio3D.idEspacio andName:@"caraIzquierda"];
                                }
                                else{
                                    [self llamarAlertaDeError];
                                    return;
                                }
                                
                                [self regresarCuentaConNumero:contarInterno];
                                
                                if (contadorError==0) {
                                    contadorError+=[self downloadImageWithURLString:caras.derecha ID:espacio3D.idEspacio andName:@"caraDerecha"];
                                }
                                else{
                                    [self llamarAlertaDeError];
                                    return;
                                }
                                
                                [self regresarCuentaConNumero:contarInterno];
                                
                                if (contadorError==0) {
                                    contadorError+=[self downloadImageWithURLString:caras.frente ID:espacio3D.idEspacio andName:@"caraFrente"];
                                }
                                else{
                                    [self llamarAlertaDeError];
                                    return;
                                }
                                
                                [self regresarCuentaConNumero:contarInterno];
                                if (contadorError==0) {
                                    contadorError+=[self downloadImageWithURLString:caras.atras ID:espacio3D.idEspacio andName:@"caraAtras"];
                                }
                                else{
                                    [self llamarAlertaDeError];
                                    return;
                                }
                                
                                [self regresarCuentaConNumero:contarInterno];
                            }
                        }
                    }
                }
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationStop" object:nil];
    NSLog(@"contador error %i",contadorError);
    if (contadorError==0) {
        FileSaver *file=[[FileSaver alloc]init];
        [file setUpdateFile:nil date:proyecto.actualizado andTag:tag];
        //[file setUpdateFile:nil date:proyecto.actualizado andTag:tag andId:proyecto.idProyecto];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updates" object:[NSNumber numberWithInt:tag]];
    }
    
}*/
+(void)downloadProject:(Proyecto *)proyecto yTag:(int)tag sender:(id)sender usuario:(Usuario*)usuario{
    //[self downloadImageWithURLString:proyecto.logo ID:proyecto.idProyecto andName:@"logo"];
    //[self downloadImageWithURLString:proyecto.imagen ID:proyecto.idProyecto andName:@"cover"];
    float contarInterno=[self contar:proyecto];
    int contadorError=0;
    NSMutableArray *itemsUrbanismoArray=proyecto.arrayItemsUrbanismo;
    for (int i=0; i<itemsUrbanismoArray.count; i++) {
        [self regresarCuentaConNumero:contarInterno sender:sender];
        ItemUrbanismo *itemUrbanismo=[itemsUrbanismoArray objectAtIndex:i];
        if ([itemUrbanismo.imagenUrbanismo isKindOfClass:[NSString class]]) {
            if (itemUrbanismo.existe) {
                if (contadorError==0) {
                    contadorError+=[self downloadImageWithURLString:itemUrbanismo.imagenUrbanismo ID:itemUrbanismo.idUrbanismo andName:@"imagenUrbanismo" usuario:usuario];
                }
                else{
                    [self llamarAlertaDeError];
                    return;
                }
                
            }
        }
        NSMutableArray *arrayGrupos=itemUrbanismo.arrayGrupos;
        for (int j=0; j<arrayGrupos.count; j++) {
            [self regresarCuentaConNumero:contarInterno];
            Grupo *grupo=[arrayGrupos objectAtIndex:j];
            NSMutableArray *arrayTiposDePiso = grupo.arrayTiposDePiso;
            for (int k=0; k<arrayTiposDePiso.count; k++) {
                [self regresarCuentaConNumero:contarInterno sender:sender];
                TipoDePiso *tipoDePiso=[arrayTiposDePiso objectAtIndex:k];
                if ([tipoDePiso.imagen isKindOfClass:[NSString class]]) {
                    if (tipoDePiso.existe) {
                        if (contadorError==0) {
                            contadorError+=[self downloadImageWithURLString:tipoDePiso.imagen ID:tipoDePiso.idTipoPiso andName:@"tipoDePiso" usuario:usuario];
                        }
                        else{
                            [self llamarAlertaDeError];
                            return;
                        }
                    }
                }
                NSMutableArray *productoArray=tipoDePiso.arrayProductos;
                for (int l=0; l<productoArray.count; l++) {
                    [self regresarCuentaConNumero:contarInterno sender:sender];
                    Producto *producto=[productoArray objectAtIndex:l];
                    NSMutableArray *arrayPlantas=producto.arrayPlantas;
                    for (int m = 0; m<arrayPlantas.count; m++) {
                        [self regresarCuentaConNumero:contarInterno sender:sender];
                        Planta *planta=[arrayPlantas objectAtIndex:m];
                        if ([planta.imagenPlanta isKindOfClass:[NSString class]]) {
                            //if (planta.existe) {
                            if (contadorError==0){
                                [self downloadImageWithURLString:planta.imagenPlanta ID:planta.idPlanta andName:@"planta" usuario:usuario];
                                //contadorError+=[self downloadImageWithURLString:planta.imagenPlanta ID:planta.idPlanta andName:@"planta"];
                                
                            }
                            else{
                                [self llamarAlertaDeError];
                                return;
                            }
                            //}
                        }
                        NSMutableArray *arrayEspacios3D=planta.arrayEspacios3D;
                        for (int n=0; n<arrayEspacios3D.count; n++) {
                            [self regresarCuentaConNumero:contarInterno sender:sender];
                            Espacio3D *espacio3D=[arrayEspacios3D objectAtIndex:n];
                            NSMutableArray *arrayCaras=espacio3D.arrayCaras;
                            //Pendiente de dejar todo dentro del siguiente if
                            if ([espacio3D.idEspacio isKindOfClass:[NSDictionary class]]) {
                                NSLog(@"Parce, este xsi es un array, no hay nada dentro");
                            }
                            for (int o=0; o<arrayCaras.count; o++) {
                                Caras *caras=[arrayCaras objectAtIndex:o];
                                if (contadorError==0) {
                                    contadorError+=[self downloadImageWithURLString:caras.arriba ID:caras.idArriba andName:@"caraArriba" usuario:usuario];
                                }
                                else{
                                    [self llamarAlertaDeError];
                                    return;
                                }
                                
                                [self regresarCuentaConNumero:contarInterno sender:sender];
                                if (contadorError==0) {
                                    contadorError+=[self downloadImageWithURLString:caras.abajo ID:caras.idAbajo andName:@"caraAbajo" usuario:usuario];
                                }
                                else{
                                    [self llamarAlertaDeError];
                                    return;
                                }
                                
                                [self regresarCuentaConNumero:contarInterno sender:sender];
                                
                                if (contadorError==0) {
                                    contadorError+=[self downloadImageWithURLString:caras.izquierda ID:caras.idIzquierda andName:@"caraIzquierda" usuario:usuario];
                                }
                                else{
                                    [self llamarAlertaDeError];
                                    return;
                                }
                                
                                [self regresarCuentaConNumero:contarInterno sender:sender];
                                
                                if (contadorError==0) {
                                    contadorError+=[self downloadImageWithURLString:caras.derecha ID:caras.idDerecha andName:@"caraDerecha" usuario:usuario];
                                }
                                else{
                                    [self llamarAlertaDeError];
                                    return;
                                }
                                
                                [self regresarCuentaConNumero:contarInterno sender:sender];
                                
                                if (contadorError==0) {
                                    contadorError+=[self downloadImageWithURLString:caras.frente ID:caras.idFrente andName:@"caraFrente" usuario:usuario];
                                }
                                else{
                                    [self llamarAlertaDeError];
                                    return;
                                }
                                
                                [self regresarCuentaConNumero:contarInterno sender:sender];
                                if (contadorError==0) {
                                    contadorError+=[self downloadImageWithURLString:caras.atras ID:caras.idAtras andName:@"caraAtras" usuario:usuario];
                                }
                                else{
                                    [self llamarAlertaDeError];
                                    return;
                                }
                                
                                [self regresarCuentaConNumero:contarInterno sender:sender];
                            }
                        }
                    }
                }
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationStop" object:nil];
    NSLog(@"contador error %i",contadorError);
    if (contadorError==0) {
        FileSaver *file=[[FileSaver alloc]init];
        //[file setUpdateFile:nil date:proyecto.actualizado andTag:tag];
        [file setUpdateFile:nil date:proyecto.actualizado andTag:tag andId:proyecto.idProyecto];
        NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
        [dictionary setObject:[NSNumber numberWithInt:tag] forKey:@"tag"];
        [dictionary setObject:proyecto.idProyecto forKey:@"id"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updates" object:dictionary];
    }
    
}
+(int)contar:(Proyecto*)proyecto{
    int w=0;
    NSMutableArray *itemsUrbanismoArray=proyecto.arrayItemsUrbanismo;
    for (int i=0; i<itemsUrbanismoArray.count; i++) {
        w+=1;
        ItemUrbanismo *itemUrbanismo=[itemsUrbanismoArray objectAtIndex:i];
        NSMutableArray *arrayGrupos=itemUrbanismo.arrayGrupos;
        for (int j=0; j<arrayGrupos.count; j++) {
            w+=1;
            Grupo *grupo=[arrayGrupos objectAtIndex:j];
            NSMutableArray *arrayTiposDePiso = grupo.arrayTiposDePiso;
            for (int k=0; k<arrayTiposDePiso.count; k++) {
                w+=1;
                TipoDePiso *tipoDePiso=[arrayTiposDePiso objectAtIndex:k];
                NSMutableArray *productoArray=tipoDePiso.arrayProductos;
                for (int l=0; l<productoArray.count; l++) {
                    w+=1;
                    Producto *producto=[productoArray objectAtIndex:l];
                    NSMutableArray *arrayPlantas=producto.arrayPlantas;
                    for (int m = 0; m<arrayPlantas.count; m++) {
                        w+=1;
                        Planta *planta=[arrayPlantas objectAtIndex:m];
                        NSMutableArray *arrayEspacios3D=planta.arrayEspacios3D;
                        for (int n=0; n<arrayEspacios3D.count; n++) {
                            w+=1;
                            Espacio3D *espacio3D=[arrayEspacios3D objectAtIndex:n];
                            NSMutableArray *arrayCaras=espacio3D.arrayCaras;
                            for (int o=0; o<arrayCaras.count; o++) {
                                w+=6;
                            }
                        }
                    }
                }
            }
        }
    }
    cuenta=0;
    return w;
}

//Método con notification center
+(float)regresarCuentaConNumero:(float)numero{
    cuenta+=1;
    float resultado=(cuenta/numero);
    NSString *intRes=[NSString stringWithFormat:@"%.2f",resultado];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLabel" object:intRes];
    NSLog(@"Porcentaje %@, %f, %f",intRes,cuenta,numero);
    return resultado;
}
//Método con respond to selector
+(float)regresarCuentaConNumero:(float)numero sender:(id)sender{
    cuenta+=1;
    float resultado=(cuenta/numero);
    NSString *intRes=[NSString stringWithFormat:@"%.2f",resultado];
    if ([sender respondsToSelector:@selector(setText:)]) {
        [sender performSelectorInBackground:@selector(setText:) withObject:intRes];
    }
    NSLog(@"Porcentaje %@, %f, %f",intRes,cuenta,numero);
    return resultado;
}
+(int)downloadImageWithURLString:(NSString*)imageUrl ID:(NSString*)ID andName:(NSString*)name usuario:(Usuario*)usuario{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/%@%@.jpeg",docDir,name,ID];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    NSLog(@"downloader file path : %@",jpegFilePath);
    if (!fileExists) {
        NSURL *urlImagen=[NSURL URLWithString:imageUrl];
        NSData *dataImagen=[NSData dataWithContentsOfURL:urlImagen];
        UIImage *imagen=[UIImage imageWithData:dataImagen];
        NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(imagen, 1.0f)];
        
        if (imagen) {
            
            [data2 writeToFile:jpegFilePath atomically:YES];
            //NSLog(@"Si hubo imagen");
            return 0;
        }
        
        else{
            //NSLog(@"NO hubo imagen, no se guardó %@ con ID %@",imageUrl,ID);
            ServerCommunicator *server=[[ServerCommunicator alloc]init];
            NSString *message=[NSString stringWithFormat:@"No se guardó %@ con ID %@",imageUrl,ID];
            NSString *parameters=[NSString stringWithFormat:@"<ns:setEventLog><username>%@</username><password>%@</password><message>%@</message></ns:setEventLog>",usuario.usuario,usuario.contrasena,message];
            [server callServerWithMethod:@"" andParameter:parameters];
            return 1;
        }
    }
    else{
        return 0;
    }
}
+(void)eraseAllFiles{
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] error:&error];
    if (error == nil) {
        for (NSString *path in directoryContents) {
            NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:path];
            BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
            if (!removeSuccess) {
            }
        }
    } else {
    }
}
+(void)llamarAlertaDeError{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"alert" object:nil];
}
@end
