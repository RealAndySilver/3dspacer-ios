//
//  DownloadView.h
//  Ekoobot 3D
//
//  Created by Diego Vidal on 27/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DownloadView;

@protocol DownloadViewDelegate <NSObject>
-(void)cancelButtonWasTappedInDownloadView:(DownloadView *)downloadView;
-(void)downloadVideoButtonWasTappedInDownloadView:(DownloadView *)downloadView;
-(void)downloadViewWillDisappear:(DownloadView *)downloadView;
-(void)downloadViewDidDisappear:(DownloadView *)downloadView;

@end

@interface DownloadView : UIView
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UILabel *progressLabel;
@property (strong, nonatomic) id <DownloadViewDelegate> delegate;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UIButton *downloadVideoButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (assign, nonatomic) float progress;
@end
