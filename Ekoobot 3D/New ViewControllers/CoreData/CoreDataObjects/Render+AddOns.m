//
//  Render+AddOns.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Render+AddOns.h"

@implementation Render (AddOns)

-(UIImage *)renderImage {
    return [UIImage imageWithData:self.mainImageData];
}

+(Render *)renderWithServerInfo:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Render *render = nil;
    
    NSString *renderID = dictionary[@"id"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Render"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", renderID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //Error
    } else if ([matches count]) {
        NSLog(@"El render ya existía en la base de datos");
        render = [matches firstObject];
        
        if (![render.mainURL isEqualToString:dictionary[@"url"]]) {
            render.mainImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dictionary[@"url"]]];
        }
        
        render.identifier = renderID;
        render.name = dictionary[@"name"];
        render.mainURL = dictionary[@"url"];
        render.miniURL = dictionary[@"mini"];
        render.thumbURL = dictionary[@"thumb"];
        render.order = dictionary[@"order"];
        render.lastUpdate = dictionary[@"lastUpdate"];
        render.project = dictionary[@"project"];
        
    } else {
        //The render did not exist on the database, so we have to create it
        NSLog(@"El render no existía, así que crearemos uno nuevo.");
        
        render = [NSEntityDescription insertNewObjectForEntityForName:@"Render" inManagedObjectContext:context];
        render.identifier = renderID;
        render.name = dictionary[@"name"];
        render.mainURL = dictionary[@"url"];
        render.miniURL = dictionary[@"mini"];
        render.thumbURL = dictionary[@"thumb"];
        render.order = dictionary[@"order"];
        render.lastUpdate = dictionary[@"lastUpdate"];
        render.project = dictionary[@"project"];
        render.mainImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:render.mainURL]];
    }
    return render;
}

@end
