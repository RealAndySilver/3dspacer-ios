//
//  SlideshowViewController.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 4/08/13.
//  Copyright (c) 2013 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KASlideShow.h"
@interface SlideshowViewController : UIViewController{
    KASlideShow *slideshow;
}
@property(nonatomic,retain)NSArray *imagePathArray;
@property(nonatomic,retain)UIWindow *window;

@end
