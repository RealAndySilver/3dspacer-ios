//
//  BrujulaView.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 11/12/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "BrujulaView.h"

@implementation BrujulaView
@synthesize cursor;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame=frame;
        self.backgroundColor=[UIColor clearColor];
        compassPlaceholder=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"brujula.png"]];
        compassPlaceholder.frame=CGRectMake(0, 0, self.frame.size.width , self.frame.size.height);
        compassPlaceholder.center=CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        compassPlaceholder.backgroundColor=[UIColor clearColor];
        [self addSubview:compassPlaceholder];
        cursor=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cursor.png"]];
        cursor.layer.shouldRasterize=YES;
        cursor.frame=CGRectMake(0, 0, (compassPlaceholder.frame.size.height-10)*0.25, compassPlaceholder.frame.size.height-10);
        cursor.center=CGPointMake(compassPlaceholder.frame.size.width/2,compassPlaceholder.frame.size.height/2);
        [compassPlaceholder addSubview:cursor];
        }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
