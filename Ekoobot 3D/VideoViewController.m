//
//  VideoViewController.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 11/10/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import "VideoViewController.h"

@interface VideoViewController ()

@end

@implementation VideoViewController
@synthesize player,adjunto,proyecto;
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
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *text=NSLocalizedString(@"DescargaVideo", nil);
    hud.labelText=text;
    [self performSelector:@selector(loadVideo) withObject:nil afterDelay:0.001];
    
}
-(void)loadVideo{
    player = [[MPMoviePlayerController alloc] initWithContentURL:[self pathForSource]];
    player.scalingMode = MPMovieScalingModeAspectFit;
    player.movieSourceType = MPMovieSourceTypeFile;
    [player setControlStyle:MPMovieControlStyleEmbedded];
    [player setShouldAutoplay:YES];
    player.view.frame = CGRectMake(0, 0, self.view.frame.size.width/2, 576/2);
    player.view.center=CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2+45);
    [self.view addSubview:player.view];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
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
#pragma mark path returner
-(NSURL*)pathForSource{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *videoFilePath = [NSString stringWithFormat:@"%@/video%@.mp4",docDir,adjunto.ID];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:videoFilePath];
    if (!fileExists) {
        //NSLog(@"no existe proj img %@",jpegFilePath);
        NSURL *urlVideo=[NSURL URLWithString:adjunto.imagen];
        NSData *data=[NSData dataWithContentsOfURL:urlVideo];
        [data writeToFile:videoFilePath atomically:YES];
        NSLog(@"No Existe %@",adjunto.imagen);

        return urlVideo;
    }
    else {
        NSLog(@"Ya Existe %@",videoFilePath);
        return [NSURL fileURLWithPath:videoFilePath isDirectory:YES];
    }
}
#pragma mark rotation
-(BOOL)shouldAutorotate{
    return YES;
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
@end
