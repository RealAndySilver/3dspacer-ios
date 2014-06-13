//
//  Video+AddOns.h
//  Ekoobot 3D
//
//  Created by Developer on 12/06/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Video.h"

@interface Video (AddOns)
+(Video *)videoWithServerInfo:(NSDictionary *)dictionary
                   nManagedObjectContext:(NSManagedObjectContext *)context;
+(void)deleteVideosForProjectWithID:(NSString *)projectID
                    inManagedObjectContext:(NSManagedObjectContext *)context;
+(NSArray *)videosArrayForProjectWithID:(NSString *)projectID
                        inManagedObjectContext:(NSManagedObjectContext *)context;
+(NSArray *)videoPathsForVideosWithProjectID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context;

@end
