//
//  PlanosDePlantaViewController.m
//  Ekoobot 3D
//
//  Created by Developer on 6/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "PlanosDePlantaViewController.h"
#import "PlanosCollectionViewCell.h"

@interface PlanosDePlantaViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@end

@implementation PlanosDePlantaViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Título";
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self setupUI];
}

-(void)setupUI {
    CGRect screenFrame = CGRectMake(0.0, 0.0, 1024.0, 768.0);
    
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewFlowLayout.itemSize = CGSizeMake(screenFrame.size.width - 20.0, 500.0);
    collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, screenFrame.size.width, 600.0) collectionViewLayout:collectionViewFlowLayout];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor cyanColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
    [self.collectionView registerClass:[PlanosCollectionViewCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
    [self.view addSubview:self.collectionView];
}

#pragma mark - UICollectionViewDataSource 

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    return cell;
}

@end
