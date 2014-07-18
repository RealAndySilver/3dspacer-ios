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
#import "ServerCommunicator.h"
#import "Project.h"
#import "UserInfo.h"

@interface PlanosDePisoViewController () <UICollectionViewDataSource, UICollectionViewDelegate, PisoCollectionViewCellDelegate, ServerCommunicatorDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *arrayNombresPiso;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSMutableArray *floorsArray;
@property (strong, nonatomic) NSArray *productsArray;
@property (strong, nonatomic) NSDictionary *productAnalyticsDic;
@property (strong, nonatomic) PisoCollectionViewCell *previousCell;
@property (strong, nonatomic) NSIndexPath *previousCellIndexPath;
@property (strong, nonatomic) NSMutableArray *floorsPinsArray;
@property (strong, nonatomic) NSMutableArray *floorsImagesArray;
@end

@implementation PlanosDePisoViewController {
    CGRect screenBounds;
    BOOL magnetometerIsAvailable;
}

#pragma mark - Lazy Instantiation

-(NSMutableArray *)floorsImagesArray {
    if (!_floorsImagesArray) {
        _floorsImagesArray = [[NSMutableArray alloc] init];
        NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSUInteger floorsCount = [self.projectDic[@"floors"] count];
        for (int i = 0; i < floorsCount; i++) {
            Floor *floor = self.projectDic[@"floors"][i];
            NSString *imageDir = [docDir stringByAppendingPathComponent:floor.imagePath];
            UIImage *floorImage = [UIImage imageWithContentsOfFile:imageDir];
            [_floorsImagesArray addObject:floorImage];
        }
    }
    return _floorsImagesArray;
}

-(NSMutableArray *)floorsPinsArray {
    if (!_floorsPinsArray) {
        _floorsPinsArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.floorsArray count]; i++) {
            Floor *floor = self.floorsArray[i];
            NSMutableArray *pinsArrayForFloor = [[NSMutableArray alloc] init];
            
            for (int j = 0; j < [self.productsArray count]; j++) {
                Product *product = self.productsArray[j];
                if ([product.floor isEqualToString:floor.identifier]) {
                    NSLog(@"Agregué un pin a la planta en el index %i", i);
                    [pinsArrayForFloor addObject:product];
                }
            }
            NSLog(@"el numero de pines en el piso %i es %i", i, [pinsArrayForFloor count]);
            [_floorsPinsArray addObject:pinsArrayForFloor];
        }
    }
    return _floorsPinsArray;
}

-(NSArray *)productsArray {
    if (!_productsArray) {
        _productsArray = self.projectDic[@"products"];
    }
    return _productsArray;
}


-(NSMutableArray *)arrayNombresPiso {
    if (!_arrayNombresPiso) {
        _arrayNombresPiso = [[NSMutableArray alloc] initWithCapacity:[self.floorsArray count]];
        for (int i = 0; i < [self.floorsArray count]; i++) {
            Floor *floor = self.floorsArray[i];
            [_arrayNombresPiso addObject:floor.name];
        }
    }
    return _arrayNombresPiso;
}

-(void)initializeFloorsArray {
    self.floorsArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.projectDic[@"floors"] count]; i++) {
        Floor *floor = self.projectDic[@"floors"][i];
        if ([floor.group isEqualToString:self.group.identifier]) {
            [self.floorsArray addObject:floor];
        }
    }
}

/*-(void)initializeFloorImagesArray {
    self.floorsImagesArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.floorsArray count]; i++) {
        Floor *floor = self.floorsArray[i];
        [self.floorsImagesArray addObject:[floor floorImage]];
    }
}*/

-(void)viewDidLoad {
    [super viewDidLoad];
    [self initializeFloorsArray];
    self.automaticallyAdjustsScrollViewInsets = NO;
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

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    PisoCollectionViewCell *cell = (PisoCollectionViewCell *)[[self.collectionView visibleCells] firstObject];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    [cell setPinsButtonsFromArray:self.floorsPinsArray[indexPath.item]];
}

-(void)setupUI {
    
    CGRect screenFrame = screenBounds;
    
    //CollectioView Setup
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //collectionViewFlowLayout.itemSize = CGSizeMake(screenFrame.size.width, screenFrame.size.height/1.28);
    collectionViewFlowLayout.itemSize = CGSizeMake(screenFrame.size.width, screenFrame.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height));
    collectionViewFlowLayout.minimumInteritemSpacing = 0;
    collectionViewFlowLayout.minimumLineSpacing = 0;
    
    CGRect collectionViewFrame;
    /*if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        collectionViewFrame = CGRectMake(0.0, 64.0, screenFrame.size.width, screenFrame.size.height - 64.0 - 50.0);
    } else {
        collectionViewFrame = CGRectMake(0.0, 10.0, screenFrame.size.width, screenFrame.size.height - 20.0);
    }*/
    collectionViewFrame = CGRectMake(0.0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, screenFrame.size.width, screenFrame.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height));
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
        self.pageControl.frame = CGRectMake(self.view.bounds.size.width/2.0 - 150.0, self.view.bounds.size.height - 30.0, 300.0, 30.0);
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
    //Floor *floor = self.floorsArray[indexPath.item];
    //cell.pisoImageView.image = [floor floorImage];
    cell.pisoImageView.image = self.floorsImagesArray[indexPath.item];
    cell.showCompass = magnetometerIsAvailable;
    
    /*NSMutableArray *pinsArrayForFloor = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.productsArray count]; i++) {
        Product *product = self.productsArray[i];
        if ([product.floor isEqualToString:floor.identifier]) {
            [pinsArrayForFloor addObject:product];
        }
    }
    
    [cell removeAllPinsFromArray:pinsArrayForFloor];
    [cell setPinsButtonsFromArray:pinsArrayForFloor];*/
    
    return cell;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"Terminé de acelerarmeeeee");
    //Get a reference to the current cell
    [self performSelector:@selector(showPinsForNewDisplayedCell) withObject:nil afterDelay:0.1];
    /*if (currentCellIndexPath.item != self.previousCellIndexPath.item) {
        //The user change to other cell
        [self.previousCell removeAllPinsFromArray:self.floorsPinsArray[self.previousCellIndexPath.item]];
        [currentCell setPinsButtonsFromArray:self.floorsPinsArray[currentCellIndexPath.item]];
    }*/
}

-(void)showPinsForNewDisplayedCell {
    PisoCollectionViewCell *currentCell = [[self.collectionView visibleCells] firstObject];
    NSIndexPath *currentCellIndexPath = [self.collectionView indexPathForCell:currentCell];
    [currentCell setPinsButtonsFromArray:self.floorsPinsArray[currentCellIndexPath.item]];
    NSLog(@"Celda Anterior: %d, celda actual: %d", self.previousCellIndexPath.item ,currentCellIndexPath.item);
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([[self.collectionView visibleCells] count] == 1) {
        self.previousCell = (PisoCollectionViewCell *)[[self.collectionView visibleCells] firstObject];
        self.previousCellIndexPath = [self.collectionView indexPathForCell:self.previousCell];
        [self.previousCell removeAllPinsFromArray:self.floorsPinsArray[self.previousCellIndexPath.item]];
        NSLog(@"****************** index path: %d", self.previousCellIndexPath.item);
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
    [self.previousCell setPinsButtonsFromArray:self.floorsPinsArray[self.previousCellIndexPath.item]];
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    ((PisoCollectionViewCell *)cell).zoomScale = 1.0;
}

-(NSString *)generateProductJSONString {
    PisoCollectionViewCell *cell = [[self.collectionView visibleCells] firstObject];
    NSUInteger currentCellIndex = [self.collectionView indexPathForCell:cell].item;
    Floor *floor = self.floorsArray[currentCellIndex];
                    
    //Generate date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSDate *date = [NSDate date];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    NSDictionary *userDic = @{@"id": [UserInfo sharedInstance].userName};
    NSDictionary *productIDDic = @{@"id": floor.identifier};
    self.productAnalyticsDic = @{@"user": userDic, @"product" : productIDDic, @"date" : formattedDateString};
    
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if ([fileSaver getDictionary:@"ProductAnalyticsDic"][@"ProductAnalyticsArray"]) {
        NSMutableArray *productsAnalyticsArray = [NSMutableArray arrayWithArray:[fileSaver getDictionary:@"ProductAnalyticsDic"][@"ProductAnalyticsArray"]];
        [productsAnalyticsArray addObject:self.productAnalyticsDic];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:productsAnalyticsArray
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"Json String: %@", jsonString);
        return jsonString;
        
    } else {
        NSArray *projectArray = @[self.productAnalyticsDic];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:projectArray
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"Json String: %@", jsonString);
        return jsonString;
    }
}

#pragma mark - Server Stuff

-(void)sendAnalytics {
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *projectString = nil;
    NSString *productString = [self generateProductJSONString];
    NSString *parameter = [NSString stringWithFormat:@"projectAnalytics=%@&productAnalytics=%@", projectString, productString];
    [serverCommunicator callServerWithPOSTMethod:@"setAnalytics" andParameter:parameter httpMethod:@"POST"];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    if ([methodName isEqualToString:@"setAnalytics"]) {
        if (dictionary) {
            NSLog(@"Llegó respuesta correcta del analytics: %@", dictionary);
            //Remove the saved analytics in FileSaver
            FileSaver *fileSaver = [[FileSaver alloc] init];
            if ([fileSaver getDictionary:@"ProductAnalyticsDic"][@"ProductAnalyticsArray"]) {
                [fileSaver setDictionary:@{@"ProductAnalyticsArray": @[]} withName:@"ProductAnalyticsDic"];
            }
            
        } else {
            NSLog(@"No llegó respuesta del analytics: %@", dictionary);
        }
    }
}

-(void)serverError:(NSError *)error {
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if ([fileSaver getDictionary:@"ProductAnalyticsDic"][@"ProductAnalyticsArray"]) {
        NSLog(@"Ya existía el arreglo en file saver de productsAnalytics");
        NSMutableArray *productsAnalyticsArray = [NSMutableArray arrayWithArray:[fileSaver getDictionary:@"ProductAnalyticsDic"][@"ProductAnalyticsArray"]];
        [productsAnalyticsArray addObject:self.productAnalyticsDic];
        [fileSaver setDictionary:@{@"ProductAnalyticsArray": productsAnalyticsArray} withName:@"ProductAnalyticsDic"];
        
    } else {
        NSLog(@"No existía en file saver el arreglo de analytics, asi que lo crearé");
        NSArray *productsAnalyticsArray = @[self.productAnalyticsDic];
        [fileSaver setDictionary:@{@"ProductAnalyticsArray": productsAnalyticsArray} withName:@"ProductAnalyticsDic"];
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
    //TipoDePiso *tipoDePiso = self.grupo.arrayTiposDePiso[indexPath.item];
    Floor *floor = self.floorsArray[indexPath.item];
    
    [self.navigationController.view.layer addAnimation:[NavAnimations navAlphaAnimation] forKey:nil];
    //BrujulaViewController *brujulaVC=[[BrujulaViewController alloc]init];
    BrujulaViewController *brujulaVC=[self.storyboard instantiateViewControllerWithIdentifier:@"Brujula"];
    brujulaVC.externalImageView = [[UIImageView alloc] initWithImage:self.floorsImagesArray[indexPath.item]];
    brujulaVC.gradosExtra = [floor.northDegrees floatValue];
    [self.navigationController pushViewController:brujulaVC animated:NO];
}

-(void)pinButtonWasSelectedWithIndex:(NSUInteger)index inCell:(PisoCollectionViewCell *)cell {
    [self sendAnalytics];
    
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
