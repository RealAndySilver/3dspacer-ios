//
//  PisoCollectionViewCell.m
//  Ekoobot 3D
//
//  Created by Developer on 9/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "PisoCollectionViewCell.h"

@implementation PisoCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //Piso ImageView
        self.pisoImageView = [[UIImageView alloc] init];
        self.pisoImageView.clipsToBounds = YES;
        self.pisoImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.pisoImageView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    self.pisoImageView.frame = CGRectMake(10.0, 10.0, contentRect.size.width - 20.0, contentRect.size.height - 20.0);
}

@end
