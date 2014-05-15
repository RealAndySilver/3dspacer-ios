//
//  ProgressView.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 4/07/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import "ProgressView.h"

@implementation ProgressView
@synthesize loading=_loading;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        spinner=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.center=CGPointMake(self.frame.size.width/2, self.frame.size.height/2-80);
        [self bgInit];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(video) name:@"video" object:nil];
    return self;
}
-(void)video{
    [self performSelectorInBackground:@selector(del) withObject:nil];
}
-(void)del{
    hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.labelText=NSLocalizedString(@"DescargaVideo", nil);
    spinner.alpha=0;
    NSLog(@"video");
}
-(void)bgInit{
    CGRect viewFrame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIView *elView=[[UIView alloc]initWithFrame:viewFrame];
    [elView setClipsToBounds:YES];
    elView.backgroundColor=[UIColor blackColor];
    elView.alpha=1;
    UIImageView *backGround=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"downloading.jpg"]];
    backGround.frame=CGRectMake(-85, 0, self.frame.size.width+170, self.frame.size.height);
    backGround.clipsToBounds = YES;
    backGround.contentMode = UIViewContentModeScaleAspectFill;
    [elView addSubview:backGround];
    
    _loading=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 70)];
    _loading.center=CGPointMake(self.frame.size.width/2,self.frame.size.height/2+(self.frame.size.height/5.12));
    _loading.text=@"";
    _loading.font=[UIFont boldSystemFontOfSize:70];
    _loading.backgroundColor=[UIColor clearColor];
    _loading.textColor=[UIColor whiteColor];
    _loading.textAlignment=NSTextAlignmentCenter;
    UILabel *loadingLabel=[[UILabel alloc]init];
    loadingLabel.tag=12;
    loadingLabel.frame=CGRectMake(0, self.frame.size.height/1.536, self.frame.size.width/1.536, 40);
    loadingLabel.center=CGPointMake(self.frame.size.width/2, self.frame.size.height/2+(self.frame.size.height/4.5176));
    loadingLabel.text=NSLocalizedString(@"DescargandoProyecto", nil);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        loadingLabel.font = [UIFont boldSystemFontOfSize:16];
    } else {
        loadingLabel.font = [UIFont boldSystemFontOfSize:13.0];
    }
    loadingLabel.backgroundColor=[UIColor clearColor];
    loadingLabel.textColor=[UIColor grayColor];
    loadingLabel.textAlignment=NSTextAlignmentCenter;
    loadingLabel.numberOfLines = 0;
    progressBar=[[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
    progressBar.frame=CGRectMake(0, 0, self.frame.size.width/1.536, 50);
    progressBar.center=CGPointMake(self.frame.size.width/2, self.frame.size.height/2+(self.frame.size.height/3.84 + 10.0));
    [self addSubview:elView];
    [self addSubview:loadingLabel];
    [self addSubview:_loading];
    [self addSubview:progressBar];
    [self addSubview:spinner];
    self.alpha=0;
}
float i=0;
-(void)setText:(NSString*)text{
    //NSLog(@"Listo");
    float progressFloat=[text floatValue];
    //NSString *value=[NSString stringWithFormat:@"%.0f%%",progressFloat*100];
   /* @try {
        if ([_loading respondsToSelector:@selector(setText:)]) {
            //[_loading setText:value];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Execption %@",exception);
    }
    @finally {
    }
    
    _loading.center=CGPointMake((progressFloat*500)+300, self.frame.size.height/2+150);*/
    progressBar.progress=progressFloat;
}
-(void)stopHud:(NSNotification*)notification{
    i=0;
    progressBar.progress=0;
    _loading.text=@"";
    spinner.alpha=1;
    [MBProgressHUD hideHUDForView:self animated:YES];
    if (![progressThread isFinished]) {
        //[progressThread isFinished];
        //[stopThread isFinished];
        NSLog(@"finished");
    }
    
}
-(void)resetHud:(NSNotification*)notification{
    //stopThread=[[NSThread alloc]initWithTarget:self selector:@selector(stopHud:) object:notification];
    //if (![stopThread isExecuting]){
    //    [stopThread start];
    //}
    //[self performSelectorInBackground:@selector(stopHud:) withObject:notification];
    [self performSelector:@selector(stopHud:) withObject:notification];


}
-(void)updateLabel:(NSNotification*)notification{
    NSString *dic=notification.object;
    //progressThread=[[NSThread alloc]initWithTarget:self selector:@selector(setText:) object:dic];
    //if (![progressThread isExecuting]) {
    //    [progressThread start];
    //}
    [self performSelectorInBackground:@selector(setText:) withObject:dic];
    //[self performSelector:@selector(setText:) withObject:dic];

}
-(void)setViewAlphaToCero{
    NSThread *bThread=[[NSThread alloc]initWithTarget:self selector:@selector(threadTo0) object:nil];
    [bThread start];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"updateLabel" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"notificationStop" object:nil];

}
-(void)setViewAlphaToOne{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabel:) name:@"updateLabel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetHud:) name:@"notificationStop" object:nil];
    NSThread *bThread=[[NSThread alloc]initWithTarget:self selector:@selector(threadTo1) object:nil];
    [bThread start];
}
-(void)threadTo0{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    self.alpha=0;
    [UIView commitAnimations];
    [spinner stopAnimating];
}
-(void)threadTo1{
    [spinner startAnimating];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    self.alpha=1;
    [UIView commitAnimations];
}
@end
