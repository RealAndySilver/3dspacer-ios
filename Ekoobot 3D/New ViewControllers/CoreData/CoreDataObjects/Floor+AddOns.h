//
//  Floor+AddOns.h
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Floor.h"

@interface Floor (AddOns)
-(UIImage *)floorImage;
+(Floor *)floorWithServerInfo:(NSDictionary *)dictionary
       inManagedObjectContext:(NSManagedObjectContext *)context;
+(NSArray *)floorsArrayForProjectWithID:(NSString *)projectID
                 inManagedObjectContext:(NSManagedObjectContext *)context;
+(void)deleteFloorsForProjectWithID:(NSString *)projectID
             inManagedObjectContext:(NSManagedObjectContext *)context;
+(NSArray *)imagesPathsForFloorWithProjectID:(NSString *)projectID inManagedObjectContext:(NSManagedObjectContext *)context;
@end
