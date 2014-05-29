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
        if ([dictionary[@"xCoord"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"xCoord"] isEqualToString:@""]) {
                space.xCoord = @(0);
            }
        } else {
            space.xCoord = dictionary[@"xCoord"];
        }
        
        if ([dictionary[@"yCoord"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"yCoord"] isEqualToString:@""]) {
                space.yCoord = @(0);
            }
        } else {
            space.yCoord = dictionary[@"yCoord"];
        }
        
        if ([dictionary[@"xLimit"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"xLimit"] isEqualToString:@""]) {
                space.xLimit = @(0);
            }
        } else {
            space.xLimit = dictionary[@"xLimit"];
        }
        
        if ([dictionary[@"yLimit"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"yLimit"] isEqualToString:@""]) {
                space.yLimit = @(0);
            }
        } else {
            space.yLimit = dictionary[@"yLimit"];
        }
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
        
        if ([dictionary[@"xCoord"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"xCoord"] isEqualToString:@""]) {
                space.xCoord = @(0);
            }
        } else {
            space.xCoord = dictionary[@"xCoord"];
        }
        
        if ([dictionary[@"yCoord"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"yCoord"] isEqualToString:@""]) {
                space.yCoord = @(0);
            }
        } else {
            space.yCoord = dictionary[@"yCoord"];
        }
        
        if ([dictionary[@"xLimit"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"xLimit"] isEqualToString:@""]) {
                space.xLimit = @(0);
            }
        } else {
            space.xLimit = dictionary[@"xLimit"];
        }
        
        if ([dictionary[@"yLimit"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"yLimit"] isEqualToString:@""]) {
                space.yLimit = @(0);
            }
        } else {
            space.yLimit = dictionary[@"yLimit"];
        }
        space.common = dictionary[@"common"];
        space.enabled = dictionary[@"enabled"];
        space.lastUpdate = dictionary[@"lastUpdate"];
        space.plant = dictionary[@"plant"];
    }
    
    return space;
}

+(NSArray *)spacesArrayForProjectWithID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Space"];
    request.predicate = [NSPredicate predicateWithFormat:@"project = %@", projectID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    NSLog(@"Número de espacios encontrados en la base de datos para el proyecto con id %@: %d", projectID, [matches count]);
    return matches;
}

+(void)deleteSpacesForProjectWithID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Space"];
    request.predicate = [NSPredicate predicateWithFormat:@"project = %@", projectID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    for (int i = 0; i < [matches count]; i++) {
        [context deleteObject:matches[i]];
        NSLog(@"Removiendo espacios del proyecto %@ en la posicion %d", projectID, i);
    }
}

@end
