//
//  Plant+AddOns.h
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Plant.h"

@interface Plant (AddOns)
-(UIImage *)plantImage;
+(Plant *)plantWithServerInfo:(NSDictionary *)dictionary
           inManagedObjectContext:(NSManagedObjectContext *)context;
+(NSArray *)plantsArrayForProjectWithID:(NSString *)projectID
                 inManagedObjectContext:(NSManagedObjectContext *)context;
+(void)deletePlantsForProjectWithID:(NSString *)projectID
             inManagedObjectContext:(NSManagedObjectContext *)context;
+(NSArray *)imagesPathsForPlantsWithProjectID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context;
@end
