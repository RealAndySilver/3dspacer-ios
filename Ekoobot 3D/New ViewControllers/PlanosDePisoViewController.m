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
#import "Floor+AddOns.h"
#import "Product.h"
#import "Plant.h"
#import "Group.h"
#import "Space.h"
#import "CMMotionManager+Shared.h"

@interface PlanosDePisoViewController () <UICollectionViewDataSource, UICollectionViewDelegate, PisoCollectionViewCellDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *arrayNombresPiso;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSMutableArray *floorsArray;
@property (strong, nonatomic) NSArray *productsArray;
@end

@implementation PlanosDePisoViewController {
    CGRect screenBounds;
    BOOL magnetometerIsAvailable;
}

#pragma mark - Lazy Instantiation 

-(NSArray *)productsArray {
    if (!_productsArray) {
        _productsArray = self.projectDic[@"products"];
    }
    return _productsArray;
}

-(NSMutableArray *)floorsArray {
    if (!_floorsArray) {
        _floorsArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.projectDic[@"floors"] count]; i++) {
            Floor *floor = self.projectDic[@"floors"][i];
            if ([floor.group isEqualToString:self.group.identifier]) {
                [_floorsArray addObject:floor];
            }
        }
    }
    return _floorsArray;
}

-(NSMutableArray *)arrayNombresPiso {
    /*if (!_arrayNombresPiso) {
        _arrayNombresPiso = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.grupo.arrayTiposDePiso count]; i++) {
            TipoDePiso *tipoDePiso = self.grupo.arrayTiposDePiso[i];
            [_arrayNombresPiso addObject:tipoDePiso.nombre];
        }
    }
    return _arrayNombresPiso;*/
    
    if (!_arrayNombresPiso) {
        _arrayNombresPiso = [[NSMutableArray alloc] initWithCapacity:[self.floorsArray count]];
        for (int i = 0; i < [self.floorsArray count]; i++) {
            Floor *floor = self.floorsArray[i];
            [_arrayNombresPiso addObject:floor.name];
        }
    }
    return _arrayNombresPiso;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    CGRect screen = [UIScreen mainScreen].bounds;
    screenBounds = CGRectMake(0.0, 0.0, screen.size.height, screen.size.width);
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    self.navigationItem.title = self.arrayNombresPiso[0];
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CMMotionManager *motionManager = [CMMotionManager sharedMotionManager];
    if (motionManager.magnetometerAvailable) {
        magnetometerIsAvailable = YES;
    } else {
        magnetometerIsAvailable = NO;
    }
}

-(void)setupUI {
    
    CGRect screenFrame = screenBounds;
    
    //CollectioView Setup
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectionViewFlowLayout.itemSize = CGSizeMake(screenFrame.size.width, screenFrame.size.height/1.28);
    collectionViewFlowLayout.minimumInteritemSpacing = 0;
    collectionViewFlowLayout.minimumLineSpacing = 0;
    
    CGRect collectionViewFrame;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        collectionViewFrame = CGRectMake(0.0, 64.0, screenFrame.size.width, screenFrame.size.height - 64.0 - 50.0);
    } else {
        collectionViewFrame = CGRectMake(0.0, 10.0, screenFrame.size.width, screenFrame.size.height - 20.0);
    }
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:collectionViewFlowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    [self.collectionView registerClass:[PisoCollectionViewCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
    [self.view addSubview:self.collectionView];
    
    //PageControl Setup
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = [self.floorsArray count];
    //self.pageControl.numberOfPages = [self.grupo.arrayTiposDePiso count];
    [self.view addSubview:self.pageControl];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.pageControl.frame = CGRectMake(self.view.bounds.size.width/2.0 - 150.0, self.view.bounds.size.height - 45.0, 300.0, 30.0);
    } else {
        self.pageControl.frame = CGRectMake(self.view.bounds.size.width/2.0 - 150.0, self.view.bounds.size.height - 25.0, 300.0, 30.0);
    }
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.floorsArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PisoCollectionViewCell *cell = (PisoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    cell.delegate = self;
    Floor *floor = self.floorsArray[indexPath.item];
    cell.pisoImageView.image = [floor floorImage];
    cell.showCompass = magnetometerIsAvailable;
    
    NSMutableArray *pinsArrayForFloor = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.productsArray count]; i++) {
        Product *product = self.productsArray[i];
        if ([product.floor isEqualToString:floor.identifier]) {
            [pinsArrayForFloor addObject:product];
        }
    }
    
    [cell removeAllPinsFromArray:pinsArrayForFloor];
    [cell setPinsButtonsFromArray:pinsArrayForFloor];
    
    return cell;
}

#pragma mark - Custom Methods

/*-(UIImage *)imageFromPisoAtIndex:(NSUInteger)index {
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
}*/

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.collectionView.frame.size.width;
    self.pageControl.currentPage = round(self.collectionView.contentOffset.x / pageWidth);
    self.navigationItem.title = self.arrayNombresPiso[self.pageControl.currentPage];
}

#pragma mark - PisoCollectionViewCellDelegate

-(void)brujulaButtonTappedInCell:(PisoCollectionViewCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    //TipoDePiso *tipoDePiso = self.grupo.arrayTiposDePiso[indexPath.item];
    Floor *floor = self.floorsArray[indexPath.item];
    
    [self.navigationController.view.layer addAnimation:[NavAnimations navAlphaAnimation] forKey:nil];
    BrujulaViewController *brujulaVC=[[BrujulaViewController alloc]init];
    brujulaVC=[self.storyboard instantiateViewControllerWithIdentifier:@"Brujula"];
    brujulaVC.externalImageView = [[UIImageView alloc] initWithImage:[floor floorImage]];
    brujulaVC.gradosExtra = [floor.northDegrees floatValue];
    [self.navigationController pushViewController:brujulaVC animated:NO];
}

-(void)pinButtonWasSelectedWithIndex:(NSUInteger)index inCell:(PisoCollectionViewCell *)cell {
    NSLog(@"toqué el pin en la posición: %d", index);
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    //TipoDePiso *tipoDePiso = self.grupo.arrayTiposDePiso[indexPath.item];
    //Producto *producto = tipoDePiso.arrayProductos[index - 1];
    
    Floor *floor = self.floorsArray[indexPath.item];
    NSMutableArray *productsArrayForFloor = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.productsArray count]; i++) {
        Product *product = self.productsArray[i];
        if ([product.floor isEqualToString:floor.identifier]) {
            [productsArrayForFloor addObject:product];
        }
    }
    Product *product = productsArrayForFloor[index - 1];
    
    if ([product.enabled boolValue]) {
        PlanosDePlantaViewController *planosDePlantaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PlanosDePlanta"];
        planosDePlantaVC.projectDic = self.projectDic;
        planosDePlantaVC.product = product;
        [self.navigationController pushViewController:planosDePlantaVC animated:YES];
    
    } else {
        //Get the first plant of the product
        Plant *plant;
        for (int i = 0; i < [self.projectDic[@"plants"] count]; i++) {
            plant = self.projectDic[@"plants"][i];
            if ([plant.product isEqualToString:product.identifier]) {
                break;
            }
        }
        
        //Get the spaces array for the plant
        NSMutableArray *spacesArrayForPlant = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.projectDic[@"spaces"] count]; i++) {
            Space *space = self.projectDic[@"spaces"][i];
            if ([space.plant isEqualToString:plant.identifier]) {
                [spacesArrayForPlant addObject:space];
            }
        }
        GLKitSpaceViewController *glKitSpaceVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GLKitSpace"];
        glKitSpaceVC.arregloDeEspacios3D = spacesArrayForPlant;
        glKitSpaceVC.projectDic = self.projectDic;
        glKitSpaceVC.espacioSeleccionado = index - 1;
        [self .navigationController pushViewController:glKitSpaceVC animated:YES];
    }
    
    /*if (producto.existe) {
        PlanosDePlantaViewController *planosDePlantaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PlanosDePlanta"];
        planosDePlantaVC.producto = producto;
        [self.navigationController pushViewController:planosDePlantaVC animated:YES];
    } else {
        GLKitSpaceViewController *glKitSpaceVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GLKitSpace"];
        
        Planta *planta = producto.arrayPlantas[0];
        glKitSpaceVC.arregloDeEspacios3D = planta.arrayEspacios3D;
        glKitSpaceVC.espacioSeleccionado = index - 1;
        [self .navigationController pushViewController:glKitSpaceVC animated:YES];
    }*/
}

@end
