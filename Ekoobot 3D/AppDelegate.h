//
//  AppDelegate.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 4/17/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileSaver.h"
#import <CoreMotion/CoreMotion.h>
#import "SqlHandler.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate, ServerCommunicatorDelegate>{
    //ServerCommunicator *server;
    //NSString *methodName;
    //int test;
    //CMMotionManager *motionManager;
}

@property (assign, nonatomic) BOOL screenIsLandscapeLeftOnly;
@property (assign, nonatomic) BOOL screenIsLandscapeRightOnly;
@property (strong, nonatomic) UIWindow *window;

@end
