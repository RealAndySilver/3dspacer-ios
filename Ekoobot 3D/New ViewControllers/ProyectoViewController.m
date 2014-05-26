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
#import "PlantaUrbanaVC.h"
#import "PlanosDePisoViewController.h"
#import "Project+AddOn.h"
#import "Render+AddOns.h"
#import "Urbanization.h"
#import "UserInfo.h"

@interface ProyectoViewController () <UICollectionViewDataSource, UICollectionViewDelegate, ProyectoCollectionViewCellDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) ProgressView *progressView;
@property (strong, nonatomic) UIWindow *secondWindow;
@property (strong, nonatomic) UIButton *enterButton;
@end

@implementation ProyectoViewController {
    CGRect screenBounds;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    CGRect screen = [UIScreen mainScreen].bounds;
    screenBounds = CGRectMake(0.0, 0.0, screen.size.height, screen.size.width);
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabelWithTag:) name:@"updates" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertViewAppear) name:@"alert" object:nil];
    //[self performSelectorInBackground:@selector(saveProjectAttachedImages) withObject:nil];
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

-(void)setupUI {
    CGRect screenFrame = screenBounds;
    
    CGRect updateButtonFrame;
    CGRect containerFrame;
    CGRect slideshowButtonFrame;
    CGRect sendInfoButtonFrame;
    CGRect infoButtonFrame;
    CGRect enterButtonFrame;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        updateButtonFrame = CGRectMake(16, 100 ,50, 50);
        containerFrame = CGRectMake(55, 107, 265, 35);
        slideshowButtonFrame = CGRectMake(53, 480, 40, 40);
        sendInfoButtonFrame = CGRectMake(53, 600, 40, 40);
        infoButtonFrame = CGRectMake(43, 660, 274, 40);
        enterButtonFrame = CGRectMake(830, 560,170, 170);

    } else {
        updateButtonFrame = CGRectMake(10.0, 64.0, 40.0, 40.0);
        containerFrame = CGRectMake(40.0, 66.0, 260.0, 35.0);
        slideshowButtonFrame = CGRectMake(10.0, 120.0, 40.0, 40.0);
        sendInfoButtonFrame = CGRectMake(10.0, slideshowButtonFrame.origin.y + slideshowButtonFrame.size.height + 10.0, 40.0, 40.0);
        infoButtonFrame = CGRectMake(0.0, sendInfoButtonFrame.origin.y + sendInfoButtonFrame.size.height + 10.0 + 40.0 + 10.0, 274.0, 40.0);
        enterButtonFrame = CGRectMake(screenFrame.size.width - 70.0, screenFrame.size.height - 70.0, 60.0, 60.0);
    }
    
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
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    [self.collectionView registerClass:[ProyectoCollectionViewCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
    [self.view addSubview:self.collectionView];
    
    //Enter button
    self.enterButton = [[UIButton alloc] initWithFrame:enterButtonFrame];
    [self.enterButton setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"BotonEntrar", nil)] forState:UIControlStateNormal];
    [self.enterButton addTarget:self action:@selector(showLoadingHUD) forControlEvents:UIControlEventTouchUpInside];
    self.enterButton.alpha = 1.0;
    [self.view addSubview:self.enterButton];
    /*if ([self.proyecto.data isEqualToString:@"1"]) {
        [self.view addSubview:self.enterButton];
    }*/
    
    //Project Logo ImageView
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 140, 150, 150)];
        Project *project = self.projectDic[@"project"];
        logoImageView.image = [project projectLogoImage];
        [self.view addSubview:logoImageView];
    }
    
    //UpdateButton Label
    UIView *container=[[UIView alloc]initWithFrame:containerFrame];
    container.backgroundColor=[UIColor colorWithWhite:0.2 alpha:1];
    container.alpha=0.8;
    container.layer.cornerRadius = 10.0;
    container.layer.shadowColor = [[UIColor colorWithWhite:0.1 alpha:1] CGColor];
    container.layer.shadowOffset = CGSizeMake(5.0f,5.0f);
    container.layer.shadowRadius = 5;
    container.layer.shadowOpacity = 1.0;
    
    UILabel *tituloProyecto = [[UILabel alloc]initWithFrame:CGRectMake(10.0, 0.0, container.frame.size.width, container.frame.size.height)];
    Project *project = self.projectDic[@"project"];
    tituloProyecto.text = project.name;
    tituloProyecto.backgroundColor=[UIColor clearColor];
    tituloProyecto.textColor=[UIColor whiteColor];
    tituloProyecto.adjustsFontSizeToFitWidth = YES;
    [tituloProyecto setFont:[UIFont fontWithName:@"Helvetica" size:26]];
    [container addSubview:tituloProyecto];
    [self.view addSubview:container];
    
    //UpdateButton
    /*UIButton *updateButton = [[UIButton alloc] initWithFrame:updateButtonFrame];
    [updateButton setBackgroundImage:[UIImage imageNamed:@"downloadBtn"] forState:UIControlStateNormal];
    [updateButton addTarget:self action:@selector(updateProjectInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:updateButton];*/
    
    //SendInfoButton
    UIButton *sendInfoButton = [[UIButton alloc] initWithFrame:sendInfoButtonFrame];
    [sendInfoButton addTarget:self action:@selector(sendInfo) forControlEvents:UIControlEventTouchUpInside];
    [sendInfoButton setImage:[UIImage imageNamed:@"mensaje.png"] forState:UIControlStateNormal];
    [self.view addSubview:sendInfoButton];
    
    //Info Button
    //[self mostrarInfoButtonConTag:self.projectNumber + 2000 frame:infoButtonFrame];
    
    //Slideshow Button
    UIButton *slideshowButton = [[UIButton alloc] initWithFrame:slideshowButtonFrame];
    [slideshowButton setImage:[UIImage imageNamed:NSLocalizedString(@"tv2.png", nil)] forState:UIControlStateNormal];
    [slideshowButton addTarget:self action:@selector(goToSlideShow) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:slideshowButton];
    /*if ([self.proyecto.arrayAdjuntos count] > 0) {
        [self.view addSubview:slideshowButton];
    }*/
}

/*-(void)mostrarInfoButtonConTag:(NSUInteger)tag frame:(CGRect)frame{
    UpdateView *updateBox=[[UpdateView alloc]initWithFrame:frame];
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
                self.enterButton.alpha = 1.0;
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
            self.enterButton.alpha = 1.0;
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
}*/

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //return [self.proyecto.arrayAdjuntos count] + 1; //Add 1 because of the main project image
    return [self.projectDic[@"renders"] count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProyectoCollectionViewCell *cell = (ProyectoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    cell.delegate = self;
    /*if (indexPath.item == 0) {
        cell.imageView.image = self.mainImage;
    } else {
        cell.imageView.image = [self projectAttachedImageAtIndex:indexPath.item - 1];
    }*/
    
    Render *render = self.projectDic[@"renders"][indexPath.item];
    cell.imageView.image = [render renderImage];
    return cell;
}

#pragma mark - Actions 

-(void)goToSlideShow {
    NSArray *rendersArray = self.projectDic[@"renders"];
    NSMutableArray *tempRendersArray = [NSMutableArray arrayWithCapacity:[rendersArray count]];
    for (int i = 0; i < [rendersArray count]; i++) {
        Render *render = rendersArray[i];
        [tempRendersArray addObject:[render renderImage]];
    }
    
    SlideshowViewController *ssVC=[[SlideshowViewController alloc]init];
    ssVC.imagesArray = tempRendersArray;
    //ssVC.imagePathArray = [self arrayOfProjectImagesPaths];
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
   /* SendInfoViewController *sendInfoVC=[[SendInfoViewController alloc]init];
    sendInfoVC=[self.storyboard instantiateViewControllerWithIdentifier:@"SendInfo"];
    sendInfoVC.nombreProyecto = self.proyecto.nombre;
    sendInfoVC.proyectoID = self.proyecto.idProyecto;
    sendInfoVC.usuario = self.usuario.usuario;
    sendInfoVC.currentUser = self.usuario;
    sendInfoVC.contrasena = self.usuario.contrasena;
    sendInfoVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    sendInfoVC.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    [self.navigationController presentViewController:sendInfoVC animated:YES completion:nil];*/
    
    Project *project = self.projectDic[@"project"];
    SendInfoViewController *sendInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SendInfo"];
    sendInfoVC.nombreProyecto = project.name;
    sendInfoVC.proyectoID = [NSString stringWithFormat:@"%d", [project.identifier intValue]];
    sendInfoVC.usuario = [UserInfo sharedInstance].userName;
    sendInfoVC.contrasena = [UserInfo sharedInstance].password;
    sendInfoVC.userType = @"sellers"; // ***********************************Corregir estoooooooooo******************************************//
    sendInfoVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    sendInfoVC.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self.navigationController presentViewController:sendInfoVC animated:YES completion:nil];
}

-(void)updateProjectInfo {
    /*self.navigationController.navigationBarHidden = YES;
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    [dic setObject:self.proyecto forKey:@"Project"];
    [dic setObject:@(2000 + self.projectNumber) forKey:@"Tag"];
    [dic setObject:self.progressView forKey:@"Sender"];
    [dic setObject:self.usuario forKey:@"Usuario"];
    [self performSelectorInBackground:@selector(downloadProject:) withObject:dic];*/
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
    /*[MBProgressHUD hideHUDForView:self.view animated:YES];
    
    ItemUrbanismo *itemUrbanismo = self.proyecto.arrayItemsUrbanismo[0];
    
    if ([self.proyecto.data isEqualToString:@"0"]) return;
    
    if (itemUrbanismo.existe==1) {
        [self irAPlantaUrbanaVC];
    }
    else{
        Grupo *grupo = itemUrbanismo.arrayGrupos[0];
        if (grupo.existe == 1) {
            TipoDePiso *tipoDePiso = grupo.arrayTiposDePiso[0];
            if (tipoDePiso.existe == 1) {
                [self irATiposDePisosVCConGrupo:grupo];
            }
            else{
                Producto *producto = tipoDePiso.arrayProductos[0];
                [self irATiposDePlantasVCConProducto:producto];
            }
        }
        else{
            TipoDePiso *tipoDePiso = grupo.arrayTiposDePiso[0];
            Producto *producto = tipoDePiso.arrayProductos[0];
            [self irATiposDePlantasVCConProducto:producto];
        }
    }*/
    
    Urbanization *urbanization = [self.projectDic[@"urbanizations"] firstObject];
    if ([urbanization.enabled boolValue]) {
        [self irAPlantaUrbanaVC];
    }
}

-(void)irAPlantaUrbanaVC {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    PlantaUrbanaVC *plantaUrbanaVC = [[PlantaUrbanaVC alloc]init];
    plantaUrbanaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PlantaUrbanaVC"];
    //plantaUrbanaVC.proyecto = self.proyecto;
    plantaUrbanaVC.projectDic = self.projectDic;
    [self.navigationController.view.layer addAnimation:[NavAnimations navAlphaAnimation] forKey:nil];
    [self.navigationController pushViewController:plantaUrbanaVC animated:NO];
}

-(void)irATiposDePisosVCConGrupo:(Grupo *)grupo {
    /*PlanosDePisoViewController *planosDePiso = [self.storyboard instantiateViewControllerWithIdentifier:@"PlanosDePiso"];
    planosDePiso.grupo = grupo;
    [self.navigationController.view.layer addAnimation:[NavAnimations navAlphaAnimation] forKey:nil];
    [self.navigationController pushViewController:planosDePiso animated:YES];*/
}

-(void)irATiposDePlantasVCConProducto:(Producto *)producto {
    /*PlanosDePlantaViewController *planosDePlantaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PlanosDePlanta"];
    planosDePlantaVC.producto = producto;
    [self.navigationController.view.layer addAnimation:[NavAnimations navAlphaAnimation] forKey:nil];
    [self.navigationController pushViewController:planosDePlantaVC animated:YES];*/
}

#pragma mark - Custom Methods

-(void)saveProjectAttachedImages {
    /*for (int i = 0; i < [self.proyecto.arrayAdjuntos count]; i++) {
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
    }*/
}

-(NSArray *)arrayOfProjectImagesPaths {
   /* NSMutableArray *projectImagesArray = [[NSMutableArray alloc] init];
    
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
    return projectImagesArray;*/
}

-(UIImage *)getLogoImageFromProject {
   /* NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
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
    }*/
}

-(UIImage *)projectAttachedImageAtIndex:(NSUInteger)index {
    /*Adjunto *adjunto = self.proyecto.arrayAdjuntos[index];
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
    }*/
}

-(NSString *)pathForProjectImageAtIndex:(NSUInteger)index {
    /*Adjunto *adjunto = self.proyecto.arrayAdjuntos[index];
    if ([adjunto.tipo isEqualToString:@"image"]) {
        NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *jpegFilePath = [NSString stringWithFormat:@"%@/render%@%@.jpg",docDir,self.proyecto.idProyecto,[IAmCoder encodeURL:adjunto.imagen]];
        return jpegFilePath;
    } else {
        return nil;
    }*/
}

-(NSString *)pathForMainImage {
    /*NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/cover%@%@.jpeg",docDir,self.proyecto.idProyecto,[IAmCoder encodeURL:self.proyecto.imagen]];
    return jpegFilePath;*/
}

#pragma mark - ProyectoCollectionViewCellDelegate

-(void)zoomButtonTappedInCell:(ProyectoCollectionViewCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    ZoomViewController *zoomVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Zoom"];
    [self.navigationController.view.layer addAnimation:[NavAnimations navAlphaAnimation] forKey:nil];
    
    Render *render = self.projectDic[@"renders"][indexPath.item];
    zoomVC.zoomImage = [render renderImage];
    /*if (indexPath.item == 0) {
        //Get Path for main image
        zoomVC.path = [self pathForMainImage];
    } else {
        zoomVC.path = [self pathForProjectImageAtIndex:indexPath.item - 1];
    }*/
    [self.navigationController pushViewController:zoomVC animated:NO];
}

#pragma mark - Notification Handlers

-(void)updateLabelWithTag:(NSNotification *)notification {
    self.navigationController.navigationBarHidden = NO;
    
    NSDictionary *dictionary=notification.object;
    NSNumber *number=[dictionary objectForKey:@"tag"];
    NSString *ID=[dictionary objectForKey:@"id"];
    
    FileSaver *file=[[FileSaver alloc]init];
    NSString *composedTag=[NSString stringWithFormat:@"%@%@",number,ID];
    
    [file getUpdateFileWithString:composedTag];
    if ([file getUpdateFileWithString:composedTag]) {
        UpdateView *updateBox = (UpdateView *)[self.view viewWithTag:[number intValue]+250];
        NSLog(@"number li tag----> %i %@",updateBox.tag,updateBox.updateText);
        NSString *actualizadoEl=NSLocalizedString(@"ActualizadoEl", nil);
        updateBox.updateText.text=[NSString stringWithFormat:@"%@ %@",actualizadoEl,[file getUpdateFileWithString:composedTag]];
        updateBox.container.alpha=0;
        updateBox.titleText.textColor=[UIColor whiteColor];
        self.enterButton.alpha=1;
        //NSLog(@"Updated %@ %@",number,[file getUpdateFile:[number intValue]]);
        
        //[self performSelectorOnMainThread:@selector(irAlSiguienteViewController:) withObject:button waitUntilDone:YES];
        updateBox.titleText.text=[NSString stringWithFormat:NSLocalizedString(@"UltimaVersion", nil)];
        updateBox.titleText.textColor=[UIColor greenColor];
    }
    
    [self goToPlanosVC];
}

-(void)alertViewAppear {
    NSString *message=NSLocalizedString(@"ErrorDescarga", nil);
    [[[UIAlertView alloc]initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
}

@end
