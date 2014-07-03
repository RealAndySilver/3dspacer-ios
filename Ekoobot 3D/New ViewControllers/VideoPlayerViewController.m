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

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"desapareceré");
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self) {
        // View is disappearing because a new view controller was pushed onto the stack
        NSLog(@"New view controller was pushed");
    } else if ([viewControllers indexOfObject:self] == NSNotFound) {
        // View is disappearing because it was popped from the stack
        NSLog(@"View controller was popped");
        [self.moviePlayerController stop];
        self.moviePlayerController = nil;
    }
}

@end
