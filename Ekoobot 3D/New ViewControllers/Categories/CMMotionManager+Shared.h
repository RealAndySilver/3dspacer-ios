//
//  CMMotionManager+Shared.h
//  Ekoobot 3D
//
//  Created by Developer on 6/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>

@interface CMMotionManager (Shared)
+(CMMotionManager *)sharedMotionManager;
@end
