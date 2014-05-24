//
//  Space+AddOns.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Space+AddOns.h"

@implementation Space (AddOns)

+(Space *)spaceWithServerInfo:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Space *space = nil;
    
    NSString *spaceID = dictionary[@"id"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Space"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", spaceID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //Error
    } else if ([matches count]) {
        NSLog(@"El espacio ya existía en la base de datos");
        space = [matches firstObject];
        space.identifier = spaceID;
        space.urbanization = dictionary[@"urbanization"];
        space.project = dictionary[@"project"];
        space.name = dictionary[@"name"];
        space.xCoord = dictionary[@"xCoord"];
        space.yCoord = dictionary[@"yCoord"];
        space.xLimit = dictionary[@"xLimit"];
        space.yLimit = dictionary[@"yLimit"];
        space.common = dictionary[@"common"];
        space.enabled = dictionary[@"enabled"];
        space.lastUpdate = dictionary[@"lastUpdate"];
        space.plant = dictionary[@"plant"];
        
    } else {
        //The render did not exist on the database, so we have to create it
        NSLog(@"El espacio no existía, así que crearemos uno nuevo.");
        
        space = [NSEntityDescription insertNewObjectForEntityForName:@"Space" inManagedObjectContext:context];
        space.identifier = spaceID;
        space.urbanization = dictionary[@"urbanization"];
        space.project = dictionary[@"project"];
        space.name = dictionary[@"name"];
        space.xCoord = dictionary[@"xCoord"];
        space.yCoord = dictionary[@"yCoord"];
        space.xLimit = dictionary[@"xLimit"];
        space.yLimit = dictionary[@"yLimit"];
        space.common = dictionary[@"common"];
        space.enabled = dictionary[@"enabled"];
        space.lastUpdate = dictionary[@"lastUpdate"];
        space.plant = dictionary[@"plant"];
    }
    
    return space;
}

@end
