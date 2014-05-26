//
//  Finish+AddOns.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 25/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Finish+AddOns.h"

@implementation Finish (AddOns)

-(UIImage *)finishIconImage {
    return [UIImage imageWithData:self.iconData];
}

+(Finish *)finishWithServerInfo:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Finish *finish = nil;
    
    NSString *finishID = dictionary[@"id"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Finish"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", finishID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //Error
    } else if ([matches count]) {
        NSLog(@"El acabado ya existía en la base de datos");
        finish = [matches firstObject];
        
        if (![finish.iconURL isEqualToString:dictionary[@"icon"]]) {
            finish.iconData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dictionary[@"icon"]]];
        }
        
        finish.project = dictionary[@"project"];
        finish.identifier = finishID;
        finish.name = dictionary[@"name"];
        finish.iconURL = dictionary[@"icon"];
        finish.order = dictionary[@"order"];
        finish.enabled = dictionary[@"enabled"];
        finish.lastUpdate = dictionary[@"lastUpdate"];
        finish.space = dictionary[@"space"];
        
    } else {
        //The render did not exist on the database, so we have to create it
        NSLog(@"EL acabado no existía, así que crearemos uno nuevo.");
        
        finish = [NSEntityDescription insertNewObjectForEntityForName:@"Finish" inManagedObjectContext:context];
        finish.project = dictionary[@"project"];
        finish.identifier = finishID;
        finish.name = dictionary[@"name"];
        finish.iconURL = dictionary[@"icon"];
        finish.order = dictionary[@"order"];
        finish.enabled = dictionary[@"enabled"];
        finish.lastUpdate = dictionary[@"lastUpdate"];
        finish.space = dictionary[@"space"];
        finish.iconData = [NSData dataWithContentsOfURL:[NSURL URLWithString:finish.iconURL]];
    }
    
    return finish;
}

@end
