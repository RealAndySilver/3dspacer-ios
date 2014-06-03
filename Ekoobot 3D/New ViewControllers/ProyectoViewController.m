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
#import "Urbanization+AddOns.h"
#import "Group+AddOns.h"
#import "Floor+AddOns.h"
#import "Product+AddOns.h"
#import "Plant+AddOns.h"
#import "Space+AddOns.h"
#import "Finish+AddOns.h"
#import "FinishImage+AddOns.h"
#import "UserInfo.h"
#import "InfoView.h"
#import "NSArray+NullReplacement.h"
#import "NSDictionary+NullReplacement.h"
#import "DownloadView.h"

@interface ProyectoViewController () <UICollectionViewDataSource, UICollectionViewDelegate, ProyectoCollectionViewCellDelegate, ServerCommunicatorDelegate, DownloadViewDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) ProgressView *progressView;
@property (strong, nonatomic) UIWindow *secondWindow;
@property (strong, nonatomic) UIButton *enterButton;
@property (strong, nonatomic) InfoView *infoView;
@property (strong, nonatomic) UIManagedDocument *databaseDocument;

//Project objects
@property (strong, nonatomic) NSArray *rendersArray;
@property (strong, nonatomic) NSDictionary *urbanizationDic;
@property (strong, nonatomic) NSArray *groupsArray;
@property (strong, nonatomic) NSArray *floorsArray;
@property (strong, nonatomic) NSArray *productsArray;
@property (strong, nonatomic) NSArray *plantsArray;
@property (strong, nonatomic) NSArray *spacesArray;
@property (strong, nonatomic) NSArray *finishesArray;
@property (strong, nonatomic) NSArray *finishesImagesArray;

@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) DownloadView *downloadView;
@end

@implementation ProyectoViewController {
    CGRect screenBounds;
}

-(UIView *)opacityView {
    if (!_opacityView) {
        _opacityView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024.0, 768.0)];
        _opacityView.backgroundColor = [UIColor blackColor];
        _opacityView.alpha = 0.7;
    }
    return _opacityView;
}

-(DownloadView *)downloadView {
    if (!_downloadView) {
        _downloadView = [[DownloadView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 350/2.0, screenBounds.size.height/2.0 - 250.0/2.0 + 25.0, 350.0, 250.0)];
        _downloadView.delegate = self;
    }
    return _downloadView;
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
        updateButtonFrame = CGRectMake(30, 100 ,50, 50);
        containerFrame = CGRectMake(70, 107, 265, 35);
        slideshowButtonFrame = CGRectMake(53, 480, 40, 40);
        sendInfoButtonFrame = CGRectMake(53, 600, 40, 40);
        infoButtonFrame = CGRectMake(53, 660, 40, 40);
        enterButtonFrame = CGRectMake(830, 560,170, 170);

    } else {
        updateButtonFrame = CGRectMake(10.0, 64.0, 40.0, 40.0);
        containerFrame = CGRectMake(40.0, 66.0, 260.0, 35.0);
        slideshowButtonFrame = CGRectMake(10.0, 120.0, 40.0, 40.0);
        sendInfoButtonFrame = CGRectMake(10.0, slideshowButtonFrame.origin.y + slideshowButtonFrame.size.height + 10.0, 40.0, 40.0);
        infoButtonFrame = CGRectMake(10.0, sendInfoButtonFrame.origin.y + sendInfoButtonFrame.size.height + 10.0 + 40.0 + 10.0, 40.0, 40.0);
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
        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 140, 150, 150)];
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
    UIButton *updateButton = [[UIButton alloc] initWithFrame:updateButtonFrame];
    [updateButton setBackgroundImage:[UIImage imageNamed:@"NewUpdateIcon.jpg"] forState:UIControlStateNormal];
    [updateButton addTarget:self action:@selector(downloadProject) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:updateButton];
    
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
    
    //Info button
    UIButton *infoButton = [[UIButton alloc] initWithFrame:infoButtonFrame];
    [infoButton setBackgroundImage:[UIImage imageNamed:@"ayuda_off.png"] forState:UIControlStateNormal];
    [infoButton addTarget:self action:@selector(showInfoView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:infoButton];
    self.infoView = [[InfoView alloc] initWithFrame:CGRectMake(infoButton.frame.origin.x + infoButton.frame.size.width/2.0, infoButton.frame.origin.y, 260.0, 40.0)];
    self.infoView.topLabelColor = [UIColor greenColor];
    self.infoView.alpha = 0.0;
    [self.view addSubview:self.infoView];
    [self.view bringSubviewToFront:infoButton];
    
    //Downloading View
    [self.view addSubview:self.opacityView];
    [self.navigationController.view addSubview:self.downloadView];
    self.opacityView.hidden = YES;
    self.downloadView.hidden = YES;
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

-(void)showInfoView {
    NSLog(@"toque el botoncito de info");
    static BOOL viewIsTransparent = YES;
    if (viewIsTransparent) {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^(){
                             self.infoView.alpha = 1.0;
                         } completion:^(BOOL finished){
                             viewIsTransparent = NO;
                         }];
    } else {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^(){
                             self.infoView.alpha = 0.0;
                         } completion:^(BOOL finished){
                             viewIsTransparent = YES;
                         }];
    }
}

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

/*-(void)downloadProject:(NSMutableDictionary*)dic{
    NSLog(@"entré a descargar el proyectooo");
    Proyecto *proyecto=[dic objectForKey:@"Project"];
    if ([proyecto.data isEqualToString:@"1"]) {
        [self.progressView setViewAlphaToOne];
        [ProjectDownloader downloadProject:[dic objectForKey:@"Project"] yTag:[[dic objectForKey:@"Tag"]intValue] sender:self.progressView usuario:[dic objectForKey:@"Usuario"]];
        [self.progressView setViewAlphaToCero];
    }
}*/

-(void)showLoadingHUD {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=NSLocalizedString(@"Cargando", nil);
    [self performSelector:@selector(goToPlanosVC) withObject:nil afterDelay:0.3];
}

-(void)goToPlanosVC {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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
        
    } else {
        Group *group = [self.projectDic[@"groups"] firstObject];
        
        if ([group.enabled boolValue]) {
            //Get the first floor of this group
            Floor *floor;
            for (int i = 0; i < [self.projectDic[@"floors"] count]; i++) {
                floor = self.projectDic[@"floors"][i];
                if ([floor.group isEqual:group.identifier]) {
                    break;
                }
            }
            if ([floor.enabled boolValue]) {
                [self irATiposDePisosVCConGrupo:group];
            } else {
                //Get the first product of the floor
                Product *product;
                for (int i = 0; i < [self.projectDic[@"products"] count]; i++) {
                    product = self.projectDic[@"products"][i];
                    if ([product.floor isEqualToString:floor.identifier]) {
                        break;
                    }
                }
                [self irATiposDePlantasVCConProducto:product];
            }
        
        } else {
            //Get the first floor of the group
            Floor *floor;
            for (int i = 0; i < [self.projectDic[@"floors"] count]; i++) {
                floor = self.projectDic[@"floors"][i];
                if ([floor.group isEqual:group.identifier]) {
                    break;
                }
            }
            
            //Get the first product of the floor
            Product *product;
            for (int i = 0; i < [self.projectDic[@"products"] count]; i++) {
                product = self.projectDic[@"products"][i];
                if ([product.floor isEqualToString:floor.identifier]) {
                    break;
                }
            }
            [self irATiposDePlantasVCConProducto:product];
        }
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

-(void)irATiposDePisosVCConGrupo:(Group *)group {
    PlanosDePisoViewController *planosDePiso = [self.storyboard instantiateViewControllerWithIdentifier:@"PlanosDePiso"];
    planosDePiso.group = group;
    planosDePiso.projectDic = self.projectDic;
    [self.navigationController.view.layer addAnimation:[NavAnimations navAlphaAnimation] forKey:nil];
    [self.navigationController pushViewController:planosDePiso animated:YES];
}

-(void)irATiposDePlantasVCConProducto:(Product *)product {
    PlanosDePlantaViewController *planosDePlantaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PlanosDePlanta"];
    planosDePlantaVC.product = product;
    planosDePlantaVC.projectDic = self.projectDic;
    [self.navigationController.view.layer addAnimation:[NavAnimations navAlphaAnimation] forKey:nil];
    [self.navigationController pushViewController:planosDePlantaVC animated:YES];
}

-(void)showDownloadingView {
    //[self.view addSubview:self.opacityView];
    //[self.view addSubview:self.downloadView];
    self.opacityView.hidden = NO;
    self.downloadView.hidden = NO;
}

#pragma mark - Server Stuff

-(void)downloadProject {
    [self showDownloadingView];
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    Project *project = self.projectDic[@"project"];
    NSString *projectID = [NSString stringWithFormat:@"%d", [project.identifier intValue]];
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"getProjectById" andParameter:projectID];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if ([methodName isEqualToString:@"getProjectById"]) {
        if (dictionary) {
            NSLog(@"Llegó respuesta del getProjectByID");
            if (dictionary[@"code"]) {
                NSLog(@"Ocurrió algún error y no se devolvió la info");
            } else {
                NSLog(@"Respuesta del getProjectByID: %@", dictionary);
               
                //Download entire project
                self.rendersArray = [dictionary[@"renders"] arrayByReplacingNullsWithBlanks];
                self.urbanizationDic = [dictionary[@"urbanization"] dictionaryByReplacingNullWithBlanks];
                self.groupsArray = [dictionary[@"groups"] arrayByReplacingNullsWithBlanks];
                self.floorsArray = [dictionary[@"floors"] arrayByReplacingNullsWithBlanks];
                self.productsArray = [dictionary[@"products"] arrayByReplacingNullsWithBlanks];
                self.plantsArray = [dictionary[@"plants"] arrayByReplacingNullsWithBlanks];
                self.spacesArray = [dictionary[@"spaces"] arrayByReplacingNullsWithBlanks];
                self.finishesArray = [dictionary[@"finishes"] arrayByReplacingNullsWithBlanks];
                self.finishesImagesArray = [dictionary[@"finishImages"] arrayByReplacingNullsWithBlanks];
                [self startSavingProcessInCoreData];
            }
        } else {
            NSLog(@"NO llegó respuesta del getProjectById");
        }
    }
}

-(void)serverError:(NSError *)error {
    NSLog(@"Server Error: %@ %@", error, [error localizedDescription]);
    self.downloadView.hidden = YES;
    self.opacityView.hidden = YES;
    [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void)startSavingProcessInCoreData {
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //Get the Datababase Document path
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = @"MyDocument";
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
    self.databaseDocument = [[UIManagedDocument alloc] initWithFileURL:url];
    
    //Check if the document exist
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:[url path]];
    if (fileExist) {
        //Open The Database Document
        [self.databaseDocument openWithCompletionHandler:^(BOOL success){
            if (success) {
                [self databaseDocumentIsReadyForSaving];
            
            } else {
                NSLog(@"Could not open the document at %@", url);
            }
        }];
    } else {
        //The documents does not exist on disk, so create it
        [self.databaseDocument saveToURL:self.databaseDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            if (success) {
                [self databaseDocumentIsReadyForSaving];
                
            } else {
                NSLog(@"Could not open the document at %@", url);
            }
        }];
    }
}

-(void)updateLabel:(NSNumber *)aNumber {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fileDownloaded" object:nil userInfo:@{@"Progress": aNumber}];
}

-(void)databaseDocumentIsReadyForSaving {
    if (self.databaseDocument.documentState == UIDocumentStateNormal) {
        
        //Get the total number of files to download
        __block float filesDownloadedCounter = 0;
        __block float progressCompleted;
        __block NSNumber *number = nil;
        float numberOfFiles = [self getNumberOfFilesToDownload];
        NSLog(@"Número de archivos a descargar: %f", numberOfFiles);
        
        //Dic to store all the core data objects and pass them to the next view controller
        NSMutableDictionary *projectDictionary = [[NSMutableDictionary alloc] init];
        
        NSManagedObjectContext *context = self.databaseDocument.managedObjectContext.parentContext;
        [context performBlock:^(){
            //Save render objects in core data
            NSMutableArray *rendersArray = [[NSMutableArray alloc] initWithCapacity:[self.rendersArray count]]; //Of Renders
            for (int i = 0; i < [self.rendersArray count]; i++) {
                NSDictionary *renderInfoDic = self.rendersArray[i];
                Render *render = [Render renderWithServerInfo:renderInfoDic inManagedObjectContext:context];
                [context save:NULL];
                [rendersArray addObject:render];
                filesDownloadedCounter ++;
                progressCompleted = filesDownloadedCounter / numberOfFiles;
                NSLog(@"progresooo: %f", progressCompleted);
                number = @(progressCompleted);
                [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
            }
            
            //Save urbanization object in core data
            NSMutableArray *urbanizationsArray = [[NSMutableArray alloc] init];
            Urbanization *urbanization = [Urbanization urbanizationWithServerInfo:self.urbanizationDic inManagedObjectContext:context];
            [context save:NULL];
            [urbanizationsArray addObject:urbanization];
            filesDownloadedCounter ++;
            progressCompleted = filesDownloadedCounter / numberOfFiles;
            NSLog(@"progresooo: %f", progressCompleted);
            number = @(progressCompleted);
            [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
            
            //Save group objects in Core Data
            NSMutableArray *groupsArray = [[NSMutableArray alloc] initWithCapacity:[self.groupsArray count]];
            for (int i = 0; i < [self.groupsArray count]; i++) {
                Group *group = [Group groupWithServerInfo:self.groupsArray[i] inManagedObjectContext:context];
                [context save:NULL];
                [groupsArray addObject:group];
                
                filesDownloadedCounter ++;
                progressCompleted = filesDownloadedCounter / numberOfFiles;
                NSLog(@"progresooo: %f", progressCompleted);
                number = @(progressCompleted);
                [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
            }
            
            //Save Floor products in Core Data
            NSMutableArray *floorsArray = [[NSMutableArray alloc] initWithCapacity:[self.floorsArray count]];
            for (int i = 0; i < [self.floorsArray count]; i++) {
                Floor *floor = [Floor floorWithServerInfo:self.floorsArray[i] inManagedObjectContext:context];
                [context save:NULL];
                [floorsArray addObject:floor];
                
                filesDownloadedCounter ++;
                progressCompleted = filesDownloadedCounter / numberOfFiles;
                number = @(progressCompleted);
                [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
            }
            
            //Save product objects in Core Data
            NSMutableArray *producstArray = [[NSMutableArray alloc] initWithCapacity:[self.productsArray count]];
            for (int i = 0; i < [self.productsArray count]; i++) {
                Product *product = [Product productWithServerInfo:self.productsArray[i] inManagedObjectContext:context];
                [context save:NULL];
                [producstArray addObject:product];
                
                filesDownloadedCounter ++;
                progressCompleted = filesDownloadedCounter / numberOfFiles;
                number = @(progressCompleted);
                [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
            }
            
            //Save plants objects in Core Data
            NSMutableArray *plantsArray = [[NSMutableArray alloc] initWithCapacity:[self.plantsArray count]];
            for (int i = 0; i < [self.plantsArray count]; i++) {
                Plant *plant = [Plant plantWithServerInfo:self.plantsArray[i] inManagedObjectContext:context];
                [context save:NULL];
                [plantsArray addObject:plant];
                
                filesDownloadedCounter ++;
                progressCompleted = filesDownloadedCounter / numberOfFiles;
                number = @(progressCompleted);
                [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
            }
            
            //Save spaces object in Core Data
            NSMutableArray *spacesArray = [[NSMutableArray alloc] initWithCapacity:[self.spacesArray count]];
            for (int i = 0; i < [self.spacesArray count]; i++) {
                Space *space = [Space spaceWithServerInfo:self.spacesArray[i] inManagedObjectContext:context];
                [context save:NULL];
                [spacesArray addObject:space];
                
                filesDownloadedCounter ++;
                progressCompleted = filesDownloadedCounter / numberOfFiles;
                number = @(progressCompleted);
                [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
            }
            
            //Save finishes in Core Data
            NSMutableArray *finishesArray = [[NSMutableArray alloc] initWithCapacity:[self.finishesArray count]];
            for (int i = 0; i < [self.finishesArray count]; i++) {
                Finish *finish = [Finish finishWithServerInfo:self.finishesArray[i] inManagedObjectContext:context];
                [context save:NULL];
                [finishesArray addObject:finish];
                
                filesDownloadedCounter ++;
                progressCompleted = filesDownloadedCounter / numberOfFiles;
                number = @(progressCompleted);
                [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
            }
            
            //Save finishes images in Core Data
            NSMutableArray *finishesImagesArray = [[NSMutableArray alloc] initWithCapacity:[self.finishesImagesArray count]];
            for (int i = 0; i < [self.finishesImagesArray count]; i++) {
                FinishImage *finishImage = [FinishImage finishImageWithServerInfo:self.finishesImagesArray[i] inManagedObjectContext:context];
                [context save:NULL];
                [finishesImagesArray addObject:finishImage];
                
                filesDownloadedCounter ++;
                progressCompleted = filesDownloadedCounter / numberOfFiles;
                number = @(progressCompleted);
                [self performSelectorOnMainThread:@selector(updateLabel:) withObject:number waitUntilDone:YES];
            }
            
            NSLog(@"Terminé de guardar toda la vaina");
            
            //Save all core data objects in our dictionary
            [projectDictionary setObject:self.projectDic[@"project"] forKey:@"project"];
            [projectDictionary setObject:rendersArray forKey:@"renders"];
            [projectDictionary setObject:urbanizationsArray forKey:@"urbanizations"];
            [projectDictionary setObject:groupsArray forKey:@"groups"];
            [projectDictionary setObject:floorsArray forKey:@"floors"];
            [projectDictionary setObject:producstArray forKey:@"products"];
            [projectDictionary setObject:plantsArray forKey:@"plants"];
            [projectDictionary setObject:spacesArray forKey:@"spaces"];
            [projectDictionary setObject:finishesArray forKey:@"finishes"];
            [projectDictionary setObject:finishesImagesArray forKey:@"finishImages"];
            
            [self performSelectorOnMainThread:@selector(finishSavingProcessOnMainThread:) withObject:projectDictionary waitUntilDone:NO];
        }];
        NSLog(@"me salí del bloqueee");
    }
}

-(void)finishSavingProcessOnMainThread:(NSDictionary *)projectDictionary {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadCompleted" object:nil userInfo:nil];
    [self goToPlanosVC];
}

/*-(void)databaseDocumentIsReadyForSaving {
    if (self.databaseDocument.documentState == UIDocumentStateNormal) {
        //Start using the document
        NSManagedObjectContext *context = self.databaseDocument.managedObjectContext;
        
        //Get the total number of files to download
        float filesDownloadedCounter = 0;
        float progressCompleted;
        float numberOfFiles = [self getNumberOfFilesToDownload];
        NSLog(@"Número de archivos a descargar: %f", numberOfFiles);
        
        //Dic to store all the core data objects and pass them to the next view controller
        NSMutableDictionary *projectDictionary = [[NSMutableDictionary alloc] init];
        
        //Save all the project info
        
        //Save render objects in core data
        NSMutableArray *rendersArray = [[NSMutableArray alloc] initWithCapacity:[self.rendersArray count]]; //Of Renders
        for (int i = 0; i < [self.rendersArray count]; i++) {
            NSDictionary *renderInfoDic = self.rendersArray[i];
            Render *render = [Render renderWithServerInfo:renderInfoDic inManagedObjectContext:context];
            [rendersArray addObject:render];
            
            filesDownloadedCounter ++;
            progressCompleted = filesDownloadedCounter / numberOfFiles;
            NSLog(@"progresooo: %f", progressCompleted);
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"fileDownloaded" object:nil userInfo:@{@"Progress": @(progressCompleted)}];
        }
        
        //Save urbanization object in core data
        NSMutableArray *urbanizationsArray = [[NSMutableArray alloc] init];
        Urbanization *urbanization = [Urbanization urbanizationWithServerInfo:self.urbanizationDic inManagedObjectContext:context];
        [urbanizationsArray addObject:urbanization];
        filesDownloadedCounter ++;
        progressCompleted = filesDownloadedCounter / numberOfFiles;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"fileDownloaded" object:nil userInfo:@{@"Progress": @(progressCompleted)}];
        
        //Save group objects in Core Data
        NSMutableArray *groupsArray = [[NSMutableArray alloc] initWithCapacity:[self.groupsArray count]];
        for (int i = 0; i < [self.groupsArray count]; i++) {
            Group *group = [Group groupWithServerInfo:self.groupsArray[i] inManagedObjectContext:context];
            [groupsArray addObject:group];
            
            filesDownloadedCounter ++;
            progressCompleted = filesDownloadedCounter / numberOfFiles;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"fileDownloaded" object:nil userInfo:@{@"Progress": @(progressCompleted)}];
        }
        
        //Save Floor products in Core Data
        NSMutableArray *floorsArray = [[NSMutableArray alloc] initWithCapacity:[self.floorsArray count]];
        for (int i = 0; i < [self.floorsArray count]; i++) {
            Floor *floor = [Floor floorWithServerInfo:self.floorsArray[i] inManagedObjectContext:context];
            [floorsArray addObject:floor];
            
            filesDownloadedCounter ++;
            progressCompleted = filesDownloadedCounter / numberOfFiles;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"fileDownloaded" object:nil userInfo:@{@"Progress": @(progressCompleted)}];
        }
        
        //Save product objects in Core Data
        NSMutableArray *producstArray = [[NSMutableArray alloc] initWithCapacity:[self.productsArray count]];
        for (int i = 0; i < [self.productsArray count]; i++) {
            Product *product = [Product productWithServerInfo:self.productsArray[i] inManagedObjectContext:context];
            [producstArray addObject:product];
            
            filesDownloadedCounter ++;
            progressCompleted = filesDownloadedCounter / numberOfFiles;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"fileDownloaded" object:nil userInfo:@{@"Progress": @(progressCompleted)}];
        }
        
        //Save plants objects in Core Data
        NSMutableArray *plantsArray = [[NSMutableArray alloc] initWithCapacity:[self.plantsArray count]];
        for (int i = 0; i < [self.plantsArray count]; i++) {
            Plant *plant = [Plant plantWithServerInfo:self.plantsArray[i] inManagedObjectContext:context];
            [plantsArray addObject:plant];
            
            filesDownloadedCounter ++;
            progressCompleted = filesDownloadedCounter / numberOfFiles;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"fileDownloaded" object:nil userInfo:@{@"Progress": @(progressCompleted)}];
        }
        
        //Save spaces object in Core Data
        NSMutableArray *spacesArray = [[NSMutableArray alloc] initWithCapacity:[self.spacesArray count]];
        for (int i = 0; i < [self.spacesArray count]; i++) {
            Space *space = [Space spaceWithServerInfo:self.spacesArray[i] inManagedObjectContext:context];
            [spacesArray addObject:space];
            
            filesDownloadedCounter ++;
            progressCompleted = filesDownloadedCounter / numberOfFiles;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"fileDownloaded" object:nil userInfo:@{@"Progress": @(progressCompleted)}];
        }
        
        //Save finishes in Core Data
        NSMutableArray *finishesArray = [[NSMutableArray alloc] initWithCapacity:[self.finishesArray count]];
        for (int i = 0; i < [self.finishesArray count]; i++) {
            Finish *finish = [Finish finishWithServerInfo:self.finishesArray[i] inManagedObjectContext:context];
            [finishesArray addObject:finish];
            
            filesDownloadedCounter ++;
            progressCompleted = filesDownloadedCounter / numberOfFiles;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"fileDownloaded" object:nil userInfo:@{@"Progress": @(progressCompleted)}];
        }
        
        //Save finishes images in Core Data
        NSMutableArray *finishesImagesArray = [[NSMutableArray alloc] initWithCapacity:[self.finishesImagesArray count]];
        for (int i = 0; i < [self.finishesImagesArray count]; i++) {
            FinishImage *finishImage = [FinishImage finishImageWithServerInfo:self.finishesImagesArray[i] inManagedObjectContext:context];
            [finishesImagesArray addObject:finishImage];
            
            filesDownloadedCounter ++;
            progressCompleted = filesDownloadedCounter / numberOfFiles;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"fileDownloaded" object:nil userInfo:@{@"Progress": @(progressCompleted)}];
        }
        
        //Save all core data objects in our dictionary
        [projectDictionary setObject:self.projectDic[@"project"] forKey:@"project"];
        [projectDictionary setObject:rendersArray forKey:@"renders"];
        [projectDictionary setObject:urbanizationsArray forKey:@"urbanizations"];
        [projectDictionary setObject:groupsArray forKey:@"groups"];
        [projectDictionary setObject:floorsArray forKey:@"floors"];
        [projectDictionary setObject:producstArray forKey:@"products"];
        [projectDictionary setObject:plantsArray forKey:@"plants"];
        [projectDictionary setObject:spacesArray forKey:@"spaces"];
        [projectDictionary setObject:finishesArray forKey:@"finishes"];
        [projectDictionary setObject:finishesImagesArray forKey:@"finishImages"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadCompleted" object:nil userInfo:nil];
        [self goToPlanosVC];
    }
}*/

-(NSUInteger)getNumberOfFilesToDownload {
    NSUInteger numberOfFiles = 0;
    numberOfFiles = [self.rendersArray count] + 1 + [self.groupsArray count] + [self.productsArray count] + [self.floorsArray count] + [self.plantsArray count] + [self.spacesArray count] + [self.finishesArray count] + [self.finishesImagesArray count];
    return numberOfFiles;
}

#pragma mark - ProyectoCollectionViewCellDelegate

-(void)zoomButtonTappedInCell:(ProyectoCollectionViewCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    ZoomViewController *zoomVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Zoom"];
    [self.navigationController.view.layer addAnimation:[NavAnimations navAlphaAnimation] forKey:nil];
    
    Render *render = self.projectDic[@"renders"][indexPath.item];
    zoomVC.zoomImage = [render renderImage];
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

#pragma mark - DownloadViewDelegate

-(void)cancelButtonWasTappedInDownloadView:(DownloadView *)downloadView {
    NSLog(@"*** Cancelé la download");
}

-(void)downloadViewWillDisappear:(DownloadView *)downloadView {
    self.opacityView.hidden = YES;
}

-(void)downloadViewDidDisappear:(DownloadView *)downloadView {
    self.opacityView.hidden = YES;
    self.downloadView.hidden = YES;
    self.downloadView.progress = 0;
    
}

@end
