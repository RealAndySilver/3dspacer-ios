//
//  Video.h
//  Ekoobot 3D
//
//  Created by Developer on 12/06/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Video : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * thumb;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * lastUpdate;
@property (nonatomic, retain) NSString * project;
@property (nonatomic, retain) NSString * videoPath;

@end
