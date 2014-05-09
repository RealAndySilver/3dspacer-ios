//
//  ProyectoViewController.m
//  Ekoobot 3D
//
//  Created by Diego Vidal on 8/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "ProyectoViewController.h"
#import "IAmCoder.h"
#import "ProyectoCollectionViewCell.h"
#import "PlanosDePlantaViewController.h"
#import "MBProgressHud.h"
#import "ProjectDownloader.h"
#import "ProgressView.h"

@interface ProyectoViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) ProgressView *progressView;
@end

@implementation ProyectoViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabelWithTag) name:@"updates" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertViewAppear) name:@"alert" object:nil];
    [self setupUI];
}

-(void)setupUI {
    CGRect screenFrame = CGRectMake(0.0, 0.0, 1024.0, 768.0);
    
    //ProgressView
    self.progressView=[[ProgressView alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.height, self.navigationController.view.frame.size.width)];
    
    [self.navigationController.view addSubview:self.progressView];
    [self.view bringSubviewToFront:self.progressView];
    
    //CollectionView
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewFlowLayout.itemSize = screenFrame.size;
    collectionViewFlowLayout.minimumLineSpacing = 0;
    collectionViewFlowLayout.minimumInteritemSpacing = 0;
    collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:screenFrame collectionViewLayout:collectionViewFlowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[ProyectoCollectionViewCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
    [self.view addSubview:self.collectionView];
    
    //Enter button
    UIButton *enterButton = [[UIButton alloc] initWithFrame:CGRectMake(830, 560,170, 170)];
    [enterButton setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"BotonEntrar", nil)] forState:UIControlStateNormal];
    [enterButton addTarget:self action:@selector(showLoadingHUD) forControlEvents:UIControlEventTouchUpInside];
    if ([self.proyecto.data isEqualToString:@"1"]) {
        [self.view addSubview:enterButton];
    }
    
    //Project Logo ImageView
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 140, 150, 150)];
    logoImageView.image = [self getLogoImageFromProject];
    [self.view addSubview:logoImageView];
    
    //UpdateButton Label
    UIView *container=[[UIView alloc]initWithFrame:CGRectMake(55, 107, 265, 35)];
    container.backgroundColor=[UIColor colorWithWhite:0.2 alpha:1];
    container.alpha=0.8;
    container.layer.cornerRadius = 10.0;
    container.layer.shadowColor = [[UIColor colorWithWhite:0.1 alpha:1] CGColor];
    container.layer.shadowOffset = CGSizeMake(5.0f,5.0f);
    container.layer.shadowRadius = 5;
    container.layer.shadowOpacity = 1.0;
    
    UILabel *tituloProyecto = [[UILabel alloc]initWithFrame:CGRectMake(100, 97, 200, 50)];
    tituloProyecto.text = self.proyecto.nombre;
    tituloProyecto.backgroundColor=[UIColor clearColor];
    tituloProyecto.textColor=[UIColor whiteColor];
    tituloProyecto.adjustsFontSizeToFitWidth = YES;
    [tituloProyecto setFont:[UIFont fontWithName:@"Helvetica" size:26]];
    [self.view addSubview:container];
    [self.view addSubview:tituloProyecto];
    
    //UpdateButton
    UIButton *updateButton = [[UIButton alloc] initWithFrame:CGRectMake(25, 75,100, 100)];
    [updateButton setImage:[UIImage imageNamed:@"downloadBtn"] forState:UIControlStateNormal];
    [updateButton addTarget:self action:@selector(updateProjectInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:updateButton];
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.proyecto.arrayAdjuntos count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProyectoCollectionViewCell *cell = (ProyectoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    cell.imageView.image = [self projectAttachedImageAtIndex:indexPath.item];
    return cell;
}

#pragma mark - Actions 

-(void)updateProjectInfo {
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    [dic setObject:self.proyecto forKey:@"Project"];
    [dic setObject:@1 forKey:@"Tag"];
    [dic setObject:self.progressView forKey:@"Sender"];
    [dic setObject:self.usuario forKey:@"Usuario"];
    [self performSelectorInBackground:@selector(downloadProject:) withObject:dic];
}

-(void)downloadProject:(NSMutableDictionary*)dic{
    NSLog(@"entré a descargar el proyectooo");
    Proyecto *proyecto=[dic objectForKey:@"Project"];
    if ([proyecto.data isEqualToString:@"1"]) {
        [self.progressView setViewAlphaToOne];
        [ProjectDownloader downloadProject:[dic objectForKey:@"Project"] yTag:[[dic objectForKey:@"Tag"]intValue] sender:self.progressView usuario:[dic objectForKey:@"Usuario"]];
        [self.progressView setViewAlphaToCero];
    }
}

-(void)showLoadingHUD {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=NSLocalizedString(@"Cargando", nil);
    [self performSelector:@selector(goToPlanosVC) withObject:nil afterDelay:0.3];
}

-(void)goToPlanosVC {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    ItemUrbanismo *itemUrbanismo = self.proyecto.arrayItemsUrbanismo[0];
    Grupo *grupo = itemUrbanismo.arrayGrupos[0];
    TipoDePiso *tipoDePiso = grupo.arrayTiposDePiso[0];
    Producto *producto = tipoDePiso.arrayProductos[0];
    
    PlanosDePlantaViewController *planosDePlanta = [self.storyboard instantiateViewControllerWithIdentifier:@"PlanosDePlanta"];
    planosDePlanta.producto = producto;
    [self.navigationController pushViewController:planosDePlanta animated:YES];
}

#pragma mark - Custom Methods

-(UIImage *)getLogoImageFromProject {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/logo%@%@",docDir,self.proyecto.idProyecto,[IAmCoder encodeURL:self.proyecto.logo]];
    [ProjectDownloader addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:docDir]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    
    if (!fileExists) {
        //NSLog(@"no existe proj img %@",jpegFilePath);
        NSURL *urlImagen=[NSURL URLWithString:self.proyecto.logo];
        NSData *data=[NSData dataWithContentsOfURL:urlImagen];
        UIImage *image = [UIImage imageWithData:data];
        NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
        if (image) {
            [data2 writeToFile:jpegFilePath atomically:YES];
        }
        return image;
    }
    else {
        UIImage *image = [UIImage imageWithContentsOfFile:jpegFilePath];
        return image;
    }
}

-(UIImage *)projectAttachedImageAtIndex:(NSUInteger)index {
    Adjunto *adjunto = self.proyecto.arrayAdjuntos[index];
    if ([adjunto.tipo isEqualToString:@"image"]) {
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        [ProjectDownloader addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:docDir]];
        NSString *jpegFilePath = [NSString stringWithFormat:@"%@/render%@%@.jpg",docDir,self.proyecto.idProyecto,[IAmCoder encodeURL:adjunto.imagen]];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
        if (!fileExists) {
            NSURL *urlImagen=[NSURL URLWithString:adjunto.imagen];
            NSData *data=[NSData dataWithContentsOfURL:urlImagen];
            UIImage *image = [UIImage imageWithData:data];
            NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
            if (image) {
                [data2 writeToFile:jpegFilePath atomically:YES];
            }
            return image;

        } else {
            UIImage *image = [UIImage imageWithContentsOfFile:jpegFilePath];
            return image;
        }

    } else {
        return nil;
    }
}

#pragma mark - Notification Handlers

-(void)updateLabelWithTag {
    [self goToPlanosVC];
}

-(void)alertViewAppear {
    NSString *message=NSLocalizedString(@"ErrorDescarga", nil);
    [[[UIAlertView alloc]initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
}

@end
