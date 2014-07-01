//
//  Urbanization+AddOns.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Urbanization+AddOns.h"

@implementation Urbanization (AddOns)

-(UIImage *)urbanizationImage {
    return [UIImage imageWithData:self.imageData];
}

+(Urbanization *)urbanizationWithServerInfo:(NSDictionary *)dictionary
                     inManagedObjectContext:(NSManagedObjectContext *)context {
    Urbanization *urbanization = nil;
    
    NSString *urbanizationID = [NSString stringWithFormat:@"%d", [dictionary[@"id"] intValue]];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Urbanization"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", urbanizationID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //Error
    } else if ([matches count]) {
        NSLog(@"La urbanizacion ya existía en la base de datos");
        urbanization = [matches firstObject];
        
        if (![urbanization.imageURL isEqualToString:dictionary[@"image"]]) {
            urbanization.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dictionary[@"image"]]];
        }
        
        urbanization.identifier = urbanizationID;
        urbanization.imageURL = dictionary[@"image"];
        urbanization.miniURL = dictionary[@"mini"];
        
        if ([dictionary[@"image_width"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"image_width"] isEqualToString:@""]) {
                urbanization.imageWidth = @(0);
            }
        }
         else {
            urbanization.imageWidth = dictionary[@"image_width"];
        }
        
        if ([dictionary[@"image_height"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"image_height"] isEqualToString:@""]) {
                urbanization.imageHeight = @(0);
            }
        }
        else {
            urbanization.imageHeight = dictionary[@"image_height"];
        }
        urbanization.northDegrees = dictionary[@"north_degs"];
        urbanization.enabled = dictionary[@"enabled"];
        urbanization.lastUpdate = dictionary[@"last_update"];
        urbanization.project = [NSString stringWithFormat:@"%d", [dictionary[@"project"] intValue]];
        
        
    } else {
        //The render did not exist on the database, so we have to create it
        NSLog(@"La urbanización no existía, así que crearemos uno nuevo.");
        
        urbanization = [NSEntityDescription insertNewObjectForEntityForName:@"Urbanization" inManagedObjectContext:context];
        urbanization.identifier = urbanizationID;
        urbanization.imageURL = dictionary[@"image"];
        urbanization.miniURL = dictionary[@"mini"];
        if ([dictionary[@"image_width"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"image_width"] isEqualToString:@""]) {
                urbanization.imageWidth = @(0);
            }
        }
        else {
            urbanization.imageWidth = dictionary[@"image_width"];
        }
        
        if ([dictionary[@"image_height"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"image_height"] isEqualToString:@""]) {
                urbanization.imageHeight = @(0);
            }
        }
        else {
            urbanization.imageHeight = dictionary[@"image_height"];
        }
        urbanization.northDegrees = dictionary[@"north_degs"];
        urbanization.enabled = dictionary[@"enabled"];
        urbanization.lastUpdate = dictionary[@"last_update"];
        urbanization.project = [NSString stringWithFormat:@"%d", [dictionary[@"project"] intValue]];
        urbanization.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urbanization.imageURL]];
    }
    return urbanization;
}

+(NSArray *)urbanizationsArrayForProjectWithID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Urbanization"];
    request.predicate = [NSPredicate predicateWithFormat:@"project = %@", projectID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    NSLog(@"Número de urbanizaciones encontradas en la base de datos para el proyecto con id %@: %d", projectID, [matches count]);
    return matches;
}

+(void)deleteUrbanizationsForProjectWithID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Urbanization"];
    request.predicate = [NSPredicate predicateWithFormat:@"project = %@", projectID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    for (int i = 0;  i < [matches count]; i++) {
        [context deleteObject:matches[i]];
        NSLog(@"Removiendo urbanización del proyecto %@ en la posición %d", projectID, i);
    }
}

@end
