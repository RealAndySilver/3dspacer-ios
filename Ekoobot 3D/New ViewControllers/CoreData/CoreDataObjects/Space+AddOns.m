//
//  Space+AddOns.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Space+AddOns.h"

@implementation Space (AddOns)

-(UIImage *)thumbImage {
    return [UIImage imageWithData:self.thumbData];
}

+(Space *)spaceWithServerInfo:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Space *space = nil;
    
    NSString *spaceID = [NSString stringWithFormat:@"%d", [dictionary[@"id"] intValue]];
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
        space.urbanization = [NSString stringWithFormat:@"%d", [dictionary[@"urbanization"] intValue]];
        space.project = [NSString stringWithFormat:@"%d", [dictionary[@"project"] intValue]];
        space.name = dictionary[@"name"];
        if ([dictionary[@"x_coord"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"x_coord"] isEqualToString:@""]) {
                space.xCoord = @(0);
            }
        } else {
            space.xCoord = dictionary[@"x_coord"];
        }
        
        if ([dictionary[@"y_coord"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"y_coord"] isEqualToString:@""]) {
                space.yCoord = @(0);
            }
        } else {
            space.yCoord = dictionary[@"y_coord"];
        }
        
        if ([dictionary[@"x_limit"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"x_limit"] isEqualToString:@""]) {
                space.xLimit = @(0);
            }
        } else {
            space.xLimit = dictionary[@"x_limit"];
        }
        
        if ([dictionary[@"y_limiit"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"y_limiit"] isEqualToString:@""]) {
                space.yLimit = @(0);
            }
        } else {
            space.yLimit = dictionary[@"y_limiit"];
        }
        space.thumb = dictionary[@"thumb"];
        space.thumbData = [NSData dataWithContentsOfURL:[NSURL URLWithString:space.thumb]];
        space.common = dictionary[@"common"];
        space.enabled = dictionary[@"enabled"];
        space.lastUpdate = dictionary[@"last_update"];
        space.plant = [NSString stringWithFormat:@"%d", [dictionary[@"plant"] intValue]];
        
    } else {
        //The render did not exist on the database, so we have to create it
        NSLog(@"El espacio no existía, así que crearemos uno nuevo.");
        
        space = [NSEntityDescription insertNewObjectForEntityForName:@"Space" inManagedObjectContext:context];
        space.identifier = spaceID;
        space.urbanization = [NSString stringWithFormat:@"%d", [dictionary[@"urbanization"] intValue]];
        space.project = [NSString stringWithFormat:@"%d", [dictionary[@"project"] intValue]];
        space.name = dictionary[@"name"];
        
        if ([dictionary[@"x_coord"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"x_coord"] isEqualToString:@""]) {
                space.xCoord = @(0);
            }
        } else {
            space.xCoord = dictionary[@"x_coord"];
        }
        
        if ([dictionary[@"y_coord"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"y_coord"] isEqualToString:@""]) {
                space.yCoord = @(0);
            }
        } else {
            space.yCoord = dictionary[@"y_coord"];
        }
        
        if ([dictionary[@"x_limit"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"x_limit"] isEqualToString:@""]) {
                space.xLimit = @(0);
            }
        } else {
            space.xLimit = dictionary[@"x_limit"];
        }
        
        if ([dictionary[@"y_limiit"] isKindOfClass:[NSString class]]) {
            if ([dictionary[@"y_limiit"] isEqualToString:@""]) {
                space.yLimit = @(0);
            }
        } else {
            space.yLimit = dictionary[@"y_limiit"];
        }
        space.thumb = dictionary[@"thumb"];
        space.thumbData = [NSData dataWithContentsOfURL:[NSURL URLWithString:space.thumb]];
        space.common = dictionary[@"common"];
        space.enabled = dictionary[@"enabled"];
        space.lastUpdate = dictionary[@"last_update"];
        space.plant = [NSString stringWithFormat:@"%d", [dictionary[@"plant"] intValue]];
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
