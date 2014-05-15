//
//  UpdateView.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 8/10/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import "UpdateView.h"

@implementation UpdateView
@synthesize backgroundImage,titleText,updateText,infoButton,container,pesoProyecto;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self placeView];
    }
    return self;
}
-(void)placeView{
    int marginTop=5;
    //infoButton=[UIButton buttonWithType:UIButtonTypeInfoLight];
    infoButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [infoButton setBackgroundImage:[UIImage imageNamed:@"ayuda_off.png"] forState:UIControlStateNormal];
    [infoButton setBackgroundImage:[UIImage imageNamed:@"ayuda.png"] forState:UIControlStateSelected];
    [infoButton addTarget:self action:@selector(alphaChange) forControlEvents:UIControlEventTouchUpInside];
    infoButton.frame=CGRectMake(10, self.frame.size.height/2-20, 40, 40);
    container=[[UIView alloc]initWithFrame:CGRectMake(30, 0, self.frame.size.width, self.frame.size.height)];
    titleText=[[UILabel alloc]initWithFrame:CGRectMake(45, marginTop, self.frame.size.width-0, 12)];
    titleText.textAlignment=NSTextAlignmentLeft;
    titleText.textAlignment=NSTextAlignmentLeft;
    titleText.backgroundColor=[UIColor clearColor];
    titleText.textColor=[UIColor whiteColor];
    [titleText setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    titleText.adjustsFontSizeToFitWidth = YES;
    updateText=[[UILabel alloc]initWithFrame:CGRectMake(45, marginTop+15, self.frame.size.width-45, 12)];
    updateText.textAlignment=NSTextAlignmentLeft;
    updateText.textAlignment=NSTextAlignmentLeft;
    updateText.backgroundColor=[UIColor clearColor];
    updateText.textColor=[UIColor whiteColor];
    [updateText setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    updateText.adjustsFontSizeToFitWidth = YES;
    updateText.text=@"Descarga el proyecto para visualizar";
    //[infoButton setHighlighted:YES];
    backgroundImage=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"updateBox.png"]];
    backgroundImage.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    backgroundImage.alpha=0;
    container.layer.borderWidth=1;
    container.layer.borderColor=[UIColor whiteColor].CGColor;
    container.backgroundColor=[UIColor blackColor];
    [container addSubview:backgroundImage];
    [container addSubview:titleText];
    [container addSubview:updateText];
    
    UIView *whiteCircle=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 42, 42)];
    whiteCircle.center=CGPointMake(0, container.frame.size.height/2);
    whiteCircle.layer.cornerRadius=20;
    whiteCircle.backgroundColor=[UIColor whiteColor];
    [container addSubview:whiteCircle];
    [self addSubview:container];
    [self addSubview:infoButton];
}
-(void)alphaChange{
    infoButton.selected = infoButton.selected ? NO:YES;
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
