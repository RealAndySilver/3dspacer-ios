//
//  LoadingView.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 12/07/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        spinner=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.center=CGPointMake(self.frame.size.width/2, self.frame.size.height/2-40);
        [self bgInit];
    }
    return self;
}
-(void)bgInit{
    CGRect viewFrame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIView *elView=[[UIView alloc]initWithFrame:viewFrame];
    [elView setClipsToBounds:YES];
    elView.backgroundColor=[UIColor blackColor];
    elView.alpha=0.5;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self 
               action:@selector(aMethod:)
     forControlEvents:UIControlEventTouchDown];
    button.frame = CGRectMake(0, 0, 130, 130);
    button.center=CGPointMake(self.frame.size.width/2, self.frame.size.height/2-30);
    button.alpha=0;
    loading=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    loading.center=CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
    loading.text=NSLocalizedString(@"Cargando", nil);
    loading.backgroundColor=[UIColor clearColor];
    loading.textColor=[UIColor whiteColor];
    loading.textAlignment=UITextAlignmentCenter;
    [self addSubview:elView];
    [self addSubview:button];
    [self addSubview:loading];
    [self addSubview:progressBar];
    [self addSubview:spinner];
    self.alpha=0;
}
-(void)setViewAlphaToCero{
    [self performSelectorInBackground:@selector(threadTo0) withObject:nil];
}
-(void)setViewAlphaToOne:(NSString*)string{
    [self performSelectorInBackground:@selector(threadTo1:) withObject:string];
}
-(void)threadTo0{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    self.alpha=0;
    [UIView commitAnimations];
    [spinner stopAnimating];
}
-(void)threadTo1:(NSString*)string{
    loading.text=[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Cargando", nil),string];
    [spinner startAnimating];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    self.alpha=1;
    [UIView commitAnimations];
}
@end
