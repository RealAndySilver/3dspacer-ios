//
//  CMMotionManager+Shared.m
//  Ekoobot 3D
//
//  Created by Developer on 6/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "CMMotionManager+Shared.h"

@implementation CMMotionManager (Shared)

+(CMMotionManager *)sharedMotionManager {
    static CMMotionManager *shared = nil;
    if (!shared) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shared = [[CMMotionManager alloc] init];
        });
    }
    return shared;
}

@end
