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
    
    NSString *plantID = [NSString stringWithFormat:@"%d", [dictionary[@"id"] intValue]];
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
        
        plant.project = [NSString stringWithFormat:@"%d", [dictionary[@"project"] intValue]];
        plant.identifier = plantID;
        plant.name = dictionary[@"name"];
        plant.imageURL = dictionary[@"image"];
        plant.miniURL = dictionary[@"mini"];
        plant.imageWidth = dictionary[@"image_width"];
        plant.imageHeight = dictionary[@"image_height"];
        plant.northDegs = dictionary[@"north_degs"];
        plant.enabled = dictionary[@"enabled"];
        plant.order = dictionary[@"order"];
        plant.lastUpdate = dictionary[@"last_update"];
        plant.product = [NSString stringWithFormat:@"%d", [dictionary[@"product"] intValue]];
        
    } else {
        //The render did not exist on the database, so we have to create it
        NSLog(@"la planta no existía, así que crearemos uno nuevo.");
        
        plant = [NSEntityDescription insertNewObjectForEntityForName:@"Plant" inManagedObjectContext:context];
        plant.project = [NSString stringWithFormat:@"%d", [dictionary[@"project"] intValue]];
        plant.identifier = plantID;
        plant.name = dictionary[@"name"];
        plant.imageURL = dictionary[@"image"];
        plant.miniURL = dictionary[@"mini"];
        
        if ([dictionary[@"image_width"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"image_width"] isEqualToString:@""]) {
                plant.imageWidth = @(0);
            }
        } else {
            plant.imageWidth = dictionary[@"image_width"];
        }
        
        if ([dictionary[@"image_height"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"image_height"] isEqualToString:@""]) {
                plant.imageWidth = @(0);
            }
        } else {
            plant.imageHeight = dictionary[@"image_height"];
        }
        plant.northDegs = dictionary[@"north_degs"];
        plant.enabled = dictionary[@"enabled"];
        plant.order = dictionary[@"order"];
        plant.lastUpdate = dictionary[@"last_update"];
        plant.product = [NSString stringWithFormat:@"%d", [dictionary[@"product"] intValue]];
        plant.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:plant.imageURL]];
    }
    
    return plant;
}

+(NSArray *)plantsArrayForProjectWithID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Plant"];
    request.predicate = [NSPredicate predicateWithFormat:@"project = %@", projectID];
    request.sortDescriptors = @[sortDescriptor];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    NSLog(@"Número de plantas encontradas en la base de datos para el proyecto con id %@: %d", projectID, [matches count]);
    return matches;
}

+(void)deletePlantsForProjectWithID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Plant"];
    request.predicate = [NSPredicate predicateWithFormat:@"project = %@", projectID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    for (int i = 0; i < [matches count]; i++) {
        [context deleteObject:matches[i]];
        NSLog(@"Removiendo plantas del proyecto %@ en la posicion %d", projectID, i);
    }
}

@end
