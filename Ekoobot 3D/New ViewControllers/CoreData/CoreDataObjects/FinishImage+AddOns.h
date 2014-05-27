//
//  FinishImage+AddOns.h
//  Ekoobot 3D
//
//  Created by Diego Vidal on 25/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "FinishImage.h"

@interface FinishImage (AddOns)
-(UIImage *)finishImage;
+(FinishImage *)finishImageWithServerInfo:(NSDictionary *)dictionary
         inManagedObjectContext:(NSManagedObjectContext *)context;
+(NSArray *)finishesImagesArrayForProjectWithID:(NSString *)projectID
                         inManagedObjectContext:(NSManagedObjectContext *)context;
+(void)deleteFinishesImagesForProjectWithID:(NSString *)projectID
                     inManagedObjectContext:(NSManagedObjectContext *)context;
@end
