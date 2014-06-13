//
//  VideoPlayerViewController.m
//  Ekoobot 3D
//
//  Created by Developer on 12/06/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VideoPlayerViewController ()
@property (strong, nonatomic) MPMoviePlayerController *moviePlayerController;
@end

@implementation VideoPlayerViewController {
    CGRect screenBounds;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    CGRect screen = [UIScreen mainScreen].bounds;
    screenBounds = CGRectMake(0.0, 0.0, screen.size.height, screen.size.width);
    NSLog(@"video file path: %@", self.videoFilePath);
    self.moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:self.videoFilePath]];
    [self.moviePlayerController prepareToPlay];
    self.moviePlayerController.view.frame = screenBounds;
    [self.view addSubview:self.moviePlayerController.view];
    self.moviePlayerController.scalingMode = MPMovieScalingModeAspectFill;
    self.moviePlayerController.movieSourceType = MPMovieSourceTypeFile;
    [self.moviePlayerController play];
}

@end
