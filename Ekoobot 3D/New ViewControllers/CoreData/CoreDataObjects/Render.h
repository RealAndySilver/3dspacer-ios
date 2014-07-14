//
//  Render.h
//  Ekoobot 3D
//
//  Created by Developer on 14/07/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Render : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * lastUpdate;
@property (nonatomic, retain) NSData * mainImageData;
@property (nonatomic, retain) NSString * mainURL;
@property (nonatomic, retain) NSString * miniURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * project;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * renderPath;

@end
