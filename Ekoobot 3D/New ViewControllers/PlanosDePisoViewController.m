//
//  PlanosDePisoViewController.m
//  Ekoobot 3D
//
//  Created by Developer on 9/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "PlanosDePisoViewController.h"
#import "PisoCollectionViewCell.h"
#import "MBProgressHud.h"
#import "PlanosDePlantaViewController.h"
#import "GLKitSpaceViewController.h"
#import "NavAnimations.h"
#import "BrujulaViewController.h"

@interface PlanosDePisoViewController () <UICollectionViewDataSource, UICollectionViewDelegate, PisoCollectionViewCellDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *arrayNombresPiso;
@property (strong, nonatomic) UIPageControl *pageControl;
@end

@implementation PlanosDePisoViewController

#pragma mark - Lazy Instantiation 

-(NSMutableArray *)arrayNombresPiso {
    if (!_arrayNombresPiso) {
        _arrayNombresPiso = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.grupo.arrayTiposDePiso count]; i++) {
            TipoDePiso *tipoDePiso = self.grupo.arrayTiposDePiso[i];
            [_arrayNombresPiso addObject:tipoDePiso.nombre];
        }
    }
    return _arrayNombresPiso;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    self.navigationItem.title = self.arrayNombresPiso[0];
    [self setupUI];
}

-(void)setupUI {
    CGRect screenFrame = CGRectMake(0.0, 0.0, 1024.0, 768.0);
    
    //CollectioView Setup
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectionViewFlowLayout.itemSize = CGSizeMake(screenFrame.size.width, 600.0);
    collectionViewFlowLayout.minimumInteritemSpacing = 0;
    collectionViewFlowLayout.minimumInteritemSpacing = 0;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, 64.0, screenFrame.size.width, screenFrame.size.height - 64.0 - 50.0) collectionViewLayout:collectionViewFlowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[PisoCollectionViewCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
    [self.view addSubview:self.collectionView];
    
    //PageControl Setup
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = [self.grupo.arrayTiposDePiso count];
    [self.view addSubview:self.pageControl];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.pageControl.frame = CGRectMake(self.view.bounds.size.width/2.0 - 150.0, self.view.bounds.size.height - 40.0, 300.0, 30.0);
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.grupo.arrayTiposDePiso count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PisoCollectionViewCell *cell = (PisoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    cell.delegate = self;
    TipoDePiso *tipoDePiso = self.grupo.arrayTiposDePiso[indexPath.row];
    [cell removeAllPinsFromArray:tipoDePiso.arrayProductos];
    [cell setPinsButtonsFromArray:tipoDePiso.arrayProductos];
    cell.pisoImageView.image = [self imageFromPisoAtIndex:indexPath.item];
    return cell;
}

#pragma mark - Custom Methods

-(UIImage *)imageFromPisoAtIndex:(NSUInteger)index {
    TipoDePiso *tipoDePiso = self.grupo.arrayTiposDePiso[index];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/tipoDePiso%@.jpeg",docDir,tipoDePiso.idTipoPiso];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    if (!fileExists) {
        //NSLog(@"no existe tipo piso img %@",jpegFilePath);
        NSURL *urlImagen=[NSURL URLWithString:tipoDePiso.imagen];
        NSData *data=[NSData dataWithContentsOfURL:urlImagen];
        UIImage *image = [UIImage imageWithData:data];
        NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
        if (image) {
            [data2 writeToFile:jpegFilePath atomically:YES];
        }
        return image;
    }
    else {
        //NSLog(@"si existe tipo piso img %@",jpegFilePath);
        UIImage *image = [UIImage imageWithContentsOfFile:jpegFilePath];
        return image;
    }
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.collectionView.frame.size.width;
    self.pageControl.currentPage = round(self.collectionView.contentOffset.x / pageWidth);
    self.navigationItem.title = self.arrayNombresPiso[self.pageControl.currentPage];
}

#pragma mark - PisoCollectionViewCellDelegate

-(void)brujulaButtonTappedInCell:(PisoCollectionViewCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    TipoDePiso *tipoDePiso = self.grupo.arrayTiposDePiso[indexPath.item];
    
    [self.navigationController.view.layer addAnimation:[NavAnimations navAlphaAnimation] forKey:nil];
    BrujulaViewController *brujulaVC=[[BrujulaViewController alloc]init];
    brujulaVC=[self.storyboard instantiateViewControllerWithIdentifier:@"Brujula"];
    brujulaVC.externalImageView = [[UIImageView alloc] initWithImage:[self imageFromPisoAtIndex:indexPath.item]];
    brujulaVC.gradosExtra = [tipoDePiso.norte floatValue];
    [self.navigationController pushViewController:brujulaVC animated:NO];
}

-(void)pinButtonWasSelectedWithIndex:(NSUInteger)index inCell:(PisoCollectionViewCell *)cell {
    NSLog(@"toqué el pin en la posición: %d", index);
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    TipoDePiso *tipoDePiso = self.grupo.arrayTiposDePiso[indexPath.item];
    Producto *producto = tipoDePiso.arrayProductos[index - 1];
    
    if (producto.existe) {
        PlanosDePlantaViewController *planosDePlantaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PlanosDePlanta"];
        planosDePlantaVC.producto = producto;
        [self.navigationController pushViewController:planosDePlantaVC animated:YES];
    } else {
        GLKitSpaceViewController *glKitSpaceVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GLKitSpace"];
        
        Planta *planta = producto.arrayPlantas[0];
        glKitSpaceVC.arregloDeEspacios3D = planta.arrayEspacios3D;
        glKitSpaceVC.espacioSeleccionado = index - 1;
        [self .navigationController pushViewController:glKitSpaceVC animated:YES];
    }
}

@end
