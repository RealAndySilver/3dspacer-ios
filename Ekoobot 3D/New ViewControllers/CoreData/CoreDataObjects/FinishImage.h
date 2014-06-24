//
//  FinishImage.h
//  Ekoobot 3D
//
//  Created by Diego Vidal on 24/06/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FinishImage : NSManagedObject

@property (nonatomic, retain) NSString * finish;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * lastUpdate;
@property (nonatomic, retain) NSString * miniURL;
@property (nonatomic, retain) NSString * project;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSNumber * finalSize;

@end
