//
//  NSDictionary+NullReplacement.m
//  CaracolPlay
//
//  Created by Diego Vidal on 13/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "NSDictionary+NullReplacement.h"

@implementation NSDictionary (NullReplacement)

-(NSDictionary *)dictionaryByReplacingNullWithBlanks {
    const NSMutableDictionary *replaced = [self mutableCopy];
    const id nul = [NSNull null];
    const NSString *blank = @"";
    
    for (NSString *key in self) {
        id object = [self objectForKey:key];
        if (object == nul) [replaced setObject:blank forKey:key];
        else if ([object isKindOfClass:[NSDictionary class]]) [replaced setObject:[object dictionaryByReplacingNullWithBlanks] forKey:key];
        //else if ([object isKindOfClass:[NSArray class]]) [replaced setObject:[object arrayByReplacingNullsWithBlanks] forKey:key];
    }
    return [NSDictionary dictionaryWithDictionary:[replaced copy]];
}

@end
