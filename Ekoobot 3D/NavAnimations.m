//
//  NavAnimations.m
//  PrizeKing
//
//  Created by Andres Abril on 22/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NavAnimations.h"

@implementation NavAnimations
+(CATransition*)navAlphaAnimation{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return transition;
}
@end
