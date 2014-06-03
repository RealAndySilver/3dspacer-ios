//
//  PlantaUrbanaGeneralVC.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 4/19/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import "PlantaUrbanaVC.h"
#import "GLKitSpaceViewController.h"
#import "PlanosDePisoViewController.h"
#import "PlanosDePlantaViewController.h"
#import "Urbanization+AddOns.h"
#import "Group.h"
#import "Floor.h"
#import "Product.h"
#import "Plant.h"
#import "Space.h"
#import "CMMotionManager+Shared.h"

@interface PlantaUrbanaVC ()
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) NSMutableArray *commonSpacesArray;
@end

@implementation PlantaUrbanaVC

@synthesize scrollViewUrbanismo;

-(NSMutableArray *)commonSpacesArray {
    if (!_commonSpacesArray) {
        _commonSpacesArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.projectDic[@"spaces"] count]; i++) {
            Space *space = self.projectDic[@"spaces"][i];
            if ([space.common boolValue]) {
                [_commonSpacesArray addObject:space];
            }
        }
    }
    return _commonSpacesArray;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    NSLog(@"Entré a PlantaUrbanaVC");
    
    NavController *navController = (NavController *)self.navigationController;
    [navController setInterfaceOrientation:YES];
    self.automaticallyAdjustsScrollViewInsets=NO;

    self.navigationItem.title = NSLocalizedString(@"PlantaUrbana", nil);
    maximumZoomScale=2.0;
    minimumZoomScale=0.3;
    [spinner startAnimating];
    [self loadScrollViewWithMap];
    
    zoomCheck=YES;
    // Do any additional setup after loading the view.
}

- (void)viewDidUnload{
    [super viewDidUnload];
    //proyecto=nil;
    scrollViewUrbanismo=nil;
    imageViewUrbanismo=nil;
    spinner=nil;
    // Release any retained subviews of the main view.
}
-(void)didReceiveMemoryWarning{
    //NSLog(@"PlantaUrbana Warning %@",proyecto.arrayItemsUrbanismo);
    //[self crearObjetos];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    spinner.alpha=0.0;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [spinner stopAnimating];
    [self.view sendSubviewToBack:spinner];
    //_motionManager.showsDeviceMovementDisplay = NO;
    self.motionManager.showsDeviceMovementDisplay = NO;
    [self.motionManager stopDeviceMotionUpdates];
    [timer invalidate];
    brujula.alpha=0;
    brujula=nil;
    timer = nil;
    attitude=nil;
    NavController *navController = (NavController *)self.navigationController;
    [navController setInterfaceOrientation:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //NSMutableArray *tempArray=proyecto.arrayItemsUrbanismo;
    //ItemUrbanismo *itemUrbanismo=[tempArray objectAtIndex:0];
    Urbanization *urbanization = [self.projectDic[@"urbanizations"] firstObject];
    adicionalGrados=DegreesToRadians([urbanization.northDegrees floatValue]);
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if(orientation ==3){
            NSLog(@"OrientacionLandscape numero %i",orientation);
            diferenciaRotacion=0;
        }
        else if(orientation==4){
            NSLog(@"OrientacionLandscapeElse numero %i",orientation);
            diferenciaRotacion=0.5;
        }
    }
    NSLog(@"Diferencia norte= %f",([urbanization.northDegrees floatValue]/360));
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [scrollViewUrbanismo setZoomScale:minimumZoomScale animated:NO];
    
    self.motionManager = [CMMotionManager sharedMotionManager];
    if (self.motionManager.deviceMotionAvailable) {
        self.motionManager.deviceMotionUpdateInterval = 1.0/30.0;
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical toQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error){
            [self update];
        }];
    }
    
    /*_motionManager = [self motionManager];
    
    [_motionManager setDeviceMotionUpdateInterval:1/60];
    [_motionManager startDeviceMotionUpdates];
    [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical];
    
    timer=[[NSTimer alloc]init];
    timer =[NSTimer scheduledTimerWithTimeInterval:1/60 target:self selector:@selector(update) userInfo:nil repeats:YES];*/
    
    if (self.motionManager.magnetometerAvailable) {
        NSLog(@"El magnetómetro está disponible entonces mostraré la brújula");
        brujula=[[BrujulaView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-90, 80, 70, 70)];
        [self.view addSubview:brujula];
        [brujula changeState];
    } else {
        NSLog(@"El magnetómetro no está disponible, así que no mostraré la brújula");
    }
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //[scrollViewUrbanismo setZoomScale:0.3 animated:NO];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || 
    (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)loadScrollViewWithMap{
    //NSMutableArray *tempArray=proyecto.arrayItemsUrbanismo;
    //ItemUrbanismo *itemUrbanismo=[tempArray objectAtIndex:0];
    Urbanization *urbanization = [self.projectDic[@"urbanizations"] firstObject];
    imageViewUrbanismo=[[UIImageView alloc]initWithImage:[urbanization urbanizationImage]];
    if (imageViewUrbanismo.frame.size.width<self.view.frame.size.height) {
        float ancho=imageViewUrbanismo.frame.size.width;
        float alto=imageViewUrbanismo.frame.size.height;
        float proporcion=0;
        if (ancho<alto) {
            proporcion=alto/ancho;
        }
        else{
            proporcion=ancho/alto;
        }
        imageViewUrbanismo.frame=CGRectMake(0, 0, ([urbanization urbanizationImage].size.width*1), ([urbanization urbanizationImage].size.height*1));
        minimumZoomScale=0.6;
        NSLog(@"width %.0f height %.0f",imageViewUrbanismo.frame.size.width,imageViewUrbanismo.frame.size.height);
    }
    
    NSMutableArray *arrayGrupos = self.projectDic[@"groups"];
    
    
    scrollViewUrbanismo=[[UIScrollView alloc]init];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [scrollViewUrbanismo addGestureRecognizer:doubleTap];
    /*NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/imagenUrbanismo%@.jpeg",docDir,itemUrbanismo.idUrbanismo];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    if (!fileExists) {
        NSLog(@"no existe %@",jpegFilePath);
        NSURL *urlImagenUrbanismo=[NSURL URLWithString:itemUrbanismo.imagenUrbanismo];
        NSData *dataImagenUrbanismo=[NSData dataWithContentsOfURL:urlImagenUrbanismo];
        UIImage *imageUrbanismo=[UIImage imageWithData:dataImagenUrbanismo];
        NSLog(@"width %.0f height %.0f",imageUrbanismo.size.width,imageUrbanismo.size.height);
        NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(imageUrbanismo, 1.0f)];//1.0f = 100% quality
        if (imageUrbanismo) {
            [data2 writeToFile:jpegFilePath atomically:YES];
        }
        imageViewUrbanismo=[[UIImageView alloc]initWithImage:[UIImage imageWithData:data2]];
        if (imageViewUrbanismo.frame.size.width<self.view.frame.size.height) {
            float ancho=imageViewUrbanismo.frame.size.width;
            float alto=imageViewUrbanismo.frame.size.height;
            float proporcion=0;
            if (ancho<alto) {
                proporcion=alto/ancho;
            }
            else{
                proporcion=ancho/alto;
            }
            imageViewUrbanismo.frame=CGRectMake(0, 0, (imageUrbanismo.size.width*1), (imageUrbanismo.size.height*1));
            minimumZoomScale=0.6;
            NSLog(@"width %.0f height %.0f",imageViewUrbanismo.frame.size.width,imageViewUrbanismo.frame.size.height);
        }
    }
    
    else{
        //NSLog(@"si existe");
        UIImage *imageUrbanismo=[UIImage imageWithContentsOfFile:jpegFilePath];
        NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(imageUrbanismo, 1.0f)];
        //imageViewUrbanismo=[[UIImageView alloc]initWithImage:imageUrbanismo];
        imageViewUrbanismo=[[UIImageView alloc]initWithImage:[UIImage imageWithData:data2]];
        if (imageViewUrbanismo.frame.size.width<1024) {
            float ancho=imageViewUrbanismo.frame.size.width;
            float alto=imageViewUrbanismo.frame.size.height;
            float proporcion=0;
            if (ancho<alto) {
                proporcion=alto/ancho;
            }
            else{
                proporcion=ancho/alto;
            }
            imageViewUrbanismo.frame=CGRectMake(0, 0, (imageUrbanismo.size.width*1), (imageUrbanismo.size.height*1));
            minimumZoomScale=0.6;
            NSLog(@"width %.0f height %.0f",imageViewUrbanismo.frame.size.width,imageViewUrbanismo.frame.size.height);
        }
    }*/
    
    //Crear todos los botones de los items del urbanismo
    [imageViewUrbanismo setUserInteractionEnabled:YES];
    
    //imageViewUrbanismo.center=CGPointMake(self.view.frame.size.height/2, self.view.frame.size.width/2);
    scrollViewUrbanismo.frame=CGRectMake(0, 20, self.view.frame.size.height, self.view.frame.size.width-44);
    scrollViewUrbanismo.contentSize=CGSizeMake(imageViewUrbanismo.frame.size.width, imageViewUrbanismo.frame.size.height);
    //[self layoutScrollView];
    [self.view addSubview:scrollViewUrbanismo];
    [scrollViewUrbanismo setShowsVerticalScrollIndicator:NO];
    [scrollViewUrbanismo setShowsHorizontalScrollIndicator:NO];
    [scrollViewUrbanismo addSubview:imageViewUrbanismo];
    for (int i=0; i<[arrayGrupos count]; i++) {
        //Grupo *grupo=[arrayGrupos objectAtIndex:i];
        Group *group = arrayGrupos[i];
        [self insertarBotonEn:imageViewUrbanismo enPosicionX:[group.xCoord description] yPosicionY:[group.yCoord description] yTag:i titulo:group.name];
    }
    
    for (int i = 0; i < [self.commonSpacesArray count]; i++) {
        Space *space = self.commonSpacesArray[i];
        [self insertarAreaComunEn:imageViewUrbanismo enPosicionX:[space.xCoord description] posicionY:[space.yCoord description] tag:1000+i titulo:space.name];
    }
    [scrollViewUrbanismo setMinimumZoomScale:minimumZoomScale];
    [scrollViewUrbanismo setMaximumZoomScale:maximumZoomScale];
    [scrollViewUrbanismo setCanCancelContentTouches:NO];
    scrollViewUrbanismo.clipsToBounds = NO;
    [scrollViewUrbanismo scrollRectToVisible:CGRectMake(imageViewUrbanismo.frame.size.width/2, scrollViewUrbanismo.frame.size.height/2, scrollViewUrbanismo.frame.size.width/2, imageViewUrbanismo.frame.size.height/2) animated:YES];
    
    [scrollViewUrbanismo setDelegate:self];
    
}

-(void)insertarAreaComunEn:(UIView *)view enPosicionX:(NSString *)posX posicionY:(NSString *)posY tag:(int)tag titulo:(NSString *)titulo {
    UIButton *boton = [[UIButton alloc]init];
    UIImage *imageButton = [UIImage imageNamed:@"pin.png"];
    boton.tag=tag;
    float buttonSize=60;
    [boton setImage:imageButton forState:UIControlStateNormal];
    [boton addTarget:self action:@selector(irAEscena3D:) forControlEvents:UIControlEventTouchUpInside];
    int posXint=[posX intValue];
    int posYint=[posY intValue];
    boton.frame=CGRectMake(posXint-(buttonSize/2), posYint-buttonSize,buttonSize, buttonSize);
    [self agregarLabelAlLadoDelBotonEnView:view enPosicionX:posXint yPosicionY:posYint conTitulo:titulo];
    [view addSubview:boton];
    [view bringSubviewToFront:boton];
}

-(void)update{
    if (brujula.isOn) {
        NavController *navController = (NavController *)self.navigationController;
        [navController setInterfaceOrientation:NO];
        //_motionManager.showsDeviceMovementDisplay = YES;
        self.motionManager.showsDeviceMovementDisplay = YES;
        //attitude = _motionManager.deviceMotion.attitude;
        attitude = self.motionManager.deviceMotion.attitude;
        CGAffineTransform swingTransform = CGAffineTransformIdentity;
        swingTransform = CGAffineTransformRotate(swingTransform, [self radiansToDegrees:DegreesToRadians(attitude.yaw)+diferenciaRotacion]-adicionalGrados);
        CGAffineTransform swingTransform2 = CGAffineTransformIdentity;
        swingTransform2 = CGAffineTransformRotate(swingTransform2, [self radiansToDegrees:DegreesToRadians(attitude.yaw)+diferenciaRotacion]);
        scrollViewUrbanismo.transform = swingTransform;
        brujula.cursor.transform = swingTransform2;
    }
    else{
        NavController *navController = (NavController *)self.navigationController;
        [navController setInterfaceOrientation:YES];
        //_motionManager.showsDeviceMovementDisplay = NO;
        self.motionManager.showsDeviceMovementDisplay = NO;
        CGAffineTransform swingTransform = CGAffineTransformIdentity;
        swingTransform = CGAffineTransformRotate(swingTransform, [self radiansToDegrees:DegreesToRadians(0)]);
        scrollViewUrbanismo.transform = swingTransform;
        brujula.cursor.transform = swingTransform;
    }
    
}
- (float)radiansToDegrees:(float)number{
    return  number * 57.295780;
}
/*-(CMMotionManager *)motionManager{
    CMMotionManager *motionManager = nil;
    id appDelegate = [UIApplication sharedApplication].delegate;
    if ([appDelegate respondsToSelector:@selector(motionManager)]) {
        motionManager = [appDelegate motionManager];
    }
    return motionManager;
}*/
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *subView = [scrollView.subviews objectAtIndex:0];
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    scrollView.contentInset = UIEdgeInsetsZero;
}
-(UIView *)viewForZoomingInScrollView:(UIScrollView*)scrollview{
    return imageViewUrbanismo;
}
-(void)insertarBotonEn:(UIView*)view enPosicionX:(NSString*)posX yPosicionY:(NSString*)posY yTag:(int)tag titulo:(NSString*)eltitulo{
    UIButton *boton = [[UIButton alloc]init];
    UIImage *imageButton = [UIImage imageNamed:@"pin.png"];
    boton.tag=tag;
    float buttonSize=60;
    [boton setImage:imageButton forState:UIControlStateNormal];
    [boton addTarget:self action:@selector(irAlSiguienteViewController:) forControlEvents:UIControlEventTouchUpInside];
    int posXint=[posX intValue];
    int posYint=[posY intValue];
    boton.frame=CGRectMake(posXint-(buttonSize/2), posYint-buttonSize,buttonSize, buttonSize);
    [self agregarLabelAlLadoDelBotonEnView:view enPosicionX:posXint yPosicionY:posYint conTitulo:eltitulo];
    [view addSubview:boton];
    [view bringSubviewToFront:boton];
}
-(void)agregarLabelAlLadoDelBotonEnView:(UIView*)view enPosicionX:(int)posX yPosicionY:(int)posY conTitulo:(NSString*)titulo{
    //Tamaño del texto
    CGFloat constrainedSize = 1000.0f;
    //UIFont * font = [UIFont fontWithName:@"Helvetica" size:22];
    UIFont * font = [UIFont boldSystemFontOfSize:22];

    CGSize textSize = [titulo sizeWithFont: font
                         constrainedToSize:CGSizeMake(constrainedSize, CGFLOAT_MAX)
                             lineBreakMode:UILineBreakModeWordWrap];
    float buttonSize=60;
    UIView *container=[[UIView alloc]init];
    container.frame=CGRectMake(posX+25, posY-(buttonSize/1.3),textSize.width+20, 28);
    container.backgroundColor=[UIColor clearColor];
    [view addSubview:container];
    UIView *lowAlphaView=[[UIView alloc]init];
    lowAlphaView.frame=CGRectMake(0, 0, container.frame.size.width, container.frame.size.height);
    lowAlphaView.backgroundColor=[UIColor clearColor];
    lowAlphaView.alpha=0.5;
    [container addSubview:lowAlphaView];
    
    UILabel *label=[[UILabel alloc]init];
    label.font=font;
    label.frame=CGRectMake(10, 2,textSize.width, 24);
    label.text=titulo;
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(1, 1);
    [label setAdjustsFontSizeToFitWidth:YES];
    label.textColor=[UIColor whiteColor];
    label.backgroundColor=[UIColor clearColor];
    [container addSubview:label];
}

-(void)irAEscena3D:(UIButton *)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self performSelector:@selector(goToGLKView:) withObject:sender afterDelay:0.3];
}

-(void)goToGLKView:(UIButton *)sender {
    GLKitSpaceViewController *glkitSpaceVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GLKitSpace"];
    glkitSpaceVC.espacioSeleccionado = 0;
    Space *space = self.commonSpacesArray[sender.tag - 1000];
    glkitSpaceVC.arregloDeEspacios3D= [NSMutableArray arrayWithObject:space];
    glkitSpaceVC.projectDic = self.projectDic;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.navigationController pushViewController:glkitSpaceVC animated:YES];
}

-(void)irAlSiguienteViewController:(UIButton*)sender{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=NSLocalizedString(@"Cargando", nil);
    [self performSelector:@selector(delayedAction:) withObject:sender afterDelay:0.3];
        
    //NSLog(@"hecho por acá");
}
-(void)delayedAction:(UIButton*)sender{
    /*ItemUrbanismo *itemUrbanismo=[proyecto.arrayItemsUrbanismo objectAtIndex:0];
    Grupo *grupo=[itemUrbanismo.arrayGrupos objectAtIndex:sender.tag];
    NSString *string =grupo.idGrupo;*/
    
    Urbanization *urbanization = [self.projectDic[@"urbanizations"] firstObject];
    Group *group = self.projectDic[@"groups"][sender.tag];
    NSString *string = group.identifier;

    if ([string rangeOfString:@"Urbanizationspaces"].location != NSNotFound) {
        NSLog(@"voy pa espacios...");
        
        //Get the first floor of the group
        Floor *floor;
        for (int i = 0; i < [self.projectDic[@"floors"] count]; i++) {
            floor = self.projectDic[@"floors"][i];
            if ([floor.group isEqualToString:group.identifier]) {
                break;
            }
        }
        
        //Get te first product of the floor
        Product *product;
        for (int i = 0; i < [self.projectDic[@"products"] count]; i++) {
            product = self.projectDic[@"products"][i];
            if ([product.floor isEqualToString:floor.identifier]) {
                break;
            }
        }
        
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
        
        GLKitSpaceViewController *glkKitSpaceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GLKitSpace"];
        glkKitSpaceViewController.arregloDeEspacios3D = spacesArrayForPlant;
        glkKitSpaceViewController.projectDic = self.projectDic;
        glkKitSpaceViewController.espacioSeleccionado = 0;
        [self.navigationController pushViewController:glkKitSpaceViewController animated:YES];
        
       /* TipoDePiso *tipoDePiso = grupo.arrayTiposDePiso[0];
        Producto *producto = tipoDePiso.arrayProductos[0];
        Planta *planta = producto.arrayPlantas[0];
        
        GLKitSpaceViewController *glkKitSpaceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GLKitSpace"];
        glkKitSpaceViewController.arregloDeEspacios3D = planta.arrayEspacios3D;
        [self.navigationController pushViewController:glkKitSpaceViewController animated:YES];*/
    }
    else {
        if ([group.enabled boolValue]) {
            Floor *floor = [self.projectDic[@"floors"] firstObject];
            if ([floor.enabled boolValue]) {
                PlanosDePisoViewController *planosDePisoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PlanosDePiso"];
                planosDePisoVC.projectDic = self.projectDic;
                planosDePisoVC.group = group;
                [self.navigationController pushViewController:planosDePisoVC animated:YES];
            
            } else {
                //Get the first product of the floor
                Product *product;
                for (int i = 0; i < [self.projectDic[@"products"] count]; i++) {
                    product = self.projectDic[@"products"][i];
                    if ([product.floor isEqualToString:floor.identifier]) {
                        break;
                    }
                }
                PlanosDePlantaViewController *planosDePlantaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PlanosDePlanta"];
                planosDePlantaVC.product = product;
                planosDePlantaVC.projectDic = self.projectDic;
                [self.navigationController pushViewController:planosDePlantaVC animated:YES];
            }
            /*TipoDePiso *tipoDePiso=[grupo.arrayTiposDePiso objectAtIndex:0];
            if (tipoDePiso.existe) {
                PlanosDePisoViewController *planosDePisoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PlanosDePiso"];
                planosDePisoVC.grupo = grupo;
                [self.navigationController pushViewController:planosDePisoVC animated:YES];
            }
            else {
                Producto *producto = tipoDePiso.arrayProductos[0];
                PlanosDePlantaViewController *planosDePlantaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PlanosDePlanta"];
                planosDePlantaVC.producto = producto;
                [self.navigationController pushViewController:planosDePlantaVC animated:YES];
            }*/
            
        
        } else{
            //Get the first floor of the group
            Floor *floor;
            for (int i = 0; i < [self.projectDic[@"floors"] count]; i++) {
                floor = self.projectDic[@"floors"][i];
                if ([floor.group isEqualToString:group.identifier]) {
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
            
            if ([product.enabled boolValue]) {
                PlanosDePlantaViewController *planosDePlantaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PlanosDePlanta"];
                planosDePlantaVC.product = product;
                planosDePlantaVC.projectDic = self.projectDic;
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
                
                //Get spaces array for the plant
                NSMutableArray *spacesArrayForPlant = [[NSMutableArray alloc] init];
                for (int i = 0; i < [self.projectDic[@"spaces"] count]; i++) {
                    Space *space = self.projectDic[@"spaces"][i];
                    if ([space.plant isEqualToString:plant.identifier]) {
                        [spacesArrayForPlant addObject:space];
                    }
                }
                GLKitSpaceViewController *glkitSpaceVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GLKitSpace"];
                glkitSpaceVC.arregloDeEspacios3D = spacesArrayForPlant;
                glkitSpaceVC.projectDic = self.projectDic;
                glkitSpaceVC.espacioSeleccionado = 0;
                [self.navigationController pushViewController:glkitSpaceVC animated:YES];
            }
            
           /* TipoDePiso *tipoDePiso=[grupo.arrayTiposDePiso objectAtIndex:0];
            Producto *producto=[tipoDePiso.arrayProductos objectAtIndex:0];
            //TiposDePlantasVC *tpVC=[[TiposDePlantasVC alloc]init];
            
            if (producto.existe) {
                PlanosDePlantaViewController *planosDePlantaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PlanosDePlanta"];
                planosDePlantaVC.producto = producto;
                [self.navigationController pushViewController:planosDePlantaVC animated:YES];
            }
            else {
                Planta *planta = producto.arrayPlantas[0];
                GLKitSpaceViewController *glkitSpaceVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GLKitSpace"];
                glkitSpaceVC.arregloDeEspacios3D = planta.arrayEspacios3D;
                [self.navigationController pushViewController:glkitSpaceVC animated:YES];
            }*/
        }
    }
}
- (void)loadViewWithSpinner{
    [spinner startAnimating];
    spinner.alpha=1.0;
    [self.view bringSubviewToFront:spinner];
}


- (void)handleDoubleTap:(UIGestureRecognizer *)recognizer {
    NSLog(@"doubletap ");
    if(zoomCheck){
        CGPoint Pointview=[recognizer locationInView:scrollViewUrbanismo];
        CGFloat newZoomscal=maximumZoomScale;
        
        newZoomscal=MIN(newZoomscal, maximumZoomScale);
        
        CGSize scrollViewSize=scrollViewUrbanismo.bounds.size;
        
        CGFloat w=scrollViewSize.width/newZoomscal;
        CGFloat h=scrollViewSize.height /newZoomscal;
        CGFloat x= Pointview.x-(w/2.0);
        CGFloat y = Pointview.y-(h/2.0);
        
        CGRect rectTozoom=CGRectMake(x, y, w, h);
        [scrollViewUrbanismo zoomToRect:rectTozoom animated:YES];
        
        [scrollViewUrbanismo setZoomScale:maximumZoomScale animated:YES];
        zoomCheck=NO;
    }
    else{
        [scrollViewUrbanismo setZoomScale:1.0 animated:YES];
        zoomCheck=YES;
    }
}

@end
