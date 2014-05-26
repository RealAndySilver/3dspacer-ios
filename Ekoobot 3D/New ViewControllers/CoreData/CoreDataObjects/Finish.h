//
//  Finish.h
//  Ekoobot 3D
//
//  Created by Diego Vidal on 25/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Finish : NSManagedObject

@property (nonatomic, retain) NSString * project;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * iconURL;
@property (nonatomic, retain) NSData * iconData;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) NSString * lastUpdate;
@property (nonatomic, retain) NSString * space;

@end
