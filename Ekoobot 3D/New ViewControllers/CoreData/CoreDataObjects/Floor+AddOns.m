//
//  Floor+AddOns.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Floor+AddOns.h"

@implementation Floor (AddOns)

-(UIImage *)floorImage {
    return [UIImage imageWithData:self.imageData];
}

+(Floor *)floorWithServerInfo:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Floor *floor = nil;
    
    NSString *floorID = dictionary[@"id"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Floor"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", floorID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //Error
    } else if ([matches count]) {
        NSLog(@"El piso ya existía en la base de datos");
        floor = [matches firstObject];
        
        if (![floor.imageURL isEqualToString:dictionary[@"image"]]) {
            floor.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dictionary[@"image"]]];
        }
        
        floor.project = dictionary[@"project"];
        floor.identifier = floorID;
        floor.name = dictionary[@"name"];
        floor.imageURL = dictionary[@"image"];
        floor.miniURL = dictionary[@"mini"];
        floor.imageWidth = dictionary[@"imageWidth"];
        floor.imageHeight = dictionary[@"imageHeight"];
        floor.northDegrees = dictionary[@"northDegs"];
        floor.enabled = dictionary[@"enabled"];
        floor.order = dictionary[@"order"];
        floor.lastUpdate = dictionary[@"lastUpdate"];
        floor.group = dictionary[@"group"];
        
        
    } else {
        //The render did not exist on the database, so we have to create it
        NSLog(@"El piso no existía, así que crearemos uno nuevo.");
        
        floor = [NSEntityDescription insertNewObjectForEntityForName:@"Floor" inManagedObjectContext:context];
        floor.project = dictionary[@"project"];
        floor.identifier = floorID;
        floor.name = dictionary[@"name"];
        floor.imageURL = dictionary[@"image"];
        floor.miniURL = dictionary[@"mini"];
        floor.imageWidth = dictionary[@"imageWidth"];
        floor.imageHeight = dictionary[@"imageHeight"];
        floor.northDegrees = dictionary[@"northDegs"];
        floor.enabled = dictionary[@"enabled"];
        floor.order = dictionary[@"order"];
        floor.lastUpdate = dictionary[@"lastUpdate"];
        floor.group = dictionary[@"group"];
        floor.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:floor.imageURL]];
    }
    
    return floor;
}

+(NSArray *)floorsArrayForProjectWithID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Floor"];
    request.predicate = [NSPredicate predicateWithFormat:@"project = %@", projectID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    NSLog(@"Número de pisos encontrados en la base de datos para el proyecto con id %@: %d", projectID, [matches count]);
    return matches;
}

+(void)deleteFloorsForProjectWithID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Floor"];
    request.predicate = [NSPredicate predicateWithFormat:@"project = %@", projectID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    for (int i = 0; i < [matches count]; i++) {
        [context deleteObject:matches[i]];
        NSLog(@"Removiendo pisos del proyecto %@ en la posición %d", projectID, i);
    }
}

@end
