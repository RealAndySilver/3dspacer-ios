//
//  DownloadView.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 27/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "DownloadView.h"

@interface DownloadView()
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UILabel *progressLabel;
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
        titleLabel.text = @"IMPORTANT";
        titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        titleLabel.textColor = [UIColor lightGrayColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:titleLabel];
        
        //Description Label
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 40.0, frame.size.width - 40.0, 80.0)];
        descriptionLabel.text = @"YOUR PROJECT IS DOWNLOADING. PLEASE WAIT.";
        descriptionLabel.textColor = [UIColor lightGrayColor];
        descriptionLabel.font = [UIFont boldSystemFontOfSize:15.0];
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:descriptionLabel];
      
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
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width/2.0 - 22.0, frame.size.height/2.0, 44.0, 44.0)];
        [cancelButton setBackgroundImage:[UIImage imageNamed:@"NewCancelDownloadIcon.png"] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelDownload) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
        
        //[self animateOpacity];
    }
    return self;
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
