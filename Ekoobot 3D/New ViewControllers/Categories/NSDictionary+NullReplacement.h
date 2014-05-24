//
//  NSDictionary+NullReplacement.h
//  CaracolPlay
//
//  Created by Diego Vidal on 13/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NullReplacement)
-(NSDictionary *)dictionaryByReplacingNullWithBlanks;
@end
