//
//  AcabadosCollectionViewCell.m
//  Ekoobot 3D
//
//  Created by Developer on 13/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "AcabadosCollectionViewCell.h"

@implementation AcabadosCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.imageView = [[UIImageView alloc] init];
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        [self.contentView addSubview:self.imageView];
        
        //Name Label
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.font = [UIFont systemFontOfSize:12.0];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.nameLabel];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    self.imageView.frame = CGRectMake(contentRect.size.width/2.0 - (contentRect.size.height - 20.0)/2.0, 0.0, contentRect.size.height - 20.0,contentRect.size.height - 20.0);
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width/2.0;
    self.nameLabel.frame = CGRectMake(0.0, self.imageView.frame.origin.y + self.imageView.frame.size.height, contentRect.size.width, 20.0);
}

@end
