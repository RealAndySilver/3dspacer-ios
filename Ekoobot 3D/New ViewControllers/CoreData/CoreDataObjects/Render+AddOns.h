//
//  Render+AddOns.h
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Render.h"

@interface Render (AddOns)
-(UIImage *)renderImage;
+(Render *)renderWithServerInfo:(NSDictionary *)dictionary
         inManagedObjectContext:(NSManagedObjectContext *)context;
+(NSMutableArray *)rendersForProjectWithID:(NSString *)projectID
                    inManagedObjectContext:(NSManagedObjectContext *)context;
+(void)deleteRendersForProjectWithID:(NSString *)projectID
              inManagedObjectContext:(NSManagedObjectContext *)context;
@end
