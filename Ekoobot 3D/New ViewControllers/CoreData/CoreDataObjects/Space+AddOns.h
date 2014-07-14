//
//  Space+AddOns.h
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Space.h"

@interface Space (AddOns)
-(UIImage *)thumbImage;
+(Space *)spaceWithServerInfo:(NSDictionary *)dictionary
           inManagedObjectContext:(NSManagedObjectContext *)context;
+(NSArray *)spacesArrayForProjectWithID:(NSString *)projectID
                 inManagedObjectContext:(NSManagedObjectContext *)context;
+(void)deleteSpacesForProjectWithID:(NSString *)projectID
             inManagedObjectContext:(NSManagedObjectContext *)context;
+(NSArray *)imagesPathsForSpacesWithProjectID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context;
@end
