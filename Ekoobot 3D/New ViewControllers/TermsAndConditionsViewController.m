//
//  TermsAndConditionsViewController.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "TermsAndConditionsViewController.h"

@interface TermsAndConditionsViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *termsWebView;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@end

@implementation TermsAndConditionsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI {
    NSString *htmlString = [NSString stringWithFormat:@"<html><body style='background-color: transparent; color:black; font-family: helvetica;'>%@</body></html>",self.termsString];
    self.termsWebView.opaque = NO;
    self.termsWebView.backgroundColor = [UIColor clearColor];
    [self.termsWebView loadHTMLString:htmlString baseURL:nil];
    
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Actions

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
