//
//  Video+AddOns.m
//  Ekoobot 3D
//
//  Created by Developer on 12/06/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Video+AddOns.h"

@implementation Video (AddOns)

+(Video *)videoWithServerInfo:(NSDictionary *)dictionary nManagedObjectContext:(NSManagedObjectContext *)context {
    Video *video = nil;
    
    NSString *videoID = [NSString stringWithFormat:@"%d", [dictionary[@"id"] intValue]];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Video"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", videoID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        //Error
    } else if ([matches count]) {
        NSLog(@"El video ya existía en la base de datos");
        video = [matches firstObject];
        video.identifier = videoID;
        video.name = dictionary[@"name"];
        video.url = dictionary[@"url"];
        video.thumb = dictionary[@"thumb"];
        video.order = dictionary[@"order"];
        video.lastUpdate = dictionary[@"lastUpdate"];
        video.project = [NSString stringWithFormat:@"%d", [dictionary[@"project"] intValue]];
        video.videoPath = [NSString stringWithFormat:@"video_%@_%@.mp4", video.project, video.identifier];
        
    } else {
        //The render did not exist on the database, so we have to create it
        
        video = [NSEntityDescription insertNewObjectForEntityForName:@"Video" inManagedObjectContext:context];
        video.identifier = videoID;
        video.name = dictionary[@"name"];
        video.url = dictionary[@"url"];
        video.thumb = dictionary[@"thumb"];
        video.order = dictionary[@"order"];
        video.lastUpdate = dictionary[@"lastUpdate"];
        video.project = [NSString stringWithFormat:@"%d", [dictionary[@"project"] intValue]];
        video.videoPath = [NSString stringWithFormat:@"video_%@_%@.mp4", video.project, video.identifier];
        NSLog(@"El video no existía, así que crearemos uno nuevo con la url %@", video.url);
    }
    
    return video;
}

+(void)deleteVideosForProjectWithID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Video"];
    request.predicate = [NSPredicate predicateWithFormat:@"project = %@", projectID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    for (int i = 0;  i < [matches count]; i++) {
        [context deleteObject:matches[i]];
        NSLog(@"Removiendo video del proyecto %@ en la posición %d", projectID, i);
    }
}

+(NSArray *)videosArrayForProjectWithID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Video"];
    request.predicate = [NSPredicate predicateWithFormat:@"project = %@", projectID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    NSLog(@"Número de videos encontradas en la base de datos para el proyecto con id %@: %d", projectID, [matches count]);
    return matches;
}

+(NSArray *)videoPathsForVideosWithProjectID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *videoPaths = [[NSMutableArray alloc] init];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Video"];
    request.predicate = [NSPredicate predicateWithFormat:@"project = %@", projectID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    NSLog(@"Número de entidades video encontradas: %d", [matches count]);
    for (int i = 0; i < [matches count]; i++) {
        Video *video = matches[i];
        [videoPaths addObject:video.videoPath];
        NSLog(@"Agregando el video path %@", video.videoPath);
    }
    NSLog(@"Retornaré %d video paths", [videoPaths count]);
    return videoPaths;
}

@end
