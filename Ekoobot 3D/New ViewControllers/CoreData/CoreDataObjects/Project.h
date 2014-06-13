//
//  Project.h
//  Ekoobot 3D
//
//  Created by Developer on 13/06/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Project : NSManagedObject

@property (nonatomic, retain) NSString * adress;
@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * lastUpdate;
@property (nonatomic, retain) NSData * logoData;
@property (nonatomic, retain) NSString * logoURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * terms;
@property (nonatomic, retain) NSNumber * enter;

@end
