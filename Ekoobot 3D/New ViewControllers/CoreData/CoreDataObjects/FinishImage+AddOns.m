//
//  FinishImage+AddOns.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 25/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "FinishImage+AddOns.h"

@implementation FinishImage (AddOns)

-(UIImage *)finishImage {
    return [UIImage imageWithData:self.imageData];
}

+(FinishImage *)finishImageWithServerInfo:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    FinishImage *finishImage = nil;
    
    NSString *finishImageID = dictionary[@"id"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FinishImage"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", finishImageID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //Error
    } else if ([matches count]) {
        NSLog(@"La imagen del acabado ya existía en la base de datos");
        finishImage = [matches firstObject];
        
        if (![finishImage.imageURL isEqualToString:dictionary[@"image"]]) {
            finishImage.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dictionary[@"image"]]];
        }
        
        finishImage.project = dictionary[@"project"];
        finishImage.identifier = finishImageID;
        finishImage.imageURL = dictionary[@"image"];
        finishImage.miniURL = dictionary[@"mini"];
        finishImage.type = dictionary[@"type"];
        finishImage.lastUpdate = dictionary[@"lastUpdate"];
        finishImage.finish = dictionary[@"finish"];
        
    } else {
        //The render did not exist on the database, so we have to create it
        NSLog(@"La imagen del acabado no existía, así que crearemos uno nuevo.");
        
        finishImage = [NSEntityDescription insertNewObjectForEntityForName:@"FinishImage" inManagedObjectContext:context];
        finishImage.project = dictionary[@"project"];
        finishImage.identifier = finishImageID;
        finishImage.imageURL = dictionary[@"image"];
        finishImage.miniURL = dictionary[@"mini"];
        finishImage.type = dictionary[@"type"];
        finishImage.lastUpdate = dictionary[@"lastUpdate"];
        finishImage.finish = dictionary[@"finish"];
        finishImage.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:finishImage.imageURL]];
    }
    
    return finishImage;
}
@end
