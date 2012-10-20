//
//  VideoViewController.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 11/10/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Proyecto.h"
#import "IAmCoder.h"

@interface VideoViewController : UIViewController{
}
@property (nonatomic)__strong MPMoviePlayerController *player;
@property (nonatomic,retain)NSURL *videoPath;
@property (nonatomic,retain)Proyecto *proyecto;

@end
