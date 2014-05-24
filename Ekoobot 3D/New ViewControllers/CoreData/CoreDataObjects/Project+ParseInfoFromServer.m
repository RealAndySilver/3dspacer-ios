//
//  Project+ParseInfoFromServer.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Project+ParseInfoFromServer.h"

@implementation Project (ParseInfoFromServer)

+(Project *)projectWithServerInfo:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Project *project = nil;
    
    NSString *projectID = [NSString stringWithFormat:@"%d", [dictionary[@"id"] intValue]];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", projectID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //Error
    } else if ([matches count]) {
        NSLog(@"El proyecto ya existía en la base de datos");
        project = [matches firstObject];
        
        if (![project.logoURL isEqualToString:dictionary[@"logo"]]) {
            project.logoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dictionary[@"logo"]]];
        }
        
        project.identifier = @([projectID intValue]);
        project.terms = dictionary[@"terms"];
        project.name = dictionary[@"name"];
        project.adress = dictionary[@"adress"];
        project.logoURL = dictionary[@"logo"];
        project.lastUpdate = dictionary[@"last_update"];
        project.enabled = dictionary[@"enabled"];
        
    } else {
        //The project did not exist on the database, so we have to create it
        NSLog(@"El proyecto no existía, así que crearemos uno nuevo.");
        
        project = [NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:context];
        project.identifier = @([projectID intValue]);
        project.terms = dictionary[@"terms"];
        project.name = dictionary[@"name"];
        project.adress = dictionary[@"adress"];
        project.logoURL = dictionary[@"logo"];
        project.lastUpdate = dictionary[@"last_update"];
        project.enabled = dictionary[@"enabled"];
        project.logoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:project.logoURL]];
    }
    return project;
}

@end
