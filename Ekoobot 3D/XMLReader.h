//
//  XMLReader.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 10/07/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLReader : NSObject <NSXMLParserDelegate>
{
    NSMutableArray *dictionaryStack;
    NSMutableString *textInProgress;
    NSError *errorPointer;
}

+ (NSDictionary *)dictionaryForPath:(NSString *)path error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;

@end

@interface NSDictionary (XMLReaderNavigation)

- (id)retrieveForPath:(NSString *)navPath;

@end
