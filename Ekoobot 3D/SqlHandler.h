//
//  SqlHandler.h
//  DroidSecure
//
//  Created by Andres Abril on 27/10/12.
//  Copyright (c) 2012 Andres Abril. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Analytic.h"
@interface SqlHandler : NSObject{
    sqlite3 *db;
    NSFileManager *fileMgr;
    NSString *homeDir;
}
- (NSMutableArray *)getPendingProjects;
-(void)InsertAnalytic:(Analytic*)analytic;
+ (void)createEditableCopyOfDatabaseIfNeeded;
-(void)deleteTable;
@end
