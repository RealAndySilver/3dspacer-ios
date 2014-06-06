//
//  AcabadosView.m
//  Ekoobot 3D
//
//  Created by Developer on 13/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "AcabadosView.h"
#import "AcabadosCollectionViewCell.h"
#import "Finish+AddOns.h"

@interface AcabadosView() <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@end

@implementation AcabadosView

-(void)setFinishesArray:(NSArray *)finishesArray {
    _finishesArray = finishesArray;
    [self.collectionView reloadData];
}

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
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, titleLabel.frame.origin.y + titleLabel.frame.size.height, frame.size.width, frame.size.height - (titleLabel.frame.origin.y + titleLabel.frame.size.height)) collectionViewLayout:collectionViewFlowLayout];
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.alwaysBounceVertical = YES;
        self.collectionView.contentInset = UIEdgeInsetsMake(20.0, 40.0, 0.0, 40.0);
        [self.collectionView registerClass:[AcabadosCollectionViewCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
        self.collectionView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.collectionView];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.finishesArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AcabadosCollectionViewCell *cell = (AcabadosCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    //cell.imageView.image = [UIImage imageNamed:@"Wood.jpg"];
    //cell.nameLabel.text = @"marmol";
    Finish *finish = self.finishesArray[indexPath.item];
    cell.nameLabel.text = finish.name;
    cell.imageView.image = [finish finishIconImage];
    return cell;
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate AcabadoWasSelectedAtIndex:indexPath.item];
}

@end
