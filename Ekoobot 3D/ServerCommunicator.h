//
//  ServerCommunicator.h
//  PrizeKing
//
//  Created by Andres Abril on 10/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLReader.h"
#import "FileSaver.h"

@interface ServerCommunicator : NSObject<UITextFieldDelegate,NSXMLParserDelegate>{
    id caller;
    int tag;
    //----- Direcciones del WebService-----
	NSMutableData *webData;
	NSMutableString *soapResults;
    NSURLConnection *theConnection;
    
    //----- XML Parsing
	NSXMLParser *xmlParser;
	BOOL elementFound;
    
    NSDictionary *dictionary;
    NSMutableArray *objectDic;
    
    
    
}
@property int tag;
@property (nonatomic,retain) id caller;
@property (nonatomic,retain) NSMutableArray *objectDic;
@property (nonatomic,retain) NSMutableDictionary *resDic;

@property(nonatomic,retain)NSDictionary *dictionary;
-(void)callServerWithMethod:(NSString*)method 
               andParameter:(NSString*)parameter;

@end
