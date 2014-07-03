//
//  Space.h
//  Ekoobot 3D
//
//  Created by Developer on 3/07/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Space : NSManagedObject

@property (nonatomic, retain) NSNumber * common;
@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * lastUpdate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * plant;
@property (nonatomic, retain) NSString * project;
@property (nonatomic, retain) NSString * urbanization;
@property (nonatomic, retain) NSNumber * xCoord;
@property (nonatomic, retain) NSNumber * xLimit;
@property (nonatomic, retain) NSNumber * yCoord;
@property (nonatomic, retain) NSNumber * yLimit;
@property (nonatomic, retain) NSString * thumb;
@property (nonatomic, retain) NSData * thumbData;

@end
