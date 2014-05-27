//
//  Group+AddOns.h
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Group.h"

@interface Group (AddOns)
+(Group *)groupWithServerInfo:(NSDictionary *)dictionary
       inManagedObjectContext:(NSManagedObjectContext *)context;
+(NSArray *)groupsArrayForProjectWithID:(NSString *)projectID
                 inManagedObjectContext:(NSManagedObjectContext *)context;
+(void)deleteGroupsForProjectWithID:(NSString *)projectID
             inManagedObjectContext:(NSManagedObjectContext *)context;
@end
