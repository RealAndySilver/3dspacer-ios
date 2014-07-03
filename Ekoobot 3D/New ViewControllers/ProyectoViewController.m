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
#import "Video.h"
#import "VideoPlayerViewController.h"
#import "DownloadView.h"
#import "UIImage+Resize.h"

@interface ProyectoViewController () <UICollectionViewDataSource, UICollectionViewDelegate, ProyectoCollectionViewCellDelegate, ServerCommunicatorDelegate, DownloadViewDelegate, NSURLSessionDataDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) ProgressView *progressView;
@property (strong, nonatomic) UIWindow *secondWindow;
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

//UI Elements
@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) DownloadView *downloadView;
@property (strong, nonatomic) UILabel *tituloProyecto;
@property (strong, nonatomic) UIView *container;
@property (strong, nonatomic) UIButton *updateButton;
@property (strong, nonatomic) UIButton *sendInfoButton;
@property (strong, nonatomic) UIButton *slideshowButton;
@property (strong, nonatomic) UIButton *infoButton;
@property (strong, nonatomic) UIButton *enterButton;
@property (strong, nonatomic) UIImageView *logoImageView;
@property (strong, nonatomic) UIButton *videoButton;

@property (strong, nonatomic) NSDictionary *projectAnalyticsDic;
@property (strong, nonatomic) NSMutableData *receivedVideoData;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@end

@implementation ProyectoViewController {
    CGRect screenBounds;
    BOOL sendingAnalytics;
    long long expectedBytes;
    BOOL downloadVideo;
    BOOL projectIsOutdated;
    BOOL infoViewIsTransparent;
}

#pragma mark - Lazy Instantiation

-(NSMutableData *)receivedVideoData {
    if (!_receivedVideoData) {
        _receivedVideoData = [[NSMutableData alloc] initWithLength:0];
    }
    return _receivedVideoData;
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

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    projectIsOutdated = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OutdatedProjectNotificationReceived:)
                                                 name:@"OutdatedProjectNotification"
                                               object:nil];
    
    CGRect screen = [UIScreen mainScreen].bounds;
    screenBounds = CGRectMake(0.0, 0.0, screen.size.height, screen.size.width);
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabelWithTag:) name:@"updates" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertViewAppear) name:@"alert" object:nil];
    //[self performSelectorInBackground:@selector(saveProjectAttachedImages) withObject:nil];
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

-(void)setupUI {
    CGRect screenFrame = screenBounds;
    Project *project = self.projectDic[@"project"];
    
    CGRect updateButtonFrame;
    CGRect containerFrame;
    CGRect slideshowButtonFrame;
    CGRect sendInfoButtonFrame;
    CGRect infoButtonFrame;
    CGRect enterButtonFrame;
    CGRect videoButtonFrame;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        updateButtonFrame = CGRectMake(30, 100 ,50, 50);
        containerFrame = CGRectMake(70, 107, 265, 35);
        slideshowButtonFrame = CGRectMake(53, 540, 40, 40);
        videoButtonFrame = CGRectMake(53.0, 480.0, 40.0, 40.0);
        sendInfoButtonFrame = CGRectMake(53, 600, 40, 40);
        infoButtonFrame = CGRectMake(53, 660, 40, 40);
        enterButtonFrame = CGRectMake(830, 560,170, 170);

    } else {
        videoButtonFrame = CGRectMake(10.0, 120.0, 40.0, 40.0);
        updateButtonFrame = CGRectMake(10.0, 64.0, 40.0, 40.0);
        containerFrame = CGRectMake(40.0, 66.0, 260.0, 35.0);
        slideshowButtonFrame = CGRectMake(10.0, 170.0, 40.0, 40.0);
        sendInfoButtonFrame = CGRectMake(10.0, slideshowButtonFrame.origin.y + slideshowButtonFrame.size.height + 10.0, 40.0, 40.0);
        infoButtonFrame = CGRectMake(10.0, sendInfoButtonFrame.origin.y + sendInfoButtonFrame.size.height + 10.0, 40.0, 40.0);
        enterButtonFrame = CGRectMake(screenFrame.size.width - 70.0, screenFrame.size.height - 70.0, 60.0, 60.0);
    }
    
    //ProgressView
    /*self.progressView=[[ProgressView alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.height, self.navigationController.view.frame.size.width)];
    
    [self.navigationController.view addSubview:self.progressView];
    [self.view bringSubviewToFront:self.progressView];*/
    
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
    if ([project.enter boolValue]) {
        self.enterButton = [[UIButton alloc] initWithFrame:enterButtonFrame];
        [self.enterButton setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"BotonEntrar", nil)] forState:UIControlStateNormal];
        [self.enterButton addTarget:self action:@selector(showLoadingHUD) forControlEvents:UIControlEventTouchUpInside];
        self.enterButton.alpha = 1.0;
        [self.view addSubview:self.enterButton];
    }
    
    //Project Logo ImageView
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 140, 150, 150)];
        //Project *project = self.projectDic[@"project"];
        self.logoImageView.image = [project projectLogoImage];
        [self.view addSubview:self.logoImageView];
    }
    
    //UpdateButton Label
    self.container=[[UIView alloc]initWithFrame:containerFrame];
    self.container.backgroundColor=[UIColor colorWithWhite:0.2 alpha:1];
    self.container.alpha=0.8;
    self.container.layer.cornerRadius = 10.0;
    self.container.layer.shadowColor = [[UIColor colorWithWhite:0.1 alpha:1] CGColor];
    self.container.layer.shadowOffset = CGSizeMake(5.0f,5.0f);
    self.container.layer.shadowRadius = 5;
    self.container.layer.shadowOpacity = 1.0;
    
    self.tituloProyecto = [[UILabel alloc]initWithFrame:CGRectMake(10.0, 0.0, self.container.frame.size.width, self.container.frame.size.height)];
    self.tituloProyecto.text = project.name;
    self.tituloProyecto.backgroundColor=[UIColor clearColor];
    self.tituloProyecto.textColor=[UIColor whiteColor];
    self.tituloProyecto.adjustsFontSizeToFitWidth = YES;
    [self.tituloProyecto setFont:[UIFont fontWithName:@"Helvetica" size:26]];
    [self.container addSubview:self.tituloProyecto];
    [self.view addSubview:self.container];
    
    //UpdateButton
    self.updateButton = [[UIButton alloc] initWithFrame:updateButtonFrame];
    [self.updateButton setBackgroundImage:[UIImage imageNamed:@"NewUpdateIcon.jpg"] forState:UIControlStateNormal];
    [self.updateButton addTarget:self action:@selector(downloadProject) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.updateButton];
    
    //SendInfoButton
    self.sendInfoButton = [[UIButton alloc] initWithFrame:sendInfoButtonFrame];
    [self.sendInfoButton addTarget:self action:@selector(sendInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.sendInfoButton setImage:[UIImage imageNamed:@"msg.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.sendInfoButton];
    
    //Video Button
    if ([self.projectDic[@"videos"] count] > 0) {
        self.videoButton = [[UIButton alloc] initWithFrame:videoButtonFrame];
        [self.videoButton addTarget:self action:@selector(watchVideo) forControlEvents:UIControlEventTouchUpInside];
        [self.videoButton setBackgroundImage:[UIImage imageNamed:@"video2.png"] forState:UIControlStateNormal];
        [self.view addSubview:self.videoButton];
    }
    
    //Slideshow Button
    self.slideshowButton = [[UIButton alloc] initWithFrame:slideshowButtonFrame];
    [self.slideshowButton setImage:[UIImage imageNamed:NSLocalizedString(@"tv.png", nil)] forState:UIControlStateNormal];
    [self.slideshowButton addTarget:self action:@selector(goToSlideShow) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.slideshowButton];
    
    //Info button
    self.infoButton = [[UIButton alloc] initWithFrame:infoButtonFrame];
    [self.infoButton setBackgroundImage:[UIImage imageNamed:@"info_off.png"] forState:UIControlStateNormal];
    [self.infoButton setBackgroundImage:[UIImage imageNamed:@"info_on_new.png"] forState:UIControlStateHighlighted];
    [self.infoButton setBackgroundImage:[UIImage imageNamed:@"info_on_new.png"] forState:UIControlStateSelected];
    [self.infoButton addTarget:self action:@selector(showInfoView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.infoButton];
    
    //Info View setup
    infoViewIsTransparent = YES;
    self.infoView = [[InfoView alloc] initWithFrame:CGRectMake(self.infoButton.frame.origin.x + self.infoButton.frame.size.width/2.0, self.infoButton.frame.origin.y, 260.0, 40.0)];
    self.infoView.topLabelColor = [UIColor greenColor];
    self.infoView.alpha = 0.0;
    self.infoView.topLabel.text = NSLocalizedString(@"UltimaVersion", nil);
    NSString *updatedString = NSLocalizedString(@"ActualizadoEl", nil);
    self.infoView.bottomLabel.text = [NSString stringWithFormat:@"%@ %@", updatedString,project.lastUpdate];
    [self.view addSubview:self.infoView];
    [self.view bringSubviewToFront:self.infoButton];
    
    //Downloading View
    [self.view addSubview:self.opacityView];
    [self.navigationController.view addSubview:self.downloadView];
    self.opacityView.hidden = YES;
    self.downloadView.hidden = YES;
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.projectDic[@"renders"] count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProyectoCollectionViewCell *cell = (ProyectoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    cell.delegate = self;
    Render *render = self.projectDic[@"renders"][indexPath.item];
    cell.imageView.image = [render renderImage];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSUInteger currentCellIndex = 0;
    
    //NSLog(@"Terminé de mostrar la celda %d", indexPath.item);
    //NSLog(@"Número de celdas visibles: %d", [[collectionView visibleCells] count]);

    ((ProyectoCollectionViewCell *)cell).zoomScale = 1.0;
    ProyectoCollectionViewCell *currentCell = [[collectionView visibleCells] firstObject];
    NSUInteger newCellIndex = [self.collectionView indexPathForCell:currentCell].item;
    NSLog(@"Current Cell index: %d - New Cell index: %d", currentCellIndex, newCellIndex);
    
    if ((newCellIndex != currentCellIndex) && self.container.alpha == 0.0) {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^(){
                             self.container.alpha = 0.8;
                             self.tituloProyecto.alpha = 1.0;
                             self.updateButton.alpha = 1.0;
                             self.slideshowButton.alpha = 1.0;
                             self.sendInfoButton.alpha = 1.0;
                             self.infoButton.alpha = 1.0;
                             self.logoImageView.alpha = 1.0;
                             self.enterButton.alpha = 1.0;
                         } completion:^(BOOL finished){}];
    }
    currentCellIndex = newCellIndex;
}

#pragma mark - Actions

-(void)watchVideo {
    downloadVideo = YES;
    
    Video *video = [self.projectDic[@"videos"] firstObject];
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *videoFilePath = [docDir stringByAppendingPathComponent:video.videoPath];
    
    //Check if the video exist
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoFilePath]) {
        //The video exists
        NSLog(@"El video %@ del proyecto %@ existe", video.identifier, video.project);
        [self goToVideoPlayerWithVideoPath:videoFilePath];

    } else {
        //The video doesn't exist
        NSLog(@"El video %@ del proyecto %@ no existe", video.identifier, video.project);
        self.downloadView.hidden = NO;
        self.downloadView.downloadVideoButton.hidden = NO;
        self.downloadView.cancelButton.transform = CGAffineTransformMakeTranslation(40.0, 0.0);
        self.downloadView.descriptionLabel.text = NSLocalizedString(@"DescargandoVideo", nil);
        self.downloadView.progressLabel.hidden = YES;
        self.downloadView.progressView.hidden = YES;
        self.opacityView .hidden = NO;
        //[self downloadVideoWithNSUrlSession:video];
    }
}

#pragma mark - NSURLSessionDataDelegate

-(void)downloadVideoWithNSUrlSession:(Video *)video  {
    NSLog(@"Descargaré el proyecto en la url %@", video.url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:video.url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    [request setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.dataTask = [urlSession dataTaskWithRequest:request];
    [self.dataTask resume];
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSLog(@"Recibí respuesta del urlSession");
    expectedBytes = [response expectedContentLength];
    completionHandler(NSURLSessionResponseAllow);
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSLog(@"Recibí data");
    [self.receivedVideoData appendData:data];
    float downloadProgress = (float)[self.receivedVideoData length] / (float)expectedBytes;
    NSLog(@"Download progress: %f", downloadProgress);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fileDownloaded" object:nil userInfo:@{@"Progress": @(downloadProgress)}];
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (!error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadCompleted" object:nil userInfo:nil];
        Video *video = [self.projectDic[@"videos"] firstObject];
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *videoFilePath = [docDir stringByAppendingPathComponent:video.videoPath];
        
        NSLog(@"Terminé de descargar la data del video");
        [self saveVideoWithData:self.receivedVideoData inDocumentsDirPath:videoFilePath];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadCompleted" object:nil userInfo:nil];
    }
}

-(void)goToVideoPlayerWithVideoPath:(NSString *)videoFilePath {
    VideoPlayerViewController *videoPlayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
    videoPlayerVC.videoFilePath = videoFilePath;
    [self.navigationController pushViewController:videoPlayerVC animated:YES];
}

-(void)saveVideoWithData:(NSData *)videoData inDocumentsDirPath:(NSString *)path {
    if ([videoData writeToFile:path atomically:YES]) {
        [self goToVideoPlayerWithVideoPath:path];
    } else {
        NSLog(@"No se pudo guardar el video en documents dir");
    }
}

-(void)showInfoView {
    NSLog(@"toque el botoncito de info");
    if (infoViewIsTransparent) {
        self.infoButton.highlighted = YES;
        self.infoButton.selected = YES;
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^(){
                             self.infoView.alpha = 1.0;
                         } completion:^(BOOL finished){
                             infoViewIsTransparent = NO;
                         }];
    } else {
        self.infoButton.highlighted = NO;
        self.infoButton.selected = NO;
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^(){
                             self.infoView.alpha = 0.0;
                         } completion:^(BOOL finished){
                             infoViewIsTransparent = YES;
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

-(void)showLoadingHUD {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=NSLocalizedString(@"Cargando", nil);
    [self sendAnalytics];
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
    self.downloadView.descriptionLabel.text = NSLocalizedString(@"DescargandoProyecto", nil);
}

-(NSString *)generateProjectJSONString {
    //Generate date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSDate *date = [NSDate date];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    Project *project = self.projectDic[@"project"];
    NSDictionary *userDic = @{@"id": [UserInfo sharedInstance].userName};
    NSDictionary *projectIDDic = @{@"id": project.identifier};
    self.projectAnalyticsDic = @{@"user": userDic, @"project" : projectIDDic, @"date" : formattedDateString};
    
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if ([fileSaver getDictionary:@"ProjectAnalyticsDic"][@"ProjectAnalyticsArray"]) {
        NSMutableArray *projectsAnalyticsArray = [NSMutableArray arrayWithArray:[fileSaver getDictionary:@"ProjectAnalyticsDic"][@"ProjectAnalyticsArray"]];
        [projectsAnalyticsArray addObject:self.projectAnalyticsDic];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:projectsAnalyticsArray
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"Json String: %@", jsonString);
        return jsonString;
        
    } else {
        NSArray *projectArray = @[self.projectAnalyticsDic];
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
    sendingAnalytics = YES;
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *projectString = [self generateProjectJSONString];
    NSString *productString = nil;
    NSString *parameter = [NSString stringWithFormat:@"projectAnalytics=%@&productAnalytics=%@", projectString, productString];
    [serverCommunicator callServerWithPOSTMethod:@"setAnalytics" andParameter:parameter httpMethod:@"POST"];
}

-(void)downloadProject {
    downloadVideo = NO;
    
    [self showDownloadingView];
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    Project *project = self.projectDic[@"project"];
    NSString *projectID = [NSString stringWithFormat:@"%d", [project.identifier intValue]];
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"getProjectById" andParameter:projectID];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    sendingAnalytics = NO;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if ([methodName isEqualToString:@"getProjectById"]) {
        if (dictionary) {
            NSLog(@"Llegó respuesta del getProjectByID");
            if (dictionary[@"code"]) {
                NSLog(@"Ocurrió algún error y no se devolvió la info: %@", dictionary);
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
    } else if ([methodName isEqualToString:@"setAnalytics"]) {
        if (dictionary) {
            NSLog(@"Llegó respuesta correcta del analytics: %@", dictionary);
            //Remove the saved analytics in FileSaver
            FileSaver *fileSaver = [[FileSaver alloc] init];
            if ([fileSaver getDictionary:@"ProjectAnalyticsDic"][@"ProjectAnalyticsArray"]) {
                [fileSaver setDictionary:@{@"ProjectAnalyticsArray": @[]} withName:@"ProjectAnalyticsDic"];
            }

        } else {
            NSLog(@"No llegó respuesta del analytics: %@", dictionary);
        }
    }
}

-(void)serverError:(NSError *)error {
    NSLog(@"Server Error: %@ %@", error, [error localizedDescription]);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if (sendingAnalytics) {
        FileSaver *fileSaver = [[FileSaver alloc] init];
        if ([fileSaver getDictionary:@"ProjectAnalyticsDic"][@"ProjectAnalyticsArray"]) {
            NSLog(@"Ya existía el arreglo en file saver de projectsAnalytics");
            NSMutableArray *projectsAnalyticsArray = [NSMutableArray arrayWithArray:[fileSaver getDictionary:@"ProjectAnalyticsDic"][@"ProjectAnalyticsArray"]];
            [projectsAnalyticsArray addObject:self.projectAnalyticsDic];
            [fileSaver setDictionary:@{@"ProjectAnalyticsArray": projectsAnalyticsArray} withName:@"ProjectAnalyticsDic"];
            
        } else {
            NSLog(@"No existía en file saver el arreglo de analytics, asi que lo crearé");
            NSArray *projectsAnalyticsArray = @[self.projectAnalyticsDic];
            [fileSaver setDictionary:@{@"ProjectAnalyticsArray": projectsAnalyticsArray} withName:@"ProjectAnalyticsDic"];
        }
        sendingAnalytics = NO;
        
    } else {
        self.downloadView.hidden = YES;
        self.opacityView.hidden = YES;
        [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
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
            NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];

            for (int i = 0; i < [self.finishesImagesArray count]; i++) {
                FinishImage *finishImage = [FinishImage finishImageWithServerInfo:self.finishesImagesArray[i] inManagedObjectContext:context];
                [context save:NULL];
                [finishesImagesArray addObject:finishImage];
                
                //Save image in documents directory
                NSString *jpegFilePath = [docDir stringByAppendingPathComponent:finishImage.imagePath];
                [self saveFinishImage:finishImage atPath:jpegFilePath];
                //[self saveImageInDocumentsDirectoryAtPath:jpegFilePath usingImageURL:finishImage.imageURL];
                
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

-(void)saveFinishImage:(FinishImage *)finishImage atPath:(NSString *)jpegFilePath {
    NSLog(@"Entré a guardar la imagen");
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    if (!fileExist) {
        NSLog(@"La imagen no existía en documents directory, así que la guardaré");
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:finishImage.imageURL]];
        
        if ([finishImage.imageURL rangeOfString:@".jpg"].location == NSNotFound) {
            //PVR Image
            NSLog(@"Guardando imagen PVR");
            [data writeToFile:jpegFilePath atomically:YES];
        } else {
            //JPG Image
            UIImage *image = [UIImage imageWithData:data];
            if ([finishImage.finalSize intValue] != [finishImage.size intValue]) {
                UIImage *newImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake([finishImage.finalSize intValue], [finishImage.finalSize intValue])];
                NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(newImage, 1.0)];
                [imageData writeToFile:jpegFilePath atomically:YES];
                
            } else {
                NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
                [imageData writeToFile:jpegFilePath atomically:YES];
            }
        }
        
    } else {
        NSLog(@"La imagen ya existía, así que no la guardé en documents directory");
    }
}

/*-(void)saveImageInDocumentsDirectoryAtPath:(NSString *)jpegFilePath usingImageURL:(NSString *)finishImageURL {
    NSLog(@"Entré a guardar la imagen");
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    if (!fileExist) {
        NSLog(@"La imagen no existía en documents directory, así que la guardaré");
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:finishImageURL]];
        
        if ([finishImageURL rangeOfString:@".jpg"].location == NSNotFound) {
            //PVR Image
            [data writeToFile:jpegFilePath atomically:YES];
        } else {
            //JPG Image
            UIImage *image = [UIImage imageWithData:data];
            //UIImage *newImage = [self transformImage:image positionInCube:position];
            NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
            [imageData writeToFile:jpegFilePath atomically:YES];
        }
        
    } else {
        NSLog(@"La imagen ya existía, así que no la guardé en documents directory");
    }
}*/

-(void)finishSavingProcessOnMainThread:(NSDictionary *)projectDictionary {
    Project *project = self.projectDic[@"project"];
    
    if (projectIsOutdated) {
        FileSaver *fileSaver = [[FileSaver alloc] init];
        NSMutableArray *savedProjectIDs = [fileSaver getDictionary:@"downloadedProjectsIDs"][@"projectIDsArray"];
        if (![savedProjectIDs containsObject:project.identifier]) {
            NSLog(@"*********************************** Volveré a agregar este proyecto a file saver");
            [savedProjectIDs addObject:project.identifier];
            [fileSaver setDictionary:@{@"projectIDsArray": savedProjectIDs} withName:@"downloadedProjectsIDs"];
            
            //Post a notification to update the carousel view controller, because we updated a project
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ProjectUpdatedNotification" object:nil];
        }
        projectIsOutdated = NO;
        
        //Change the info view text
        self.infoView.topLabel.text = NSLocalizedString(@"UltimaVersion", nil);
        self.infoView.topLabel.textColor = [UIColor greenColor];
        NSString *updatedString = NSLocalizedString(@"ActualizadoEl", nil);
        self.infoView.bottomLabel.text = [NSString stringWithFormat:@"%@ %@", updatedString, project.lastUpdate];
        self.enterButton.hidden = NO;
    }
    
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

-(void)cellIsAtInitialZoomScale:(ProyectoCollectionViewCell *)cell {
    if (self.container.alpha == 0.0) {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^(){
                             self.container.alpha = 0.8;
                             self.tituloProyecto.alpha = 1.0;
                             self.updateButton.alpha = 1.0;
                             self.slideshowButton.alpha = 1.0;
                             self.sendInfoButton.alpha = 1.0;
                             self.infoButton.alpha = 1.0;
                             self.logoImageView.alpha = 1.0;
                             self.enterButton.alpha = 1.0;
                             self.videoButton.alpha = 1.0;
                             if (!infoViewIsTransparent) self.infoView.alpha = 1.0;
                         } completion:^(BOOL finished){}];
    }
}

-(void)cellIsZoomed:(ProyectoCollectionViewCell *)cell {
    NSLog(@"recibí el delegate de proyectoCollectionVIewCell");
    if (self.container.alpha != 0.0) {
        NSLog(@"entré a ocultar el container");
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^(){
                             self.container.alpha = 0.0;
                             self.tituloProyecto.alpha = 0.0;
                             self.updateButton.alpha = 0.0;
                             self.slideshowButton.alpha = 0.0;
                             self.sendInfoButton.alpha = 0.0;
                             self.infoButton.alpha = 0.0;
                             self.logoImageView.alpha = 0.0;
                             self.enterButton.alpha = 0.0;
                             self.videoButton.alpha = 0.0;
                             self.infoView.alpha = 0.0;
                         } completion:^(BOOL finished){}];
    } else {
        NSLog(@"No oculté el container");
    }
}

/*-(void)zoomButtonTappedInCell:(ProyectoCollectionViewCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    ZoomViewController *zoomVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Zoom"];
    [self.navigationController.view.layer addAnimation:[NavAnimations navAlphaAnimation] forKey:nil];
    
    Render *render = self.projectDic[@"renders"][indexPath.item];
    zoomVC.zoomImage = [render renderImage];
    [self.navigationController pushViewController:zoomVC animated:NO];
}*/

#pragma mark - Notification Handlers

/*-(void)updateLabelWithTag:(NSNotification *)notification {
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
}*/

#pragma mark - Notification Handlers 

-(void)OutdatedProjectNotificationReceived:(NSNotification *)notification {
    NSLog(@"**************************** Me llegó la notificación de proyecto desactualizado ************************************");
    Project *project = self.projectDic[@"project"];
    
    NSDictionary *infoDic = [notification userInfo];
    NSNumber *outdatedProjectID = infoDic[@"OutdatedProjectIdentifier"];
    if ([outdatedProjectID intValue] == [project.identifier intValue]) {
        NSLog(@"************************************ Este proyecto está desactualizado ********************************************");
        //This project is outdated, so hidde the "enter button" and
        //update the info view
        self.enterButton.hidden = YES;
        self.infoView.topLabel.textColor = [UIColor redColor];
        self.infoView.topLabel.text = NSLocalizedString(@"NuevaVersion", nil);
        self.infoView.bottomLabel.text = NSLocalizedString(@"Descarga", nil);
        [[[UIAlertView alloc] initWithTitle:@"Nueva actualización" message:@"Existe una nueva actualización disponible para este proyecto." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        
        projectIsOutdated = YES;
    }
}

#pragma mark - DownloadViewDelegate

-(void)downloadVideoButtonWasTappedInDownloadView:(DownloadView *)downloadView {
    NSLog(@"descargaréeeeeee");
    Video *video = [self.projectDic[@"videos"] firstObject];
    downloadView.progressLabel.hidden = NO;
    downloadView.progressView.hidden = NO;
    [self downloadVideoWithNSUrlSession:video];
}

-(void)cancelButtonWasTappedInDownloadView:(DownloadView *)downloadView {
    NSLog(@"*** Cancelé la download");
    if (downloadVideo) {
        [self.dataTask cancel];
        self.receivedVideoData = nil;
    }
    
    self.opacityView.hidden = YES;
    self.downloadView.hidden = YES;
    self.downloadView.progress = 0;
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
