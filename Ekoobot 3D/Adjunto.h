//
//  Adjunto.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 19/10/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Adjunto : NSObject
@property(nonatomic,retain)NSString *actualizado;
@property(nonatomic,retain)NSString *imagen;
@property(nonatomic,retain)NSString *ID;
@property(nonatomic,retain)NSString *nombre;
@property(nonatomic,retain)NSString *tipo;

- (id)initWithDictionary:(NSDictionary*)dictionary;
@end
