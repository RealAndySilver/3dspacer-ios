//
//  Floor.h
//  Ekoobot 3D
//
//  Created by Developer on 14/07/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Floor : NSManagedObject

@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) NSString * group;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSNumber * imageHeight;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * imageWidth;
@property (nonatomic, retain) NSString * lastUpdate;
@property (nonatomic, retain) NSString * miniURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * northDegrees;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * project;
@property (nonatomic, retain) NSString * imagePath;

@end
