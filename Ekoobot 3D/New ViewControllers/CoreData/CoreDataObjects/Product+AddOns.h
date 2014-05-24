//
//  Product+AddOns.h
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Product.h"

@interface Product (AddOns)
+(Product *)productWithServerInfo:(NSDictionary *)dictionary
       inManagedObjectContext:(NSManagedObjectContext *)context;
@end
