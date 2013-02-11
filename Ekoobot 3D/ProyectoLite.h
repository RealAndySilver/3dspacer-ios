//
//  ProyectoLite.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 31/01/13.
//  Copyright (c) 2013 Ekoomedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProyectoLite : NSObject
@property(nonatomic,retain)NSString *actualizado;
@property(nonatomic,retain)NSString *idProyecto;;
-(id)initWithDictionary:(NSDictionary*)dic;
@end
