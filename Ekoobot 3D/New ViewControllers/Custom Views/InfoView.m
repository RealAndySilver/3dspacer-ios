//
//  InfoView.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 30/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "InfoView.h"

@implementation InfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1.0;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        
        //Top Label
        self.topLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 0.0, frame.size.width - 50.0, frame.size.height/2.0)];
        self.topLabel.text = @"You have the latest version.";
        self.topLabel.font = [UIFont systemFontOfSize:12.0];
        [self addSubview:self.topLabel];
        
        //Bottom Label
        self.bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, frame.size.height/2.0, frame.size.width - 50.0, frame.size.height/2.0)];
        self.bottomLabel.textColor = [UIColor whiteColor];
        self.bottomLabel.font = [UIFont systemFontOfSize:12.0];
        self.bottomLabel.text = @"Update on 2014-05-20 12:30";
        [self addSubview:self.bottomLabel];
    }
    return self;
}

-(void)setTopLabelColor:(UIColor *)topLabelColor {
    _topLabelColor = topLabelColor;
    self.topLabel.textColor = topLabelColor;
}


@end
