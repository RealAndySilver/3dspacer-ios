//
//  ShadowLabel.m
//  Ekoobot 3D
//
//  Created by Developer on 23/07/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "ShadowLabel.h"

@implementation ShadowLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)drawTextInRect:(CGRect)rect {
    CGSize myShadowOffset = CGSizeMake(1, 1);
    CGFloat myColorValues[] = {0, 0, 0, .8};
    
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(myContext);
    
    CGColorSpaceRef myColorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef myColor = CGColorCreate(myColorSpace, myColorValues);
    CGContextSetShadowWithColor (myContext, myShadowOffset, 2, myColor);
    
    [super drawTextInRect:rect];
    
    CGColorRelease(myColor);
    CGColorSpaceRelease(myColorSpace);
    
    CGContextRestoreGState(myContext);
}

@end
