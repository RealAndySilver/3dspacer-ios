//
//  PlanosCollectionViewCell.m
//  Ekoobot 3D
//
//  Created by Developer on 6/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "PlanosCollectionViewCell.h"

@interface PlanosCollectionViewCell()
@property (strong, nonatomic) UIButton *brujulaButton;
@end

@implementation PlanosCollectionViewCell

-(id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //Imageview
        self.planoImageView = [[UIImageView alloc] init];
        self.planoImageView.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:self.planoImageView];
        
        //Espacio button
        self.espacioButton = [[UIButton alloc] init];
        self.espacioButton.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:self.espacioButton];
        
        //Brujula button
        self.brujulaButton = [[UIButton alloc] init];
        [self.brujulaButton setBackgroundImage:[UIImage imageNamed:@"compassOn.png"] forState:UIControlStateNormal];
        [self.planoImageView addSubview:self.brujulaButton];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    self.planoImageView.frame = CGRectMake(10.0, 10.0, contentRect.size.width - 20.0, contentRect.size.height - 20.0);
    self.espacioButton.frame = CGRectMake(30.0, 30.0, 30.0, 30.0);
    self.brujulaButton.frame = CGRectMake(self.planoImageView.frame.size.width - 50.0, 10.0, 40.0, 40.0);
}

@end
