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
        self.contentView.backgroundColor = [UIColor clearColor];
        
        //Imageview
        self.planoImageView = [[UIImageView alloc] init];
        self.planoImageView.backgroundColor = [UIColor blackColor];
        self.planoImageView.clipsToBounds = YES;
        self.planoImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.planoImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:self.planoImageView];
        
        //Brujula button
        self.brujulaButton = [[UIButton alloc] init];
        [self.brujulaButton setBackgroundImage:[UIImage imageNamed:@"compassOn.png"] forState:UIControlStateNormal];
        [self.planoImageView addSubview:self.brujulaButton];
        
        //espacio 3d 1
        self.espacio3D1 = [[UIButton alloc] init];
        [self.espacio3D1 setBackgroundImage:[UIImage imageNamed:@"pin.png"] forState:UIControlStateNormal];
        self.espacio3D1.tag = 0;
        [self.espacio3D1 addTarget:self action:@selector(espacio3DButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.planoImageView addSubview:self.espacio3D1];
        
        //espacio3d1 label
        self.espacio3D1Label = [[UILabel alloc] init];
        self.espacio3D1Label.textColor = [UIColor whiteColor];
        self.espacio3D1Label.font = [UIFont boldSystemFontOfSize:13.0];
        [self.planoImageView addSubview:self.espacio3D1Label];
        
        //Area total label
        self.areaTotalLabel = [[UILabel alloc] init];
        self.areaTotalLabel.textAlignment = NSTextAlignmentCenter;
        self.areaTotalLabel.textColor = [UIColor whiteColor];
        self.areaTotalLabel.font = [UIFont boldSystemFontOfSize:20.0];
        [self.contentView addSubview:self.areaTotalLabel];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    self.planoImageView.frame = CGRectMake(20.0, -10.0, contentRect.size.width - 40.0, contentRect.size.height - 60);
    self.brujulaButton.frame = CGRectMake(self.planoImageView.frame.size.width - 100.0, 10.0, 80.0, 80.0);
    self.areaTotalLabel.frame = CGRectMake(contentRect.size.width/2.0 - 150.0, self.planoImageView.frame.origin.y + self.planoImageView.frame.size.height, 300.0, 44.0);
}

#pragma mark - Actions 

-(void)espacio3DButtonTapped:(UIButton *)sender {
    NSLog(@"seleccioné un espacio");
    [self.delegate espacio3DButtonWasSelectedWithTag:sender.tag inCell:self];
}

@end
