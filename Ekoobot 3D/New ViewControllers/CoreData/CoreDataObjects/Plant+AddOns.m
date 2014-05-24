//
//  Plant+AddOns.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Plant+AddOns.h"

@implementation Plant (AddOns)

-(UIImage *)plantImage {
    return [UIImage imageWithData:self.imageData];
}

+(Plant *)plantWithServerInfo:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Plant *plant = nil;
    
    NSString *plantID = dictionary[@"id"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Plant"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", plantID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //Error
    } else if ([matches count]) {
        NSLog(@"la planta ya existía en la base de datos");
        plant = [matches firstObject];
        
        if (![plant.imageURL isEqualToString:dictionary[@"image"]]) {
            plant.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dictionary[@"image"]]];
        }
        
        plant.project = dictionary[@"project"];
        plant.identifier = plantID;
        plant.name = dictionary[@"name"];
        plant.imageURL = dictionary[@"image"];
        plant.miniURL = dictionary[@"mini"];
        plant.imageWidth = dictionary[@"imageWidth"];
        plant.imageHeight = dictionary[@"imageHeight"];
        plant.northDegs = dictionary[@"northDegs"];
        plant.enabled = dictionary[@"enabled"];
        plant.order = dictionary[@"order"];
        plant.lastUpdate = dictionary[@"lastUpdate"];
        plant.product = dictionary[@"product"];
        
    } else {
        //The render did not exist on the database, so we have to create it
        NSLog(@"la planta no existía, así que crearemos uno nuevo.");
        
        plant = [NSEntityDescription insertNewObjectForEntityForName:@"Plant" inManagedObjectContext:context];
        plant.project = dictionary[@"project"];
        plant.identifier = plantID;
        plant.name = dictionary[@"name"];
        plant.imageURL = dictionary[@"image"];
        plant.miniURL = dictionary[@"mini"];
        plant.imageWidth = dictionary[@"imageWidth"];
        plant.imageHeight = dictionary[@"imageHeight"];
        plant.northDegs = dictionary[@"northDegs"];
        plant.enabled = dictionary[@"enabled"];
        plant.order = dictionary[@"order"];
        plant.lastUpdate = dictionary[@"lastUpdate"];
        plant.product = dictionary[@"product"];
        plant.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:plant.imageURL]];
    }
    
    return plant;
}

@end
