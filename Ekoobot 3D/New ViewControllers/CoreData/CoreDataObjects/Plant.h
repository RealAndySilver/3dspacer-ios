//
//  Plant.h
//  Ekoobot 3D
//
//  Created by Diego Vidal on 26/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Plant : NSManagedObject

@property (nonatomic, retain) NSString * enabled;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * imageHeight;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * imageWidth;
@property (nonatomic, retain) NSString * lastUpdate;
@property (nonatomic, retain) NSString * miniURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * northDegs;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * product;
@property (nonatomic, retain) NSString * project;

@end
