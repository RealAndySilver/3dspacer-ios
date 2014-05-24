//
//  Urbanization+AddOns.h
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Urbanization.h"

@interface Urbanization (AddOns)
-(UIImage *)urbanizationImage;
+(Urbanization *)urbanizationWithServerInfo:(NSDictionary *)dictionary
         inManagedObjectContext:(NSManagedObjectContext *)context;
@end
