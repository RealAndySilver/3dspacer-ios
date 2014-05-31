//
//  TermsAndConditionsViewController.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "TermsAndConditionsViewController.h"
#import "MainCarouselViewController.h"

@interface TermsAndConditionsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIWebView *termsWebView;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@end

@implementation TermsAndConditionsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI {
    
    //WebView
    NSString *htmlString = [NSString stringWithFormat:@"<html><body style='background-color: transparent; color:black; font-family: helvetica;'>%@</body></html>",self.termsString];
    self.termsWebView.opaque = NO;
    self.termsWebView.backgroundColor = [UIColor clearColor];
    [self.termsWebView loadHTMLString:htmlString baseURL:nil];
    
    //Buttons
    if (self.controllerWasPresentedFromDownloadButton) {
        NSLog(@"Mostraré el cancel button");
        self.cancelButton.hidden = NO;
        [self.cancelButton addTarget:self action:@selector(dismissVCWithCancel) forControlEvents:UIControlEventTouchUpInside];
        [self.dismissButton addTarget:self action:@selector(acceptTerms) forControlEvents:UIControlEventTouchUpInside];
    } else {
        NSLog(@"No mostraré el cancel button");
        self.cancelButton.hidden = YES;
        [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - Actions

-(void)acceptTerms {
    [self.delegate userDidAcceptTerms];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dismissVCWithCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
