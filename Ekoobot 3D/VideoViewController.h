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
#import "MBProgressHud.h"
#import "Adjunto.h"

@interface VideoViewController : UIViewController{
    MBProgressHUD *hud;
}
@property (nonatomic)__strong MPMoviePlayerController *player;
@property (nonatomic,retain)Adjunto *adjunto;
@property (nonatomic,retain)Proyecto *proyecto;

@end
