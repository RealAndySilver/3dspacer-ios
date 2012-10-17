//
//  VideoViewController.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 11/10/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "VideoViewController.h"

@interface VideoViewController ()

@end

@implementation VideoViewController
@synthesize player,videoPath;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor blackColor];
    player = [[MPMoviePlayerController alloc] initWithContentURL:videoPath];
    player.scalingMode = MPMovieScalingModeFill;
    player.movieSourceType = MPMovieSourceTypeFile;
    [player setControlStyle:MPMovieControlStyleEmbedded];
    [player setShouldAutoplay:YES];
    player.view.frame = CGRectMake(0, 0, self.view.frame.size.height/2, 576/2);
    player.view.center=CGPointMake(self.view.frame.size.height/2, self.view.frame.size.width/2+45);
    [self.view addSubview:player.view];
    [player prepareToPlay];
}
-(void)viewWillAppear:(BOOL)animated{
    UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
    dismissTap.numberOfTapsRequired=1;
    [self.view addGestureRecognizer:dismissTap];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)back:(id)sender{
    [player stop];
    player=nil;
    [self dismissModalViewControllerAnimated:YES];
}
@end
