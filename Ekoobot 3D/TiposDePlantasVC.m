//
//  TiposDePlantasVC.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 6/19/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import "TiposDePlantasVC.h"

@interface TiposDePlantasVC ()

@end

@implementation TiposDePlantasVC

@synthesize producto;
@synthesize pageCon;

#pragma mark -
#pragma mark Ciclo de Vida

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Se cargan y muestran todos los proyectos
    arrayNombresPlantas=[[NSMutableArray alloc]init];
    scrollArray=[[NSMutableArray alloc]init];
    [self crearObjetos];
    self.navigationItem.title=@"Plantas";
    Planta *planta=[producto.arrayPlantas objectAtIndex:0];
    self.navigationItem.title=planta.nombre;

    [self.navigationItem setHidesBackButton:NO animated:YES];
}
-(void)didReceiveMemoryWarning{
    NSLog(@"Planta Warning %@",producto.arrayPlantas);
    //[self crearObjetos];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    producto=nil;
    scrollView=nil;
    spinner=nil;
    pageCon=nil;
}
-(void)viewWillDisappear:(BOOL)animated{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBarHidden=NO;
    NavController *navController = (NavController *)self.navigationController;
    [navController setInterfaceOrientation:YES];
}
-(void)viewDidAppear:(BOOL)animated{
        UIScrollView *sv=[scrollArray objectAtIndex:scrollVar];
        [sv setZoomScale:1 animated:YES];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || 
    (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView1{
    CGRect frame=[[UIScreen mainScreen] applicationFrame];
    float roundedValue = round(scrollView.contentOffset.x / frame.size.height);
    //self.pageCon.currentPage=roundedValue;
    if (roundedValue>=0 && roundedValue<=arrayNombresPlantas.count) {
        self.pageCon.currentPage=roundedValue;
        NSString *key=[NSString stringWithFormat:@"%f",roundedValue];
        self.navigationItem.title=[arrayNombresPlantas objectAtIndex:[key intValue]];
        scrollVar=roundedValue;
    }
}

- (void)customLogoutAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cerrar Sesión" 
                                                    message:@"¿Está seguro que desea cerrar sesión?" 
                                                   delegate:self 
                                          cancelButtonTitle:@"Cancelar"
                                          otherButtonTitles:@"OK",nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"OK"])
    {
        [self logout];
    }
}

- (void)logout{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Pintado de Plantilla

- (void)crearObjetos{    
    [self crearScrollViewConPaginas:producto.arrayPlantas.count];
    
    //En este ciclo se crean los proyectos encontrados para este usuario
    for (int i= 0; i<producto.arrayPlantas.count; i++) {
        Planta *planta=[[Planta alloc]init];
        planta = [producto.arrayPlantas objectAtIndex:i];
        [arrayNombresPlantas addObject:planta.nombre];
        [self paginaCreadaConPlanta:planta enPosicion:i];
    }
}

- (void)crearScrollViewConPaginas:(int)numeroDePaginas{
    //Se crea el scrollview
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.height,frame.size.width)];
    if (numeroDePaginas==1) {
        scrollView.contentSize=CGSizeMake(frame.size.height*numeroDePaginas+1, frame.size.width);
    }
    else {
        scrollView.contentSize=CGSizeMake(frame.size.height*numeroDePaginas, frame.size.width);
    }
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator=NO;
    scrollView.delegate=self;
    [self.view addSubview:scrollView];
    //Se crea el contador de paginas
    self.pageCon = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 0, frame.size.height, 50)];
    self.pageCon.center=CGPointMake(365,frame.size.height-335);
    self.pageCon.userInteractionEnabled=NO;
    self.pageCon.numberOfPages=numeroDePaginas;
    [self.view addSubview:pageCon];
}

- (void)paginaCreadaConPlanta:(Planta*)planta enPosicion:(int)posicion{
    CGRect frame=[[UIScreen mainScreen] applicationFrame];
    //UIView *pagina=[[UIView alloc]init];
    UIScrollView *pagina=[[UIScrollView alloc]init];
    pagina.frame=CGRectMake(frame.size.height*posicion, 0, frame.size.height, frame.size.width);
    [pagina setContentSize:CGSizeMake(pagina.frame.size.width, pagina.frame.size.height)];
    NSMutableArray *tempArray=planta.arrayEspacios3D;
    UIImageView *imageView=[self insertarImagenPlantaEnPagina:pagina conPlanta:planta];
    imageView.tag=posicion+2000;
    UIScrollView *sv=[[UIScrollView alloc]initWithFrame:CGRectMake(25, 25, pagina.frame.size.width-50, pagina.frame.size.height-100)];
    sv.tag=posicion+3000;
    [sv addSubview:imageView];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [sv addGestureRecognizer:doubleTap];

    sv.clipsToBounds=YES;
    [pagina addSubview:sv];
    NSString *area=NSLocalizedString(@"AreaTotal", nil);
    [self labelDeArea:[NSString stringWithFormat:@"%@ %@",area, producto.area] eInsertarEnView:imageView];
    
    [imageView setUserInteractionEnabled:YES];
    for (int i=0; i<tempArray.count; i++) {
        Espacio3D *espacio3D=[tempArray objectAtIndex:i];
        [self insertarBotonEn:imageView enPosicionX:espacio3D.coordenadaX yPosicionY:espacio3D.coordenadaY Tag:i yPagina:posicion titulo:espacio3D.nombre];
    }
    [sv setUserInteractionEnabled:YES];
    [sv setMinimumZoomScale:1];
    [sv setMaximumZoomScale:2];
    [sv setCanCancelContentTouches:NO];
    sv.clipsToBounds = YES;
    sv.delegate=self;
    [scrollArray addObject:sv];
    [scrollView addSubview:pagina];
}
-(UIView *)viewForZoomingInScrollView:(UIScrollView*)scrollview{
 return (UIImageView *)[scrollView viewWithTag:self.pageCon.currentPage+2000];
 }
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollview withView:(UIView *)view atScale:(float)scale{
    NSLog(@"xxx");
    //scrollview.minimumZoomScale = scale;
}
-(void)labelDeArea:(NSString*)area eInsertarEnView:(UIView*)view{
    UIToolbar *toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 600, self.view.frame.size.height-50, 50)];
    [toolBar setBarStyle:UIBarStyleBlack];
    [view addSubview:toolBar];
    UILabel *areaLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, toolBar.frame.size.width, 50)];
    areaLabel.textAlignment=UITextAlignmentCenter;
    areaLabel.backgroundColor=[UIColor clearColor];
    areaLabel.font=[UIFont fontWithName:@"Helvetica" size:20];
    areaLabel.textColor=[UIColor whiteColor];
    [areaLabel setAdjustsFontSizeToFitWidth:YES];
    NSString *replacedMt=[producto.area stringByReplacingOccurrencesOfString:@"mt2" withString:@"mt\u00B2"];
    NSString *areaTotal=NSLocalizedString(@"AreaTotal", nil);
    areaLabel.text=[NSString stringWithFormat:@"%@ %@",areaTotal, replacedMt];
    areaLabel.center=CGPointMake(toolBar.frame.size.width/2, toolBar.frame.size.height/2);
    [toolBar addSubview:areaLabel];
}
-(UIImageView*)insertarImagenPlantaEnPagina:(UIView*)view conPlanta:(Planta*)planta{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *newFolder=[NSString stringWithFormat:@"%@/resources",docDir];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/planta%@.jpeg",docDir,planta.idPlanta];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    UIImageView *plantaImage = [[UIImageView alloc]init];

    if (!fileExists) {
        NSLog(@"no existe planta img %@",jpegFilePath);
        NSString *string=[planta.imagenPlanta stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        NSURL *urlImagen=[NSURL URLWithString:string];
        NSLog(@"url %@",urlImagen);

        NSData *data=[NSData dataWithContentsOfURL:urlImagen];
        plantaImage.image = [UIImage imageWithData:data];
        NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(plantaImage.image, 1.0f)];//1.0f = 100% quality
        if (plantaImage.image) {
            [data2 writeToFile:jpegFilePath atomically:YES];
        }
        plantaImage.frame = CGRectMake(0, 0, view.frame.size.width-50, view.frame.size.height-150);
        return plantaImage;
    }
    else {
        NSLog(@"si existe planta img %@",jpegFilePath);
        plantaImage.image = [UIImage imageWithContentsOfFile:jpegFilePath];
        plantaImage.frame = CGRectMake(0, 0, view.frame.size.width-50, view.frame.size.height-150);
        NSLog(@"width %f height %f",plantaImage.frame.size.width,plantaImage.frame.size.height);
        return plantaImage;
    }
    return nil;
}

-(void)insertarBotonEn:(UIView*)view enPosicionX:(NSString*)posX yPosicionY:(NSString*)posY Tag:(int)tag yPagina:(int)pagina titulo:(NSString*)eltitulo{
    CustomButton *boton = [[CustomButton alloc]init];
    UIImage *imageButton = [UIImage imageNamed:@"pin.png"];
    boton.tag=tag;
    float buttonSize=34;
    boton.secondaryId=pagina;
    //[boton setImage:imageButton forState:UIControlStateNormal];
    [boton setBackgroundImage:imageButton forState:UIControlStateNormal];
    UIFont *font=[UIFont fontWithName:@"Helvetica" size:8];
    boton.titleLabel.font=font;
    [boton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //[boton setTitle:eltitulo forState:UIControlStateNormal];
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
    CGFloat constrainedSize = 300.0f;
    //UIFont * font = [UIFont fontWithName:@"Helvetica" size:13];
    UIFont * font = [UIFont boldSystemFontOfSize:13];
    
    CGSize textSize = [titulo sizeWithFont: font
                         constrainedToSize:CGSizeMake(constrainedSize, CGFLOAT_MAX)
                             lineBreakMode:UILineBreakModeWordWrap];
    float buttonSize=34;
    UIView *container=[[UIView alloc]init];
    container.frame=CGRectMake(posX+10, posY-(buttonSize/1.2),textSize.width+20, 20);
    container.backgroundColor=[UIColor clearColor];
    [view addSubview:container];
    UIView *lowAlphaView=[[UIView alloc]init];
    lowAlphaView.frame=CGRectMake(0, 0, container.frame.size.width, container.frame.size.height);
    lowAlphaView.backgroundColor=[UIColor clearColor];
    lowAlphaView.alpha=0.5;
    [container addSubview:lowAlphaView];
    
    UILabel *label=[[UILabel alloc]init];
    label.font=font;
    label.frame=CGRectMake(10, 0,textSize.width, 20);
    label.text=titulo;
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(1, 1);
    [label setAdjustsFontSizeToFitWidth:YES];
    label.textColor=[UIColor whiteColor];
    label.backgroundColor=[UIColor clearColor];
    [container addSubview:label];
}
#pragma mark -
#pragma mark Eventos para ir a otros viewcontrollers

- (void)irAlSiguienteViewController:(CustomButton*)sender{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *loadingText=NSLocalizedString(@"Cargando", nil);
    hud.labelText=loadingText;
    [self performSelector:@selector(delayedAction:) withObject:sender afterDelay:0.2];
}
-(void)delayedAction:(CustomButton*)sender{
    Planta *planta=[[Planta alloc]init];
    planta = [producto.arrayPlantas objectAtIndex:sender.secondaryId];
    NSMutableArray *tempArray=planta.arrayEspacios3D;
    Espacio3D *espacio3D=[tempArray objectAtIndex:sender.tag];
    Espacio3DVC *e3dVC=[[Espacio3DVC alloc]init];
    e3dVC=[self.storyboard instantiateViewControllerWithIdentifier:@"Espacio3DVC"];
    e3dVC.espacio3D=espacio3D;
    e3dVC.arregloEspacial=tempArray;
    NavController *navController = (NavController *)self.navigationController;
    [navController setOrientationType:0];
    //[navController forceLandscapeFromLandscape];
    [self.navigationController pushViewController:e3dVC animated:YES];
}
#pragma mark - scroll tap
- (void)handleDoubleTap:(UIGestureRecognizer *)recognizer {
    NSLog(@"doubletap ");
    UIScrollView *tempScroll=(UIScrollView *)[scrollView viewWithTag:self.pageCon.currentPage+3000];
    if(tempScroll.zoomScale>=1.0 && tempScroll.zoomScale<=1.5){
        CGPoint Pointview=[recognizer locationInView:tempScroll];
        CGFloat newZoomscal=3.0;
        
        newZoomscal=MIN(newZoomscal, 5.0);
        
        CGSize scrollViewSize=tempScroll.bounds.size;
        
        CGFloat w=scrollViewSize.width/newZoomscal;
        CGFloat h=scrollViewSize.height/newZoomscal;
        CGFloat x= Pointview.x-(w/2.0);
        CGFloat y = Pointview.y-(h/2.0);
        
        CGRect rectTozoom=CGRectMake(x, y, w, h);
        [tempScroll zoomToRect:rectTozoom animated:YES];
        
        [tempScroll setZoomScale:2.0 animated:YES];
        //zoomCheck=NO;
    }
    else{
        [tempScroll setZoomScale:1.0 animated:YES];
   //     zoomCheck=YES;
    }
}

@end