//
//  SqlHandler.m
//
//  Created by Andres Abril on 27/10/12.
//  Copyright (c) 2012 Andres Abril. All rights reserved.
//

#import "SqlHandler.h"
#define SQLITEPATH @"analytics.sqlite"
@implementation SqlHandler
- (NSMutableArray *)getPendingProjects{
    NSMutableArray *analyticsArray = [[NSMutableArray alloc] init];
    @try {
        fileMgr = [NSFileManager defaultManager];
        NSString *dbPath = [self databaseLocation];
        BOOL success = [fileMgr fileExistsAtPath:dbPath];
        if(!success){
            NSLog(@"Cannot locate database file '%@'.", dbPath);
            return nil;
        }
        if((sqlite3_open([dbPath UTF8String], &db) != SQLITE_OK)){
            NSLog(@"An error has occured.");
        }
        NSString* sql =@"SELECT projectId,month,day,hour,username,userId,token,minute,seconds,amPm,year FROM project";
        sqlite3_stmt *sqlStatement;
        if(sqlite3_prepare_v2(db, [sql UTF8String], -1, &sqlStatement, NULL) != SQLITE_OK)
        {
            NSLog(@"Problem with prepare statement %s",sqlite3_errmsg(db));
        }
        while (sqlite3_step(sqlStatement)==SQLITE_ROW) {
            Analytic *analytic = [[Analytic alloc]init];
            analytic.projectId = [NSString stringWithUTF8String:(char *) sqlite3_column_text(sqlStatement,0)];
            analytic.month = [NSString stringWithUTF8String:(char *) sqlite3_column_text(sqlStatement,1)];
            analytic.day = [NSString stringWithUTF8String:(char *) sqlite3_column_text(sqlStatement, 2)];
            analytic.hour = [NSString stringWithUTF8String:(char *) sqlite3_column_text(sqlStatement, 3)];
            analytic.username = [NSString stringWithUTF8String:(char *) sqlite3_column_text(sqlStatement, 4)];
            analytic.userId = [NSString stringWithUTF8String:(char *) sqlite3_column_text(sqlStatement, 5)];
            analytic.token = [NSString stringWithUTF8String:(char *) sqlite3_column_text(sqlStatement, 6)];
            analytic.minute = [NSString stringWithUTF8String:(char *) sqlite3_column_text(sqlStatement, 7)];
            analytic.seconds = [NSString stringWithUTF8String:(char *) sqlite3_column_text(sqlStatement, 8)];
            analytic.amPm = [NSString stringWithUTF8String:(char *) sqlite3_column_text(sqlStatement, 9)];
            analytic.year = [NSString stringWithUTF8String:(char *) sqlite3_column_text(sqlStatement, 10)];


            NSLog(@"projectid: %@ \nyear: %@\nmonth: %@ \nday: %@ \nhour: %@ \nminutes: %@\nseconds: %@\namPm: %@\nusername: %@ \nuserId: %@ \ntoken: %@",analytic.year,analytic.projectId,analytic.month,analytic.day,analytic.hour,analytic.minute,analytic.seconds,analytic.amPm,analytic.username,analytic.userId,analytic.token);
            [analyticsArray addObject:analytic];
        }
        sqlite3_finalize(sqlStatement);
        sqlite3_close(db);
    }
    @catch (NSException *exception) {
        NSLog(@"An exception occured: %@", [exception reason]);
    }
    @finally {
        return analyticsArray;
    }
}

-(void)deleteTable{
    NSString *insertSQL = [NSString stringWithFormat: @"DELETE FROM project"];
    sqlite3_stmt *stmt;
    if((sqlite3_open([[self databaseLocation] UTF8String], &db) != SQLITE_OK)){
        NSLog(@"An error has occured.");
    }
    if (sqlite3_prepare_v2(db, [insertSQL UTF8String], -1, &stmt, NULL) != SQLITE_OK){
        NSLog(@"error %s",sqlite3_errmsg(db));
    }
    else {
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            // Read the data from the result row
            NSLog(@"Deleted pal");
        }
    }
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    
}
-(void)InsertAnalytic:(Analytic*)analytic{
    NSString *dbPath = [self databaseLocation];
    const char *dbpath = [dbPath UTF8String];
    sqlite3_stmt    *stmt;
    if (sqlite3_open(dbpath, &db) == SQLITE_OK){
        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO project (projectId,month,day,hour,username,userId,token,minute,seconds,amPm,year) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')", analytic.projectId,analytic.month,analytic.day,analytic.hour,analytic.username,analytic.userId,analytic.token,analytic.minute,analytic.seconds,analytic.amPm,analytic.year];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(db, insert_stmt, -1, &stmt, NULL);
        if (sqlite3_step(stmt) == SQLITE_DONE){
            sqlite3_bind_text(stmt, 0, [analytic.projectId UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt, 1, [analytic.month UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt, 2, [analytic.day UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt, 3, [analytic.hour UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt, 4, [analytic.username UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt, 5, [analytic.userId UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt, 6, [analytic.token UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt, 7, [analytic.minute UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt, 8, [analytic.seconds UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt, 9, [analytic.amPm UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt, 10, [analytic.year UTF8String], -1, SQLITE_TRANSIENT);
        }
        else {
            //NSLog(@"error %s",sqlite3_errmsg(db));
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
}
-(NSString*)databaseLocation{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:SQLITEPATH];
    return dbPath;
}


+ (void)createEditableCopyOfDatabaseIfNeeded {
    //Create db in local file. This process will be done only once
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:SQLITEPATH];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success)
        return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:SQLITEPATH];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
    else{
        NSLog(@"DB copied");
    }
}
@end
