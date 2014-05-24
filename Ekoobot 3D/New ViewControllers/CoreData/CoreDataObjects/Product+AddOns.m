//
//  Product+AddOns.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Product+AddOns.h"

@implementation Product (AddOns)

+(Product *)productWithServerInfo:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Product *product = nil;
    
    NSString *productID = dictionary[@"id"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Product"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", productID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //Error
    } else if ([matches count]) {
        NSLog(@"El producto ya existía en la base de datos");
        product = [matches firstObject];
        product.identifier = productID;
        product.project = dictionary[@"project"];
        product.name = dictionary[@"name"];
        product.area = dictionary[@"area"];
        product.xCoord = dictionary[@"xCoord"];
        product.yCoord = dictionary[@"yCoord"];
        product.startPlant = dictionary[@"startPlant"];
        product.enabled = dictionary[@"enabled"];
        product.lastUpdate = dictionary[@"lastUpdate"];
        product.floor = dictionary[@"floor"];
        
        
    } else {
        //The render did not exist on the database, so we have to create it
        NSLog(@"El producto no existía, así que crearemos uno nuevo.");
        
        product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:context];
        product.identifier = productID;
        product.project = dictionary[@"project"];
        product.name = dictionary[@"name"];
        product.area = dictionary[@"area"];
        product.xCoord = dictionary[@"xCoord"];
        product.yCoord = dictionary[@"yCoord"];
        product.startPlant = dictionary[@"startPlant"];
        product.enabled = dictionary[@"enabled"];
        product.lastUpdate = dictionary[@"lastUpdate"];
        product.floor = dictionary[@"floor"];
    }
    return product;
}

@end
