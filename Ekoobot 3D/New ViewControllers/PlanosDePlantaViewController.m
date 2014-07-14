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
#import "BrujulaViewController.h"
#import "Plant+AddOns.h"
#import "Product.h"
#import "Space.h"
#import "CMMotionManager+Shared.h"

@interface PlanosDePlantaViewController () <UICollectionViewDataSource, UICollectionViewDelegate, PlanoCollectionViewCellDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (assign, nonatomic) NSUInteger numeroDePlanta;
@property (assign, nonatomic) NSUInteger numeroDeEspacio3D;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSMutableArray *nombresPlantasArray;
@property (strong, nonatomic) NSMutableArray *plantsArray;
@property (strong, nonatomic) NSArray *spacesArray;
@property (strong, nonatomic) NSMutableArray *plantsPinsArray;
@property (strong, nonatomic) PlanosCollectionViewCell *cell;
@property (strong, nonatomic) PlanosCollectionViewCell *previousCell;
@property (strong, nonatomic) NSIndexPath *previousCellIndexPath;
@property (strong, nonatomic) NSMutableArray *plantImagesArray;
@end

@implementation PlanosDePlantaViewController {
    CGRect screenBounds;
    NSUInteger theTag;
    BOOL magnetometerIsAvailable;
}

#pragma mark - Lazy Instantiation

-(NSMutableArray *)plantImagesArray {
    if (!_plantImagesArray) {
        _plantImagesArray = [[NSMutableArray alloc] init];
        NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSUInteger plantsCount = [self.projectDic[@"plants"] count];
        for (int i = 0; i < plantsCount; i++) {
            Plant *plant = self.projectDic[@"plants"][i];
            NSString *imageDir = [docDir stringByAppendingPathComponent:plant.imagePath];
            UIImage *plantImage = [UIImage imageWithContentsOfFile:imageDir];
            [_plantImagesArray addObject:plantImage];
        }
    }
    return _plantImagesArray;

}

-(NSMutableArray *)plantsPinsArray {
    if (!_plantsPinsArray) {
        _plantsPinsArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.plantsArray count]; i++) {
            Plant *plant = self.plantsArray[i];
            NSMutableArray *pinsArrayForPlant = [[NSMutableArray alloc] init];
            
            for (int j = 0; j < [self.spacesArray count]; j++) {
                Space *space = self.spacesArray[j];
                if ([space.plant isEqualToString:plant.identifier]) {
                    NSLog(@"Agregué un pin a la planta en el index %i", i);
                    [pinsArrayForPlant addObject:space];
                }
            }
            NSLog(@"el numero de pines en la planta %i es %i", i, [pinsArrayForPlant count]);
            [_plantsPinsArray addObject:pinsArrayForPlant];
        }
    }
    return _plantsPinsArray;
}

-(NSArray *)spacesArray {
    if (!_spacesArray) {
        _spacesArray = self.projectDic[@"spaces"];
    }
    return _spacesArray;
}

-(NSMutableArray *)plantsArray {
    if (!_plantsArray) {
        _plantsArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.projectDic[@"plants"] count]; i++) {
            Plant *plant = self.projectDic[@"plants"][i];
            if ([plant.product isEqualToString:self.product.identifier]) {
                [_plantsArray addObject:plant];
            }
        }
    }
    return _plantsArray;
}

-(NSMutableArray *)nombresPlantasArray {
    if (!_nombresPlantasArray) {
        _nombresPlantasArray = [[NSMutableArray alloc] initWithCapacity:[self.plantsArray count]];
        for (int i = 0; i < [self.plantsArray count]; i++) {
            Plant *plant = self.plantsArray[i];
            [_nombresPlantasArray addObject:plant.name];
        }
    }
    return _nombresPlantasArray;
}

/*-(void)initializePlantImagesArray {
    self.plantImagesArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.plantsArray count]; i++) {
        Plant *plant = self.plantsArray[i];
        [self.plantImagesArray addObject:[plant plantImage]];
    }
}*/

#pragma mark View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    //[self initializePlantImagesArray];
    self.automaticallyAdjustsScrollViewInsets = NO;
    CGRect screen = [UIScreen mainScreen].bounds;
    screenBounds = CGRectMake(0.0, 0.0, screen.size.height, screen.size.width);
    self.view.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
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

-(void)viewDidDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    PlanosCollectionViewCell *cell = (PlanosCollectionViewCell *)[[self.collectionView visibleCells] firstObject];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    [cell setEspacios3DButtonsFromArray:self.plantsPinsArray[indexPath.item]];
}

-(void)setupUI {
    CGRect screenFrame = screenBounds;
    //Setup CollectionView
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    //collectionViewFlowLayout.itemSize = CGSizeMake(screenFrame.size.width, screenFrame.size.height/1.1815);
    collectionViewFlowLayout.itemSize = CGSizeMake(screenFrame.size.width, screenBounds.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height));
    collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectionViewFlowLayout.minimumInteritemSpacing = 0;
    collectionViewFlowLayout.minimumLineSpacing = 0;
    //self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, screenFrame.size.width, collectionViewFlowLayout.itemSize.height + 20.0) collectionViewLayout:collectionViewFlowLayout];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, screenFrame.size.width, screenBounds.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height)) collectionViewLayout:collectionViewFlowLayout];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    self.collectionView.pagingEnabled = YES;
    [self.collectionView registerClass:[PlanosCollectionViewCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
    [self.view addSubview:self.collectionView];
    
    //Setup PageControl
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = [self.plantsArray count];
    [self.view addSubview:self.pageControl];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
         self.pageControl.frame = CGRectMake(self.view.bounds.size.width/2.0 - 150.0, self.collectionView.frame.origin.y + self.collectionView.frame.size.height, 300.0, 30.0);
    } else {
        self.pageControl.frame = CGRectMake(self.view.bounds.size.width/2.0 - 150.0, self.view.bounds.size.height - 30.0, 300.0, 30.0);
    }
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.plantsArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PlanosCollectionViewCell *cell = (PlanosCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    cell.delegate = self;
    //Plant *plant = self.plantsArray[indexPath.item];
    //cell.planoImageView.image = [plant plantImage];
    cell.planoImageView.image = self.plantImagesArray[indexPath.item];
    cell.showCompass = magnetometerIsAvailable;
    //[cell removeAllPinsFromArray:self.plantsPinsArray[indexPath.item]];
    //[cell setEspacios3DButtonsFromArray:self.plantsPinsArray[indexPath.item]];
    
    /*NSMutableArray *pinsArrayForPlant = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.spacesArray count]; i++) {
        Space *space = self.spacesArray[i];
        if ([space.plant isEqualToString:plant.identifier]) {
            NSLog(@"Agregaré un pin a la planta en el index %d", indexPath.item);
            [pinsArrayForPlant addObject:space];
        }
    }
    
    [cell removeAllPinsFromArray:pinsArrayForPlant];
    [cell setEspacios3DButtonsFromArray:pinsArrayForPlant];*/
    
    
    NSString *replacedMt=[self.product.area stringByReplacingOccurrencesOfString:@"mt2" withString:@"mt\u00B2"];
    NSString *areatTotalString = NSLocalizedString(@"AreaTotal", nil);
    cell.areaTotalLabel.text = [areatTotalString stringByAppendingString:replacedMt];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    ((PlanosCollectionViewCell *)cell).zoomScale = 1.0;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"Terminé de acelerarmeeeee");
    [self performSelector:@selector(showPinsForNewDisplayedCell) withObject:nil afterDelay:0.1];
    /*if (currentCellIndexPath.item != self.previousCellIndexPath.item) {
        //The user change to other cell
        //[self.previousCell removeAllPinsFromArray:self.plantsPinsArray[self.previousCellIndexPath.item]];
        [currentCell setEspacios3DButtonsFromArray:self.plantsPinsArray[currentCellIndexPath.item]];
    }*/
}

-(void)showPinsForNewDisplayedCell {
    PlanosCollectionViewCell *currentCell = [[self.collectionView visibleCells] firstObject];
    NSIndexPath *currentCellIndexPath = [self.collectionView indexPathForCell:currentCell];
    [currentCell setEspacios3DButtonsFromArray:self.plantsPinsArray[currentCellIndexPath.item]];
    NSLog(@"Celda Anterior: %d, celda actual: %d", self.previousCellIndexPath.item ,currentCellIndexPath.item);
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"Dragiingggggggg");
    if ([[self.collectionView visibleCells] count] == 1) {
        self.previousCell = (PlanosCollectionViewCell *)[[self.collectionView visibleCells] firstObject];
        self.previousCellIndexPath = [self.collectionView indexPathForCell:self.previousCell];
        [self.previousCell removeAllPinsFromArray:self.plantsPinsArray[self.previousCellIndexPath.item]];
        //NSLog(@"****************** index path: %d", self.previousCellIndexPath.item);
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"Terminé de dragearmeeeee");
    if (decelerate) {
        NSLog(@"Entraré al end descelerating");
    } else {
        NSLog(@"No entraré al descelerating");
        [self performSelector:@selector(showPinsWhenDesceleratingIsNo) withObject:nil afterDelay:0.2];
    }
}

-(void)showPinsWhenDesceleratingIsNo {
    [self.previousCell setEspacios3DButtonsFromArray:self.plantsPinsArray[self.previousCellIndexPath.item]];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"Entré al end scrolliiiinnnggg");
}

#pragma mark - Custom Methods

-(void)goToGLKitView {
    /*[MBProgressHUD hideHUDForView:self.view animated:YES];
    
    Planta *planta = self.producto.arrayPlantas[self.numeroDePlanta];
    NSMutableArray *espacios3DArray = planta.arrayEspacios3D;
    
    GLKitSpaceViewController *glkitSpaceVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GLKitSpace"];
    glkitSpaceVC.espacioSeleccionado = self.numeroDeEspacio3D;
    glkitSpaceVC.arregloDeEspacios3D = espacios3DArray;
    
    [self.navigationController pushViewController:glkitSpaceVC animated:YES];*/
    
    self.numeroDeEspacio3D = theTag;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:self.cell];
    Plant *plant = self.plantsArray[indexPath.item];
    NSMutableArray *spacesArrayForPlant = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.spacesArray count]; i++) {
         Space *space = self.spacesArray[i];
         if ([space.plant isEqualToString:plant.identifier]) {
             [spacesArrayForPlant addObject:space];
         }
    }
    NSLog(@"número de espacios en esta planta: %d", [spacesArrayForPlant count]);
    GLKitSpaceViewController *glkitSpaceVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GLKitSpace"];
    glkitSpaceVC.espacioSeleccionado = self.numeroDeEspacio3D;
    glkitSpaceVC.arregloDeEspacios3D = spacesArrayForPlant;
    glkitSpaceVC.projectDic = self.projectDic;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.navigationController pushViewController:glkitSpaceVC animated:YES];
}

-(void)goToBrujulaVCForFloorAtIndex:(NSUInteger)index {
    Plant *plant = self.plantsArray[index];
    
    BrujulaViewController *brujulaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Brujula"];
    UIImageView *floorImageView = [[UIImageView alloc] initWithImage:self.plantImagesArray[index]];
    brujulaVC.externalImageView = floorImageView;
    brujulaVC.gradosExtra = [plant.northDegs floatValue];
    [self.navigationController.view.layer addAnimation:[NavAnimations navAlphaAnimation] forKey:nil];
    [self.navigationController pushViewController:brujulaVC animated:NO];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.collectionView.frame.size.width;
    self.pageControl.currentPage = round(self.collectionView.contentOffset.x / pageWidth);
    self.navigationItem.title = self.nombresPlantasArray[self.pageControl.currentPage];
}

#pragma mark - PlanosCollectionViewCellDelegate

-(void)brujulaButtonWasTappedInCell:(PlanosCollectionViewCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSLog(@"burjula button tapped in cell: %d", indexPath.item);
    [self goToBrujulaVCForFloorAtIndex:indexPath.item];
}

-(void)espacio3DButtonWasSelectedWithTag:(NSUInteger)tag inCell:(PlanosCollectionViewCell *)cell {
    /*NSLog(@"recibí la info del delegate");
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSLog(@"indexpath de la celda: %d", indexPath.item);
    
    self.numeroDePlanta = indexPath.item;
    self.numeroDeEspacio3D = tag;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self performSelector:@selector(goToGLKitView) withObject:nil afterDelay:0.3];*/
    theTag = tag;
    self.cell = cell;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self performSelector:@selector(goToGLKitView) withObject:nil afterDelay:0.1];
    
    /*self.numeroDeEspacio3D = tag;
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    Plant *plant = self.plantsArray[indexPath.item];
    NSMutableArray *spacesArrayForPlant = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.spacesArray count]; i++) {
        Space *space = self.spacesArray[i];
        if ([space.plant isEqualToString:plant.identifier]) {
            [spacesArrayForPlant addObject:space];
        }
    }
    NSLog(@"número de espacios en esta planta: %d", [spacesArrayForPlant count]);
    GLKitSpaceViewController *glkitSpaceVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GLKitSpace"];
    glkitSpaceVC.espacioSeleccionado = self.numeroDeEspacio3D;
    glkitSpaceVC.arregloDeEspacios3D = spacesArrayForPlant;
    glkitSpaceVC.projectDic = self.projectDic;
    [self.navigationController pushViewController:glkitSpaceVC animated:YES];*/
}

@end
