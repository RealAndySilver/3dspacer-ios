//
//  More3DScenesCollectionViewCell.m
//  Ekoobot 3D
//
//  Created by Developer on 5/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "More3DScenesCollectionViewCell.h"

@implementation More3DScenesCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor orangeColor];
        
        self.sceneNameLabel = [[UILabel alloc] init];
        self.sceneNameLabel.textColor = [UIColor whiteColor];
        self.sceneNameLabel.backgroundColor = [UIColor blackColor];
        self.sceneNameLabel.textAlignment = NSTextAlignmentCenter;
        self.sceneNameLabel.font = [UIFont systemFontOfSize:13.0];
        [self.contentView addSubview:self.sceneNameLabel];
        
        self.sceneImageView = [[UIImageView alloc] init];
        self.sceneImageView.clipsToBounds = YES;
        self.sceneImageView.backgroundColor = [UIColor grayColor];
        self.sceneImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.sceneImageView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    self.sceneNameLabel.frame = CGRectMake(0.0, 0.0, contentRect.size.width, 20.0);
    self.sceneImageView.frame = CGRectMake(0.0, 20.0, contentRect.size.width, contentRect.size.height - 20.0);
}

@end
