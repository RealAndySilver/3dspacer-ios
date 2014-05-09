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
#import "NavAnimations.h"
#import "ZoomViewController.h"
#import "SendInfoViewController.h"
#import "UpdateView.h"
#import "SlideshowViewController.h"
#import "SlideControlViewController.h"

@interface ProyectoViewController () <UICollectionViewDataSource, UICollectionViewDelegate, ProyectoCollectionViewCellDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) ProgressView *progressView;
@property (strong, nonatomic) UIWindow *secondWindow;
@end

@implementation ProyectoViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabelWithTag) name:@"updates" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertViewAppear) name:@"alert" object:nil];
    [self saveProjectAttachedImages];
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
    
    //SendInfoButton
    UIButton *sendInfoButton = [[UIButton alloc] initWithFrame:CGRectMake(53, 600, 40, 40)];
    [sendInfoButton addTarget:self action:@selector(sendInfo) forControlEvents:UIControlEventTouchUpInside];
    [sendInfoButton setImage:[UIImage imageNamed:@"mensaje.png"] forState:UIControlStateNormal];
    [self.view addSubview:sendInfoButton];
    
    //Info Button
    //[self mostrarInfoButtonConTag:1];
    
    //Slideshow Button
    UIButton *slideshowButton = [[UIButton alloc] initWithFrame:CGRectMake(53, 480, 40, 40)];
    [slideshowButton setImage:[UIImage imageNamed:NSLocalizedString(@"tv2.png", nil)] forState:UIControlStateNormal];
    [slideshowButton addTarget:self action:@selector(goToSlideShow) forControlEvents:UIControlEventTouchUpInside];
    if ([self.proyecto.arrayAdjuntos count] > 0) {
        [self.view addSubview:slideshowButton];
    }
}

-(void)mostrarInfoButtonConTag:(NSUInteger)tag {
    UpdateView *updateBox=[[UpdateView alloc]initWithFrame:CGRectMake(43, 660, 274, 40)];
    updateBox.tag=tag+250;
    [self.view addSubview:updateBox];
    NSLog(@"update tag----> %i %@",updateBox.tag,updateBox);
    FileSaver *file=[[FileSaver alloc]init];
    NSString *composedTag=[NSString stringWithFormat:@"%i%@",tag,self.proyecto.idProyecto];
    if ([self.proyecto.data isEqualToString:@"0"]) {
        updateBox.titleText.backgroundColor=[UIColor clearColor];
        updateBox.titleText.text=NSLocalizedString(@"UltimaVersion", nil);
        updateBox.titleText.textColor=[UIColor greenColor];
        updateBox.titleText.tag=tag+1100;
        updateBox.updateText.textColor=[UIColor whiteColor];
        updateBox.updateText.text=@"";
        updateBox.container.alpha=0;
        updateBox.infoButton.selected=NO;
        return;
    }
    if ([file getUpdateFileWithString:composedTag]) {
        NSString *actualizadoEl=NSLocalizedString(@"ActualizadoEl", nil);
        updateBox.updateText.text=[NSString stringWithFormat:@"%@ %@",actualizadoEl,[file getUpdateFileWithString:composedTag]];
        if (![self.proyecto.actualizado isEqualToString:[file getUpdateFileWithString:composedTag]]) {
            updateBox.titleText.text=NSLocalizedString(@"NuevaVersion", nil);
            updateBox.titleText.textColor=[UIColor redColor];
            updateBox.titleText.tag=tag+1100;
            updateBox.container.alpha=1;
            updateBox.infoButton.selected=YES;
            NSString *peso=NSLocalizedString(@"Peso", nil);
            updateBox.updateText.text=[NSString stringWithFormat:@"%@ %@",peso,self.proyecto.peso];
            //updateBox.updateText.textColor=[UIColor orangeColor];
            if ([self.usuario.tipo isEqualToString:@"sellers"]) {
                // Para poner botón de entrar para vendedores con el proyecto desactualizado //
                UIButton *lebuttons = (UIButton *)[self.view viewWithTag:tag+1000];
                NSLog(@"Button punto tag %i",lebuttons.tag);
                lebuttons.alpha=1;
            }
        }
        else{
            updateBox.titleText.backgroundColor=[UIColor clearColor];
            updateBox.titleText.text=NSLocalizedString(@"UltimaVersion", nil);
            updateBox.titleText.textColor=[UIColor greenColor];
            updateBox.titleText.tag=tag+1100;
            updateBox.updateText.textColor=[UIColor whiteColor];
            updateBox.container.alpha=0;
            updateBox.infoButton.selected=NO;
            UIButton *lebuttons = (UIButton *)[self.view viewWithTag:tag+1000];
            NSLog(@"Button punto tag %i",lebuttons.tag);
            lebuttons.alpha=1;
        }
    }
    else{
        updateBox.container.alpha=0;
        updateBox.infoButton.selected=NO;
        updateBox.titleText.text=NSLocalizedString(@"Descarga", nil);
        NSString *peso=NSLocalizedString(@"Peso", nil);
        updateBox.updateText.text=[NSString stringWithFormat:@"%@ %@",peso,self.proyecto.peso];
    }
    [self.view bringSubviewToFront:updateBox];
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.proyecto.arrayAdjuntos count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProyectoCollectionViewCell *cell = (ProyectoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    cell.delegate = self;
    cell.imageView.image = [self projectAttachedImageAtIndex:indexPath.item];
    return cell;
}

#pragma mark - Actions 

-(void)goToSlideShow {
    SlideshowViewController *ssVC=[[SlideshowViewController alloc]init];
    ssVC.imagePathArray = [self arrayOfProjectImagesPaths];
    //ssVC.imagePathArray = [renderPathArray objectAtIndex:sender.tag-3500];
    
    SlideControlViewController *cVC=[[SlideControlViewController alloc]init];
    cVC=[self.storyboard instantiateViewControllerWithIdentifier:@"SlideControl"];
    if ([[UIScreen screens] count] > 1)
    {
        UIScreen *secondScreen = [[UIScreen screens] objectAtIndex:1];
        NSString *availableModeString;
        
        for (int i = 0; i < secondScreen.availableModes.count; i++)
        {
            availableModeString = [NSString stringWithFormat:@"%f, %f",
                                   ((UIScreenMode *)[secondScreen.availableModes objectAtIndex:i]).size.width,
                                   ((UIScreenMode *)[secondScreen.availableModes objectAtIndex:i]).size.height];
            
            //[[[UIAlertView alloc] initWithTitle:@"Available Mode" message:availableModeString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            availableModeString = nil;
        }
        
        // undocumented value 3 means no overscan compensation
        secondScreen.overscanCompensation = 3;
        self.secondWindow=nil;
        self.secondWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, secondScreen.bounds.size.width, secondScreen.bounds.size.height)];
        self.secondWindow.screen = secondScreen;
        ssVC.window=self.secondWindow;
        self.secondWindow.rootViewController = ssVC;
        self.secondWindow.hidden = NO;
        NSLog(@"Screen %f x %f",ssVC.window.screen.bounds.size.height,ssVC.window.screen.bounds.size.width);
        cVC.modalPresentationStyle = UIModalPresentationFormSheet;
        [self.navigationController presentViewController:cVC animated:YES completion:nil];
        
    }
    else{
        
        [self.navigationController pushViewController:ssVC animated:YES];
    }
}

-(void)sendInfo {
    SendInfoViewController *sendInfoVC=[[SendInfoViewController alloc]init];
    sendInfoVC=[self.storyboard instantiateViewControllerWithIdentifier:@"SendInfo"];
    sendInfoVC.nombreProyecto = self.proyecto.nombre;
    sendInfoVC.proyectoID = self.proyecto.idProyecto;
    sendInfoVC.usuario = self.usuario.usuario;
    sendInfoVC.currentUser = self.usuario;
    sendInfoVC.contrasena = self.usuario.contrasena;
    sendInfoVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    sendInfoVC.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    [self.navigationController presentViewController:sendInfoVC animated:YES completion:nil];
}

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

-(void)saveProjectAttachedImages {
    for (int i = 0; i < [self.proyecto.arrayAdjuntos count]; i++) {
        Adjunto *adjunto = self.proyecto.arrayAdjuntos[i];
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
            }
        }
    }
}

-(NSArray *)arrayOfProjectImagesPaths {
    NSMutableArray *projectImagesArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.proyecto.arrayAdjuntos count]; i++) {
        Adjunto *adjunto = self.proyecto.arrayAdjuntos[i];
        if ([adjunto.tipo isEqualToString:@"image"]) {
            NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            [ProjectDownloader addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:docDir]];
            NSString *jpegFilePath = [NSString stringWithFormat:@"%@/render%@%@.jpg",docDir,self.proyecto.idProyecto,[IAmCoder encodeURL:adjunto.imagen]];
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
            if (fileExists) {
                [projectImagesArray addObject:jpegFilePath];
            }
        }
    }
    return projectImagesArray;
}

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

-(NSString *)pathForProjectImageAtIndex:(NSUInteger)index {
    Adjunto *adjunto = self.proyecto.arrayAdjuntos[index];
    if ([adjunto.tipo isEqualToString:@"image"]) {
        NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *jpegFilePath = [NSString stringWithFormat:@"%@/render%@%@.jpg",docDir,self.proyecto.idProyecto,[IAmCoder encodeURL:adjunto.imagen]];
        return jpegFilePath;
    } else {
        return nil;
    }
}

#pragma mark - ProyectoCollectionViewCellDelegate

-(void)zoomButtonTappedInCell:(ProyectoCollectionViewCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    ZoomViewController *zoomVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Zoom"];
    [self.navigationController.view.layer addAnimation:[NavAnimations navAlphaAnimation] forKey:nil];
    zoomVC.path = [self pathForProjectImageAtIndex:indexPath.item];
    [self.navigationController pushViewController:zoomVC animated:NO];
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
