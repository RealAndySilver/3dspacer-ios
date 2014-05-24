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
    
    NSString *urbanizationID = dictionary[@"id"];
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
        urbanization.imageWidth = dictionary[@"imageWidth"];
        urbanization.imageHeight = dictionary[@"imageHeight"];
        urbanization.northDegrees = dictionary[@"northDegs"];
        urbanization.enabled = dictionary[@"enabled"];
        urbanization.lastUpdate = dictionary[@"lastUpdate"];
        urbanization.project = dictionary[@"project"];
        
        
    } else {
        //The render did not exist on the database, so we have to create it
        NSLog(@"La urbanización no existía, así que crearemos uno nuevo.");
        
        urbanization = [NSEntityDescription insertNewObjectForEntityForName:@"Urbanization" inManagedObjectContext:context];
        urbanization.identifier = urbanizationID;
        urbanization.imageURL = dictionary[@"image"];
        urbanization.miniURL = dictionary[@"mini"];
        urbanization.imageWidth = dictionary[@"imageWidth"];
        urbanization.imageHeight = dictionary[@"imageHeight"];
        urbanization.northDegrees = dictionary[@"northDegs"];
        urbanization.enabled = dictionary[@"enabled"];
        urbanization.lastUpdate = dictionary[@"lastUpdate"];
        urbanization.project = dictionary[@"project"];
        urbanization.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urbanization.imageURL]];
    }
    return urbanization;
}

@end
