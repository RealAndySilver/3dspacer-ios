//
//  FileSaver.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 18/06/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileSaver : NSObject{
    NSDictionary *datos;
    NSDictionary *datosFriendList;

}
-(NSDictionary*)getDictionary:(NSString*)userId;
-(void)setDictionary:(NSDictionary*)dictionary withUserId:(NSString*)userId;
-(NSString*)getUserWithName:(NSString*)name andPassword:(NSString*)password;
-(void)setUserName:(NSString*)name password:(NSString*)password andId:(NSString*)ID;
-(NSString*)getUpdateFile:(int)tag;
-(NSString *)getUpdateFileWithString:(NSString*)tag;
-(void)setUpdateFile:(NSString*)name date:(NSString*)date andTag:(int)tag;
-(void)setUpdateFile:(NSString*)name date:(NSString*)date andTag:(int)tag andId:(NSString*)ID;
-(void)setLastUserName:(NSString*)name andPassword:(NSString*)password;
-(NSDictionary*)getLastUserNameAndPassword;

-(NSString*)getNombre;
-(NSString*)getPassword;

-(void)setDictionary:(NSDictionary*)dictionary withName:(NSString*)dicName;
-(NSDictionary*)getDictionaryWithName:(NSString*)dicName;
@end
