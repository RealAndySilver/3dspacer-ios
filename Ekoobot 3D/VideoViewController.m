//
//  VideoViewController.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 11/10/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import "VideoViewController.h"

@interface VideoViewController (){
    UIButton *cancelButton;
    NSURLConnection * connection;
    UILabel *progressLabel;
}

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
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/cover%@%@.jpeg",docDir,proyecto.idProyecto,[IAmCoder encodeURL:proyecto.imagen]];
    UIImageView *backgroundImage=[[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:jpegFilePath]];
    backgroundImage.frame=CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
    backgroundImage.alpha=0.15;
    [backgroundImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.view addSubview:backgroundImage];
    
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.opacity=0;

    NSString *text=NSLocalizedString(@"DescargaVideo", nil);
    hud.labelText=text;
    player = [[MPMoviePlayerController alloc] init];
    player.view.frame = CGRectMake(0, 0, self.view.frame.size.width/2, 576/2);
    player.view.center=CGPointMake(self.view.frame.size.height/2, self.view.frame.size.width/2+45);
    
    [self performSelector:@selector(loadVideo) withObject:nil afterDelay:0.001];
    progress=[[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
    progress.frame=CGRectMake(0, 0, self.view.frame.size.height/7, 20);
    progress.center=CGPointMake(self.view.frame.size.height/2, self.view.frame.size.width/2+50);
    [self.view addSubview:progress];
    progress.hidden=YES;
    progressLabel=[[UILabel alloc]initWithFrame:CGRectMake(progress.frame.origin.x+
                                                           progress.frame.size.width+10,
                                                           progress.frame.origin.y-5,
                                                           100,
                                                           20)];
    progressLabel.text=@"0.0%";
    progressLabel.backgroundColor=[UIColor clearColor];
    progressLabel.textColor=[UIColor whiteColor];
    progressLabel.hidden=YES;
    [self.view addSubview:progressLabel];
    
    cancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setBackgroundColor:[UIColor redColor]];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];

    [cancelButton setTitle:NSLocalizedString(@"Cancelar", nil) forState:UIControlStateNormal];
    cancelButton.frame=CGRectMake(0, 0, 100, 38);
    cancelButton.center=CGPointMake(self.view.frame.size.height/2, self.view.frame.size.width/2+95);
    cancelButton.hidden=YES;
    [self.view addSubview:cancelButton];

}
-(void)loadVideo{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *videoFilePath = [NSString stringWithFormat:@"%@/video%@.mp4",docDir,adjunto.ID];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:videoFilePath];
    
    if (fileExists) {
        UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
        dismissTap.numberOfTapsRequired=1;
        [self.view addGestureRecognizer:dismissTap];
        player.contentURL=[self pathForSource];
        player.scalingMode = MPMovieScalingModeAspectFit;
        player.movieSourceType = MPMovieSourceTypeFile;
        [player setControlStyle:MPMovieControlStyleEmbedded];
        [player setShouldAutoplay:YES];
        
        [self.view addSubview:player.view];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [player prepareToPlay];
    }
    else{
        [self downloadWithNsurlconnection];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)back:(id)sender{
    [player stop];
    player=nil;
    [connection cancel];
    connection=nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark path returner
-(NSURL*)pathForSource{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
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
#pragma mark - nsurl connection delegate
-(void)downloadWithNsurlconnection{
    NSURL *url = [NSURL URLWithString:adjunto.imagen];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    [theRequest setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
    connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
    if(connection) {
        receivedData = [[NSMutableData alloc] initWithLength:0];
	}
	else {
		NSLog(@"theConnection is NULL");
	}
}


- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    progress.hidden = NO;
    progressLabel.hidden=NO;
    cancelButton.hidden=NO;

    [receivedData setLength:0];
    expectedBytes = [response expectedContentLength];
    NSLog(@"Cantidad esperada %lld",[response expectedContentLength]);
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
    float progressive = (float)[receivedData length] / (float)expectedBytes;
    [progress setProgress:progressive];
    progressLabel.text=[NSString stringWithFormat:@"%.1f%%",progressive*100];
    NSLog(@"El progreso es: %f y lo esperado es: %lld",progressive,expectedBytes);
    
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSString *titulo=NSLocalizedString(@"Error", nil);
    NSString *mensaje=NSLocalizedString(@"ErrorConexion", nil);
    [[[UIAlertView alloc]initWithTitle:titulo message:mensaje delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
    [self performSelector:@selector(back:) withObject:nil afterDelay:0.5];
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *videoFilePath = [NSString stringWithFormat:@"%@/video%@.mp4",docDir,adjunto.ID];
    [receivedData writeToFile:videoFilePath atomically:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    progress.hidden = YES;
    cancelButton.hidden=YES;
    progressLabel.hidden=YES;
    [self loadVideo];
}
@end
