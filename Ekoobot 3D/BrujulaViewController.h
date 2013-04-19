//
//  BrujulaViewController.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 11/12/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import "BrujulaView.h"
#import "AppDelegate.h"
#import "NavController.h"
@interface BrujulaViewController : UIViewController<UIScrollViewDelegate>{
    BOOL zoomCheck;
    float maximumZoomScale;
    float minimumZoomScale;
    UIScrollView *scrollViewRotar;
    UIScrollView *scrollViewImagen;
    UIImageView *imageViewZoomImage;
    CMAttitude *attitude;
    CMMotionManager *_motionManager;
    NSTimer *timer;
    BrujulaView *brujula;
    float diferenciaRotacion;
    float adicionalGrados;

}
@property(nonatomic)NSString *path;
@property(nonatomic)UIImageView *externalImageView;
@property(nonatomic)float gradosExtra;
@end
