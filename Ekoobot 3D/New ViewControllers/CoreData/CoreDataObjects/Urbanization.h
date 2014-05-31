//
//  Urbanization.h
//  Ekoobot 3D
//
//  Created by Diego Vidal on 26/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Urbanization : NSManagedObject

@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSNumber * imageHeight;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * imageWidth;
@property (nonatomic, retain) NSString * lastUpdate;
@property (nonatomic, retain) NSString * miniURL;
@property (nonatomic, retain) NSNumber * northDegrees;
@property (nonatomic, retain) NSString * project;

@end