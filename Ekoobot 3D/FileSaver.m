//
//  FileSaver.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 18/06/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import "FileSaver.h"
#define DATAFILENAME @"savefile.plist"
#define FRIENDLISTFILE @"friendList.plist"

@implementation FileSaver
-(id) init{
	if ((self = [super init])) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *Path = [paths objectAtIndex:0];
		//NSString *Path = [[NSBundle mainBundle] bundlePath];
		NSString *DataPath = [Path stringByAppendingPathComponent:DATAFILENAME];
		NSDictionary *tempDict = [[NSDictionary alloc] initWithContentsOfFile:DataPath];
		
        if (!tempDict) {
			tempDict = [[NSDictionary alloc] init];
		}
        datos = tempDict;
        
        NSArray *paths2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *Path2 = [paths2 objectAtIndex:0];
		//NSString *Path = [[NSBundle mainBundle] bundlePath];
		NSString *DataPath2 = [Path2 stringByAppendingPathComponent:FRIENDLISTFILE];
		NSDictionary *tempDict2 = [[NSDictionary alloc] initWithContentsOfFile:DataPath2];
		
        if (!tempDict2) {
			tempDict2 = [[NSDictionary alloc] init];
		}
        datosFriendList = tempDict2;
	}    
	return self;
}
-(BOOL)guardar{
	NSData *xmlData;  
	NSString *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *Path = [paths objectAtIndex:0];
	//NSString *Path = [[NSBundle mainBundle] bundlePath];
    //NSLog(@"guardar %@",datosConf);
	NSString *DataPath = [Path stringByAppendingPathComponent:DATAFILENAME];
	xmlData = [NSPropertyListSerialization dataFromPropertyList:datos format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];  
	if (xmlData) {  
		[xmlData writeToFile:DataPath atomically:YES];  
		return YES;
	} else {  
		NSLog(@"Error writing plist to file '%s', error = '%s'", [DataPath UTF8String], [error UTF8String]);  
		return NO;
	}
}

-(NSDictionary*)getDictionary:(NSString*)userId{
    return [datos objectForKey:userId];
}
-(void)setDictionary:(NSDictionary*)dictionary withUserId:(NSString*)userId{
	NSMutableDictionary *newData = [datos mutableCopy];
	[newData setObject:dictionary forKey:userId];
	datos = newData;
	[self guardar];
}

/*-(NSString*)getUserWithName:(NSString*)name andPassword:(NSString*)password{
    if ([[datos objectForKey:@"nombreLocal"]isEqualToString:name]&&[[datos objectForKey:@"passwordLocal"]isEqualToString:password]) {
        return [datos objectForKey:@"idLocal"];
    }
    else{
        return nil;
    }
}
-(void)setUserName:(NSString*)name password:(NSString*)password andId:(NSString*)ID{
    NSMutableDictionary *newData = [datos mutableCopy];
    [newData setObject:name forKey:@"nombreLocal"];
    [newData setObject:password forKey:@"passwordLocal"];
    [newData setObject:ID forKey:@"idLocal"];
	datos = newData;
	[self guardar];
}*/
-(NSString*)getUserWithName:(NSString*)name andPassword:(NSString*)password{
    if ([[datos objectForKey:name]isEqualToString:name]&&[[datos objectForKey:password]isEqualToString:password]) {
        NSString *namePass=[NSString stringWithFormat:@"%@%@",name,password];
        return [datos objectForKey:namePass];
    }
    else{
        return nil;
    }
}
-(void)setUserName:(NSString*)name password:(NSString*)password andId:(NSString*)ID{
    NSMutableDictionary *newData = [datos mutableCopy];
    [newData setObject:name forKey:name];
    [newData setObject:password forKey:password];
    NSString *namePass=[NSString stringWithFormat:@"%@%@",name,password];
    [newData setObject:ID forKey:namePass];
	datos = newData;
	[self guardar];
}

-(NSString *)getUpdateFile:(int)tag{
    NSString *string=[NSString stringWithFormat:@"%i",tag];
    NSString *date=[datos objectForKey:string];
    return date;
}
-(NSString *)getUpdateFileWithString:(NSString*)tag{
    NSString *string=[NSString stringWithFormat:@"%@",tag];
    NSString *date=[datos objectForKey:string];
    return date;
}

-(void)setUpdateFile:(NSString *)name date:(NSString *)date andTag:(int)tag{
    NSMutableDictionary *newData = [datos mutableCopy];
    NSString *string=[NSString stringWithFormat:@"%i",tag];
    [newData setObject:date forKey:string];
	datos = newData;
	[self guardar];
}
-(void)setUpdateFile:(NSString *)name date:(NSString *)date andTag:(int)tag andId:(NSString *)ID{
    NSMutableDictionary *newData = [datos mutableCopy];
    NSString *string=[NSString stringWithFormat:@"%i%@",tag,ID];
    [newData setObject:date forKey:string];
	datos = newData;
	[self guardar];
}
-(NSString*)getNombre{
    return [datos objectForKey:@"nombreLocal"];
}
-(NSString*)getPassword{
    return [datos objectForKey:@"passwordLocal"];
}

-(void)setLastUserName:(NSString *)name andPassword:(NSString *)password{
    NSMutableDictionary *newData = [datos mutableCopy];
	[newData setObject:name forKey:@"name"];
    [newData setObject:password forKey:@"password"];
	datos = newData;
	[self guardar];
}
-(NSDictionary *)getLastUserNameAndPassword{
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    if ([[datos objectForKey:@"name"] isKindOfClass:[NSString class]]) {
        [dic setObject:[datos objectForKey:@"name"] forKey:@"name"];
        [dic setObject:[datos objectForKey:@"password"] forKey:@"password"];
    }
    return dic;
}

@end
