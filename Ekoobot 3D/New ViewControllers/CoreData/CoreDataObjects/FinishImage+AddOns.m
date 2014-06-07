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
        
        /*if (![finishImage.imageURL isEqualToString:dictionary[@"image"]]) {
            finishImage.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dictionary[@"image"]]];
        }*/
        
        finishImage.project = dictionary[@"project"];
        finishImage.identifier = finishImageID;
        finishImage.imageURL = dictionary[@"image"];
        finishImage.miniURL = dictionary[@"mini"];
        finishImage.type = dictionary[@"type"];
        if ([finishImage.type isEqualToString:@"bottom"]) {
            finishImage.type = @"down";
        }
        finishImage.lastUpdate = dictionary[@"lastUpdate"];
        finishImage.finish = dictionary[@"finish"];
        finishImage.imagePath = [NSString stringWithFormat:@"finishImage_%@_%@_%@.jpg", finishImage.project, finishImage.identifier, finishImage.type];
        
    } else {
        //The render did not exist on the database, so we have to create it
        NSLog(@"La imagen del acabado no existía, así que crearemos uno nuevo.");
        
        finishImage = [NSEntityDescription insertNewObjectForEntityForName:@"FinishImage" inManagedObjectContext:context];
        finishImage.project = dictionary[@"project"];
        finishImage.identifier = finishImageID;
        finishImage.imageURL = dictionary[@"image"];
        finishImage.miniURL = dictionary[@"mini"];
        finishImage.type = dictionary[@"type"];
        if ([finishImage.type isEqualToString:@"bottom"]) {
            finishImage.type = @"down";
        }
        finishImage.lastUpdate = dictionary[@"lastUpdate"];
        finishImage.finish = dictionary[@"finish"];
        finishImage.imagePath = [NSString stringWithFormat:@"finishImage_%@_%@_%@", finishImage.project, finishImage.identifier, finishImage.type];
        //finishImage.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:finishImage.imageURL]];
    }
    
    return finishImage;
}

+(NSArray *)finishesImagesArrayForProjectWithID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FinishImage"];
    request.predicate = [NSPredicate predicateWithFormat:@"project = %@", projectID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    NSLog(@"Número de imagenes de acabados encontradas para el proyecto con id %@: %d", projectID, [matches count]);
    return matches;
}

+(void)deleteFinishesImagesForProjectWithID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FinishImage"];
    request.predicate = [NSPredicate predicateWithFormat:@"project = %@", projectID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    for (int i = 0; i < [matches count]; i++) {
        [context deleteObject:matches[i]];
        NSLog(@"Removiendo imagen de acabado del proyecto %@ en la posicion %d",  projectID, i);
    }
}

@end
