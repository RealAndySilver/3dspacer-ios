//
//  Project+ParseInfoFromServer.h
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "Project.h"

@interface Project (ParseInfoFromServer)
+(Project *)projectWithServerInfo:(NSDictionary *)dictionary
           inManagedObjectContext:(NSManagedObjectContext *)context;
@end
