//
//  Group+AddOns.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Group+AddOns.h"

@implementation Group (AddOns)

+(Group *)groupWithServerInfo:(NSDictionary *)dictionary
       inManagedObjectContext:(NSManagedObjectContext *)context {
    Group *group = nil;
    
    NSString *groupID = dictionary[@"id"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", groupID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //Error
    } else if ([matches count]) {
        NSLog(@"El grupo ya existía en la base de datos");
        group = [matches firstObject];
        group.identifier = groupID;
        group.name = dictionary[@"name"];
        
        if ([dictionary[@"xCoord"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"xCoord"] isEqualToString:@""]) {
                group.xCoord = @(0);
            }
        }
        else {
            group.xCoord = dictionary[@"xCoord"];
        }
        
        if ([dictionary[@"yCoord"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"yCoord"] isEqualToString:@""]) {
                group.yCoord = @(0);
            }
        }
        else {
            group.yCoord = dictionary[@"yCoord"];
        }
        
        group.startFloor = dictionary[@"startFloor"];
        group.enabled = dictionary[@"enabled"];
        group.lastUpdate = dictionary[@"lastUpdate"];
        group.urbanization = dictionary[@"urbanization"];
        group.project = dictionary[@"project"];
        
    } else {
        //The render did not exist on the database, so we have to create it
        NSLog(@"El grupo no existía, así que crearemos uno nuevo.");
        
        group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
        group.identifier = groupID;
        group.name = dictionary[@"name"];
        
        if ([dictionary[@"xCoord"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"xCoord"] isEqualToString:@""]) {
                group.xCoord = @(0);
            }
        }
        else {
            group.xCoord = dictionary[@"xCoord"];
        }
        
        if ([dictionary[@"yCoord"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"yCoord"] isEqualToString:@""]) {
                group.yCoord = @(0);
            }
        }
        else {
            group.yCoord = dictionary[@"yCoord"];
        }
        
        group.startFloor = dictionary[@"startFloor"];
        group.enabled = dictionary[@"enabled"];
        group.lastUpdate = dictionary[@"lastUpdate"];
        group.urbanization = dictionary[@"urbanization"];
        group.project = dictionary[@"project"];
    }
    return group;
}

+(NSArray *)groupsArrayForProjectWithID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
    request.predicate = [NSPredicate predicateWithFormat:@"project = %@", projectID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    NSLog(@"Número de grupos encontrados en la base de datos para el proyecto con id %@: %d", projectID, [matches count]);
    return matches;
}

+(void)deleteGroupsForProjectWithID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
    request.predicate = [NSPredicate predicateWithFormat:@"project = %@", projectID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    for (int i = 0; i < [matches count]; i++) {
        [context deleteObject:matches[i]];
        NSLog(@"Removiendo grupo del proyecto %@ en la posición %d", projectID, i);
    }
}

@end
