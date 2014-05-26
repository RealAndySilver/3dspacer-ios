//
//  More3DScenesView.m
//  Ekoobot 3D
//
//  Created by Developer on 5/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "More3DScenesView.h"
#import "More3DScenesCollectionViewCell.h"
#import "Space.h"

@interface More3DScenesView() <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@end

@implementation More3DScenesView

#pragma mark - Setters

-(void)setNumberOfScenes:(NSUInteger)numberOfScenes {
    _numberOfScenes = numberOfScenes;
    [self.collectionView reloadData];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        //Title label
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, 30.0)];
        self.titleLabel.font = [UIFont systemFontOfSize:17.0];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
        
        //CollectionView Setup
        UICollectionViewFlowLayout *collectionViewFLowLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionViewFLowLayout.itemSize = CGSizeMake(120.0, 120.0);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            collectionViewFLowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        } else {
            collectionViewFLowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        }
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, 40.0, frame.size.width, frame.size.height - 60.0) collectionViewLayout:collectionViewFLowLayout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 20.0, 0.0, 0.0);
        [self.collectionView registerClass:[More3DScenesCollectionViewCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
        self.collectionView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.collectionView];
    }
    return self;
}

#pragma mark - CollectionViewDataSource 

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.espacios3DArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    More3DScenesCollectionViewCell *cell = (More3DScenesCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    //Espacio3D *espacio3D = self.espacios3DArray[indexPath.item];
    //Caras *caras = espacio3D.arrayCaras[0];
    //cell.sceneImageView.image = [UIImage imageWithContentsOfFile:[self pathForJPEGResourceWithName:@"Atras" ID:caras.idAtras]];
    Space *space = self.espacios3DArray[indexPath.item];
    cell.sceneNameLabel.text = space.name;
    return cell;
}

#pragma mark - CollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate sceneWasSelectedAtIndex:indexPath.item inView:self];
}

-(NSString*)pathForJPEGResourceWithName:(NSString*)name ID:(NSString*)ID{
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/cara%@%@.jpeg",docDir,name,ID];
    return jpegFilePath;
}

@end
