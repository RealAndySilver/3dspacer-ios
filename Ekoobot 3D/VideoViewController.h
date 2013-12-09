//
//  VideoViewController.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 11/10/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Proyecto.h"
#import "IAmCoder.h"
#import "MBProgressHud.h"
#import "Adjunto.h"
#import <Foundation/Foundation.h>

@interface VideoViewController : UIViewController{
    MBProgressHUD *hud;
    NSMutableData *receivedData;
    long long expectedBytes;
    UIProgressView *progress;
}
@property (nonatomic)__strong MPMoviePlayerController *player;
@property (nonatomic,retain)Adjunto *adjunto;
@property (nonatomic,retain)Proyecto *proyecto;

@end
