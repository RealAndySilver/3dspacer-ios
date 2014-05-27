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
@property (strong, nonatomic) UILabel *percentageLabel;
@end

@implementation DownloadView

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
        
        self.alpha = 0.0;
        self.layer.cornerRadius = 10.0;
        self.backgroundColor = [UIColor whiteColor];
        
        //Title
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, frame.size.width, 40.0)];
        titleLabel.text = @"Project Download";
        titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        titleLabel.textColor = [UIColor lightGrayColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
        //PercentageLabel
        self.percentageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 20.0)];
        self.percentageLabel.textColor = [UIColor blackColor];
        self.percentageLabel.text = @"0";
        [self addSubview:self.percentageLabel];
        
        //Spinner
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.frame = CGRectMake(frame.size.width/2.0 - 20.0, frame.size.height/2.0 - 40.0, 40.0, 40.0);
        [self addSubview:spinner];
        [spinner startAnimating];
        
        //ProgressView
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.progressView.frame = CGRectMake(30.0, frame.size.height/2.0 + 10.0, frame.size.width - 60.0, 20.0);
        [self.progressView setProgress:0.0 animated:NO];
        [self addSubview:self.progressView];
        
        //Cancel Button
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, frame.size.height - 44.0, frame.size.width - 40.0, 44.0)];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
        
        [self animateOpacity];
    }
    return self;
}

-(void)animateOpacity {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.alpha = 1.0;
                     } completion:^(BOOL finished){}];
}

#pragma mark - Actions 

-(void)closeView {
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
}

#pragma mark - Notification Handlers

-(void)fileDownloadNotificationReceived:(NSNotification *)notification {
    NSDictionary *notificationDic = [notification userInfo];
    float progress = [notificationDic[@"Progress"] floatValue];
    //self.progressView.progress = progress;
    self.percentageLabel.text = [NSString stringWithFormat:@"%f", progress];
    NSLog(@"percentaje label: %@", self.percentageLabel.text);
    //NSLog(@"Progreso: %f", self.progressView.progress);
}

-(void)downloadCompleteNotificationReceived:(NSNotification *)notification {
    NSLog(@"Se completó la descarga");
    [self closeView];
}

@end
