//
//  AcabadosView.m
//  Ekoobot 3D
//
//  Created by Developer on 13/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "AcabadosView.h"
#import "AcabadosCollectionViewCell.h"

@interface AcabadosView() <UICollectionViewDataSource, UICollectionViewDelegate>
@end

@implementation AcabadosView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.layer.borderColor = [UIColor colorWithWhite:0.4 alpha:1.0].CGColor;
        self.layer.borderWidth = 1.0;
        
        //TitleLabel
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, 50.0)];
        titleLabel.text = @"Acabados";
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        titleLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self addSubview:titleLabel];
        
        //Acabados Collection view
        UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        collectionViewFlowLayout.itemSize = CGSizeMake(frame.size.width, frame.size.width/3.0 + 20.0);
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, titleLabel.frame.origin.y + titleLabel.frame.size.height, frame.size.width, frame.size.height - (titleLabel.frame.origin.y + titleLabel.frame.size.height)) collectionViewLayout:collectionViewFlowLayout];
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.alwaysBounceVertical = YES;
        collectionView.contentInset = UIEdgeInsetsMake(20.0, 40.0, 0.0, 40.0);
        [collectionView registerClass:[AcabadosCollectionViewCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
        collectionView.backgroundColor = [UIColor clearColor];
        [self addSubview:collectionView];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AcabadosCollectionViewCell *cell = (AcabadosCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:@"Wood.jpg"];
    cell.nameLabel.text = @"marmooool";
    return cell;
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate AcabadoWasSelectedAtIndex:indexPath.item];
}

@end
