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
    
    NSString *floorID = [NSString stringWithFormat:@"%d", [dictionary[@"id"] intValue]];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Floor"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", floorID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //Error
    } else if ([matches count]) {
        NSLog(@"El piso ya existía en la base de datos");
        floor = [matches firstObject];
        
        /*if (![floor.imageURL isEqualToString:dictionary[@"image"]]) {
            floor.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dictionary[@"image"]]];
        }*/
        
        floor.project = [NSString stringWithFormat:@"%d", [dictionary[@"project"] intValue]];
        floor.identifier = floorID;
        floor.name = dictionary[@"name"];
        floor.imageURL = dictionary[@"image"];
        floor.miniURL = dictionary[@"mini"];
        if ([dictionary[@"image_width"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"image_width"] isEqualToString:@""]) {
                floor.imageWidth = @(0);
            }
        } else {
            floor.imageWidth = dictionary[@"image_width"];
        }
        
        if ([dictionary[@"image_height"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"image_height"] isEqualToString:@""]) {
                floor.imageHeight = @(0);
            }
        } else {
            floor.imageHeight = dictionary[@"image_height"];
        }
        floor.northDegrees = dictionary[@"north_degs"];
        floor.enabled = dictionary[@"enabled"];
        floor.order = dictionary[@"order"];
        floor.lastUpdate = dictionary[@"last_update"];
        floor.group = [NSString stringWithFormat:@"%d", [dictionary[@"group"] intValue]];
        floor.imagePath = [NSString stringWithFormat:@"floor_%@_%@", floor.project, floor.identifier];
        
        
    } else {
        //The render did not exist on the database, so we have to create it
        NSLog(@"El piso no existía, así que crearemos uno nuevo.");
        
        floor = [NSEntityDescription insertNewObjectForEntityForName:@"Floor" inManagedObjectContext:context];
        floor.project = [NSString stringWithFormat:@"%d", [dictionary[@"project"] intValue]];
        floor.identifier = floorID;
        floor.name = dictionary[@"name"];
        floor.imageURL = dictionary[@"image"];
        floor.miniURL = dictionary[@"mini"];
        if ([dictionary[@"image_width"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"image_width"] isEqualToString:@""]) {
                floor.imageWidth = @(0);
            }
        } else {
            floor.imageWidth = dictionary[@"image_width"];
        }
        
        if ([dictionary[@"image_height"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"image_height"] isEqualToString:@""]) {
                floor.imageHeight = @(0);
            }
        } else {
            floor.imageHeight = dictionary[@"image_height"];
        }
        floor.northDegrees = dictionary[@"north_degs"];
        floor.enabled = dictionary[@"enabled"];
        floor.order = dictionary[@"order"];
        floor.lastUpdate = dictionary[@"last_update"];
        floor.group = [NSString stringWithFormat:@"%d", [dictionary[@"group"] intValue]];
        floor.imagePath = [NSString stringWithFormat:@"floor_%@_%@", floor.project, floor.identifier];
        //floor.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:floor.imageURL]];
    }
    
    return floor;
}

+(NSArray *)imagesPathsForFloorWithProjectID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *imagePaths = [[NSMutableArray alloc] init];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Floor"];
    request.predicate = [NSPredicate predicateWithFormat:@"project = %@", projectID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    for (int i = 0; i < [matches count]; i++) {
        Floor *floor = matches[i];
        [imagePaths addObject:floor.imagePath];
    }
    
    return imagePaths;
}

+(NSArray *)floorsArrayForProjectWithID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Floor"];
    request.predicate = [NSPredicate predicateWithFormat:@"project = %@", projectID];
    request.sortDescriptors = @[sortDescriptor];
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
