//
//  DownloadView.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 27/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "DownloadView.h"

@interface DownloadView()

@end

@implementation DownloadView

#pragma mark - Getters & Setters

-(void)setProgress:(float)progress {
    _progress = progress;
    self.progressView.progress = progress;
    int progressPercentaje = progress * 100.0;
    self.progressLabel.text = [NSString stringWithFormat:@"%d%%", progressPercentaje];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fileDownloadNotificationReceived:)
                                                     name:@"fileDownloaded"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadCompleteNotificationReceived:)
                                                     name:@"downloadCompleted"
                                                   object:nil];
        
        //self.alpha = 0.0;
        self.layer.cornerRadius = 4.0;
        self.backgroundColor = [UIColor whiteColor];
        
        //Background Image
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NewDownloadBox.png"]];
        backgroundImageView.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        [self addSubview:backgroundImageView];
        
        //Title
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 10.0, frame.size.width, 40.0)];
        titleLabel.text = NSLocalizedString(@"Importante", nil);
        titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        titleLabel.textColor = [UIColor lightGrayColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:titleLabel];
        
        //Description Label
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 40.0, frame.size.width - 40.0, 80.0)];
        self.descriptionLabel.text = NSLocalizedString(@"DescargandoProyecto", nil);
        self.descriptionLabel.textColor = [UIColor lightGrayColor];
        self.descriptionLabel.font = [UIFont boldSystemFontOfSize:15.0];
        self.descriptionLabel.numberOfLines = 0;
        self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.descriptionLabel];
      
        //Spinner
        /*UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.frame = CGRectMake(frame.size.width/2.0 - 20.0, frame.size.height/2.0 - 40.0, 40.0, 40.0);
        [self addSubview:spinner];
        [spinner startAnimating];*/
        
        //ProgressView
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.progressView.frame = CGRectMake(80.0, frame.size.height - 40.0, frame.size.width - 160.0, 20.0);
        [self.progressView setProgress:0.0 animated:NO];
        [self addSubview:self.progressView];
        
        //Progress Label
        self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 60.0, self.progressView.frame.origin.y - 20.0, 60.0, 40.0)];
        self.progressLabel.text = @"0%";
        self.progressLabel.textColor = [UIColor lightGrayColor];
        self.progressLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [self addSubview:self.progressLabel];
        
        //Cancel Button
        self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width/2.0 - 22.0, frame.size.height/2.0, 44.0, 44.0)];
        [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"NewCancelDownloadIcon.png"] forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(cancelDownload) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cancelButton];
        
        //DownloadVideo Button
        self.downloadVideoButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.downloadVideoButton.frame = CGRectMake(frame.size.width/2.0 - 20.0 - 44.0, frame.size.height/2.0, 44.0, 44.0);
        [self.downloadVideoButton setBackgroundImage:[UIImage imageNamed:@"DownloadVideoIcon.png"] forState:UIControlStateNormal];
        self.downloadVideoButton.hidden = YES;
        [self.downloadVideoButton addTarget:self action:@selector(downloadVideo) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.downloadVideoButton];
        
        //[self animateOpacity];
    }
    return self;
}

-(void)downloadVideo {
    [self.delegate downloadVideoButtonWasTappedInDownloadView:self];
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.downloadVideoButton.alpha = 0.0;
                         self.cancelButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                     } completion:^(BOOL finished){}];
}

/*-(void)animateOpacity {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.alpha = 1.0;
                     } completion:^(BOOL finished){}];
}*/

#pragma mark - Actions 

-(void)cancelDownload {
    [self.delegate cancelButtonWasTappedInDownloadView:self];
    self.downloadVideoButton.alpha = 1.0;
    self.cancelButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
}

/*-(void)closeView {
    //[self.delegate cancelButtonWasTappedInDownloadView:self];
    [self.delegate downloadViewWillDisappear:self];
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.alpha = 0.0;
                     } completion:^(BOOL finished){
                         [self.delegate downloadViewDidDisappear:self];
                     }];
}*/

#pragma mark - Notification Handlers

-(void)fileDownloadNotificationReceived:(NSNotification *)notification {
    NSDictionary *notificationDic = [notification userInfo];
    float progress = [notificationDic[@"Progress"] floatValue];
    self.progressView.progress = progress;
    int progressPercentaje = progress * 100.0;
    self.progressLabel.text = [NSString stringWithFormat:@"%d%%", progressPercentaje];
    NSLog(@"Progress del progressview: %f", self.progressView.progress);
}

-(void)downloadCompleteNotificationReceived:(NSNotification *)notification {
    NSLog(@"Se completó la descarga");
    //[self closeView];
    [self.delegate downloadViewDidDisappear:self];
}

@end
