//
//  Finish+AddOns.h
//  Ekoobot 3D
//
//  Created by Diego Vidal on 25/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Finish.h"

@interface Finish (AddOns)
-(UIImage *)finishIconImage;
+(Finish *)finishWithServerInfo:(NSDictionary *)dictionary
       inManagedObjectContext:(NSManagedObjectContext *)context;
+(NSArray *)finishesArrayForProjectWithID:(NSString* )projectID
                   inManagedOBjectContext:(NSManagedObjectContext *)context;
+(void)deleteFinishesForProjectWithID:(NSString *)projectID
               inManagedObjectContext:(NSManagedObjectContext *)context;
@end
