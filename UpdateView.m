//
//  UpdateView.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 8/10/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "UpdateView.h"

@implementation UpdateView
@synthesize backgroundImage,titleText,updateText,infoButton,container;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self placeView];
    }
    return self;
}
-(void)placeView{
    int marginTop=10;
    infoButton=[UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(alphaChange) forControlEvents:UIControlEventTouchUpInside];
    infoButton.frame=CGRectMake(10, self.frame.size.height/2-10, 20, 20);
    container=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    titleText=[[UILabel alloc]initWithFrame:CGRectMake(0, marginTop, self.frame.size.width-0, 20)];
    titleText.textAlignment=UITextAlignmentCenter;
    titleText.backgroundColor=[UIColor clearColor];
    titleText.textColor=[UIColor whiteColor];
    [titleText setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    titleText.adjustsFontSizeToFitWidth = YES;
    updateText=[[UILabel alloc]initWithFrame:CGRectMake(0, marginTop+20, self.frame.size.width-0, 20)];
    updateText.textAlignment=UITextAlignmentCenter;
    updateText.textAlignment=UITextAlignmentCenter;
    updateText.backgroundColor=[UIColor clearColor];
    updateText.textColor=[UIColor whiteColor];
    [updateText setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    updateText.adjustsFontSizeToFitWidth = YES;
    updateText.text=@"Descarga el proyecto para visualizar";
    //[infoButton setHighlighted:YES];
    backgroundImage=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"updateBox.png"]];
    backgroundImage.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [container addSubview:backgroundImage];
    [container addSubview:titleText];
    [container addSubview:updateText];
    [self addSubview:container];
    [self addSubview:infoButton];
}
-(void)alphaChange{
    float tiempo=0.5;
    if (container.alpha==0) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:tiempo];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        container.alpha=1;
        [UIView commitAnimations];
    }
    else if (container.alpha==1){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:tiempo];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        container.alpha=0;
        [UIView commitAnimations];
    }
}

@end
