//
//  PlanosDePlantaViewController.m
//  Ekoobot 3D
//
//  Created by Developer on 6/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "PlanosDePlantaViewController.h"
#import "PlanosCollectionViewCell.h"
#import "GLKitSpaceViewController.h"
#import "MBProgressHud.h"

@interface PlanosDePlantaViewController () <UICollectionViewDataSource, UICollectionViewDelegate, PlanoCollectionViewCellDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (assign, nonatomic) NSUInteger numeroDePlanta;
@property (assign, nonatomic) NSUInteger numeroDeEspacio3D;
@end

@implementation PlanosDePlantaViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Título";
    self.view.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self setupUI];
}

-(void)setupUI {
    CGRect screenFrame = CGRectMake(0.0, 0.0, 1024.0, 768.0);
    
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewFlowLayout.itemSize = CGSizeMake(screenFrame.size.width, 650.0);
    collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, screenFrame.size.width, 670.0) collectionViewLayout:collectionViewFlowLayout];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    self.collectionView.pagingEnabled = YES;
    [self.collectionView registerClass:[PlanosCollectionViewCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
    [self.view addSubview:self.collectionView];
}

#pragma mark - UICollectionViewDataSource 

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.producto.arrayPlantas count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PlanosCollectionViewCell *cell = (PlanosCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    cell.delegate = self;
    Planta *planta = self.producto.arrayPlantas[indexPath.item];
    NSArray *espacios3DArray = planta.arrayEspacios3D;
    Espacio3D *espacio3D1 = espacios3DArray[0];
    
    cell.espacio3D1.frame = CGRectMake([espacio3D1.coordenadaX floatValue], [espacio3D1.coordenadaY floatValue] - 30.0, 30.0, 30.0);
    cell.espacio3D1Label.text = espacio3D1.nombre;
    cell.espacio3D1Label.frame = CGRectMake(cell.espacio3D1.frame.origin.x + cell.espacio3D1.frame.size.width, cell.espacio3D1.frame.origin.y, 100.0, 30.0);
    cell.planoImageView.image = [self imageFromPlantaAtIndex:indexPath.item];
    
    NSString *replacedMt=[self.producto.area stringByReplacingOccurrencesOfString:@"mt2" withString:@"mt\u00B2"];
    cell.areaTotalLabel.text = [NSString stringWithFormat:@"Área total: %@", replacedMt];
    return cell;
}

#pragma mark - Custom Methods

-(UIImage *)imageFromPlantaAtIndex:(NSUInteger)index {
    Planta *planta = self.producto.arrayPlantas[index];
    
    //Access the image path at the documents directory
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/planta%@.jpeg",docDir,planta.idPlanta];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    
    if (!fileExists) {
        //The image doesnt exist
        NSLog(@"no existe planta img %@",jpegFilePath);
        NSString *string=[planta.imagenPlanta stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        NSURL *urlImagen=[NSURL URLWithString:string];
        NSLog(@"url %@",urlImagen);
        
        NSData *data=[NSData dataWithContentsOfURL:urlImagen];
        UIImage *plantaImage = [UIImage imageWithData:data];
        NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(plantaImage, 1.0f)];//1.0f = 100% quality
        if (plantaImage) {
            [data2 writeToFile:jpegFilePath atomically:YES];
        }
        return plantaImage;
    }
    else {
        //The image exist
        NSLog(@"si existe planta img %@",jpegFilePath);
        UIImage *plantaImage = [UIImage imageWithContentsOfFile:jpegFilePath];
        return plantaImage;
    }
}

-(void)goToGLKitView {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    Planta *planta = self.producto.arrayPlantas[self.numeroDePlanta];
    NSMutableArray *espacios3DArray = planta.arrayEspacios3D;
    
    GLKitSpaceViewController *glkitSpaceVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GLKitSpace"];
    glkitSpaceVC.espacioSeleccionado = self.numeroDeEspacio3D;
    glkitSpaceVC.arregloDeEspacios3D = espacios3DArray;
    
    [self.navigationController pushViewController:glkitSpaceVC animated:YES];
}

#pragma mark - PlanosCollectionViewCellDelegate

-(void)espacio3DButtonWasSelectedWithTag:(NSUInteger)tag inCell:(PlanosCollectionViewCell *)cell {
    NSLog(@"recibí la info del delegate");
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSLog(@"indexpath de la celda: %d", indexPath.item);
    
    self.numeroDePlanta = indexPath.item;
    self.numeroDeEspacio3D = tag;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self performSelector:@selector(goToGLKitView) withObject:nil afterDelay:0.3];
}

@end
