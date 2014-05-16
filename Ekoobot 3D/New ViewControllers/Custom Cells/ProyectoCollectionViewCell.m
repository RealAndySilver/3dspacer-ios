//
//  ProyectoCollectionViewCell.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 8/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "ProyectoCollectionViewCell.h"

@interface ProyectoCollectionViewCell()
@property (strong, nonatomic) UIButton *zoomButton;
@end

@implementation ProyectoCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor blackColor];
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];
        
        //Zooom button
        self.zoomButton = [[UIButton alloc] init];
        [self.zoomButton setImage:[UIImage imageNamed:@"zoom.png"] forState:UIControlStateNormal];
        [self.zoomButton addTarget:self action:@selector(zoomButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.zoomButton];
        
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    self.imageView.frame = CGRectMake(0.0, 0.0, contentRect.size.width, contentRect.size.height);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.zoomButton.frame = CGRectMake(53, 540, 40, 40);
    } else {
        self.zoomButton.frame = CGRectMake(10.0, 220.0, 40.0, 40.0);
    }
}

#pragma mark - Actions 

-(void)zoomButtonTapped {
    [self.delegate zoomButtonTappedInCell:self];
}

@end
