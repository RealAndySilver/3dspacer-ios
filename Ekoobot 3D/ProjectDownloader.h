//
//  ProjectDownloader.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 4/07/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Proyecto.h"
#import "FileSaver.h"
#import "Usuario.h"
#import "ServerCommunicator.h"


@interface ProjectDownloader : NSObject{

}
+(void)downloadProject:(Proyecto *)proyecto yTag:(int)tag sender:(id)sender usuario:(Usuario*)usuario;
+(void)eraseAllFiles;

@end
