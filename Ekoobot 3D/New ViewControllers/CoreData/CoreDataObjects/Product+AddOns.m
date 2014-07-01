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
    
    NSString *productID = [NSString stringWithFormat:@"%d", [dictionary[@"id"] intValue]];
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
        product.project = [NSString stringWithFormat:@"%d", [dictionary[@"project"] intValue]];
        product.name = dictionary[@"name"];
        product.area = dictionary[@"area"];
        if ([dictionary[@"x_coord"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"x_coord"] isEqualToString:@""]) {
                product.xCoord = @(0);
            }
        }
         else {
            product.xCoord = dictionary[@"x_coord"];
        }
        
        if ([dictionary[@"y_coord"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"y_coord"] isEqualToString:@""]) {
                product.yCoord = @(0);
            }
        }
         else {
            product.yCoord = dictionary[@"y_coord"];
        }
        product.startPlant = [NSString stringWithFormat:@"%d", [dictionary[@"start_plant"] intValue]];
        product.enabled = dictionary[@"enabled"];
        product.lastUpdate = dictionary[@"last_update"];
        product.floor = [NSString stringWithFormat:@"%d", [dictionary[@"floor"] intValue]];
        
        
    } else {
        //The render did not exist on the database, so we have to create it
        NSLog(@"El producto no existía, así que crearemos uno nuevo.");
        
        product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:context];
        product.identifier = productID;
        product.project = [NSString stringWithFormat:@"%d", [dictionary[@"project"] intValue]];
        product.name = dictionary[@"name"];
        product.area = dictionary[@"area"];
        
        if ([dictionary[@"x_coord"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"x_coord"] isEqualToString:@""]) {
                product.xCoord = @(0);
            }
        }
        else {
            product.xCoord = dictionary[@"x_coord"];
        }
        
        if ([dictionary[@"y_coord"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"y_coord"] isEqualToString:@""]) {
                product.yCoord = @(0);
            }
        }
        else {
            product.yCoord = dictionary[@"y_coord"];
        }
        product.startPlant = [NSString stringWithFormat:@"%d", [dictionary[@"start_plant"] intValue]];
        product.enabled = dictionary[@"enabled"];
        product.lastUpdate = dictionary[@"last_update"];
        product.floor = [NSString stringWithFormat:@"%d", [dictionary[@"floor"] intValue]];
    }
    return product;
}

+(NSArray *)productsArrayForProjectWithID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Product"];
    request.predicate = [NSPredicate predicateWithFormat:@"project = %@", projectID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    NSLog(@"Número de productos encontrados en la base de datos para el proyecto con id %@: %d", projectID, [matches count]);
    return matches;
}

+(void)deleteProductsForProjectWithID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Product"];
    request.predicate = [NSPredicate predicateWithFormat:@"project = %@", projectID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    for (int i = 0; i < [matches count]; i++) {
        [context deleteObject:matches[i]];
        NSLog(@"Removiendo productos del proyecto %@ en la posicion %d", projectID, i);
    }
}

@end
