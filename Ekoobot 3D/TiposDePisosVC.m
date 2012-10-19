//
//  PlantaUrbanaEspecificaVC.m
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 4/19/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "TiposDePisosVC.h"

@interface TiposDePisosVC ()

@end

@implementation TiposDePisosVC

@synthesize grupo;
@synthesize pageCon;

#pragma mark -
#pragma mark Ciclo de Vida

-(void)viewDidLoad{
    [super viewDidLoad];
    //Se cargan y muestran todos los proyectos
    [self crearObjetos];
    
    //El titulo del view
    self.navigationItem.title=@"Piso Tipo";
    /*UIBarButtonItem *logout = [[UIBarButtonItem alloc] initWithTitle:@"Logout" 
                                                               style:UIBarButtonItemStylePlain 
                                                              target:self 
                                                              action:@selector(customLogoutAlert)];   
    //self.navigationItem.rightBarButtonItem = logout;*/
    [self.navigationItem setHidesBackButton:NO animated:YES];
}
-(void)didReceiveMemoryWarning{
    NSLog(@"Pisos Warning %@",grupo.arrayTiposDePiso);
    //[self crearObjetos];
}
-(void)viewDidUnload{
    [super viewDidUnload];
    scrollView=nil;
    grupo=nil;
    pageCon=nil;
}
-(void)viewWillDisappear:(BOOL)animated{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden=NO;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || 
    (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView1{
    CGRect frame=[[UIScreen mainScreen] applicationFrame];
    float roundedValue = round(scrollView.contentOffset.x / frame.size.height);
    self.pageCon.currentPage=roundedValue;
}
-(void)customLogoutAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cerrar Sesión" 
                                                    message:@"¿Está seguro que desea cerrar sesión?" 
                                                   delegate:self 
                                          cancelButtonTitle:@"Cancelar"
                                          otherButtonTitles:@"OK",nil];
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"OK"])
    {
        [self logout];
    }
}
-(void)logout{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Pintado de Plantilla
-(void)crearObjetos{    
    [self crearScrollViewConPaginas:grupo.arrayTiposDePiso.count];
    NSLog(@"Count tipos de piso array %i",grupo.arrayTiposDePiso.count);
    //En este ciclo se crean los proyectos encontrados para este usuario
    for (int i= 0; i<grupo.arrayTiposDePiso.count; i++) {
        TipoDePiso *tipoDePiso=[[TipoDePiso alloc]init];
        tipoDePiso = [grupo.arrayTiposDePiso objectAtIndex:i];
        [self paginaCreadaConTipoPiso:tipoDePiso enPosicion:i];
    }
}
-(void)crearScrollViewConPaginas:(int)numeroDePaginas{
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
-(void)paginaCreadaConTipoPiso:(TipoDePiso*)tipoPiso enPosicion:(int)posicion{
    CGRect frame=[[UIScreen mainScreen] applicationFrame];
    UIScrollView *pagina=[[UIScrollView alloc]init];
    pagina.frame=CGRectMake(frame.size.height*posicion, 0, frame.size.height, frame.size.width);
    [pagina setContentSize:CGSizeMake(pagina.frame.size.width, pagina.frame.size.height)];
    NSMutableArray *tempArray=tipoPiso.arrayProductos;
    UIImageView *imageView=[self insertarImagenProyectoEnPagina:pagina conTipoPiso:tipoPiso];
    imageView.tag=posicion+2000;
    [pagina addSubview:imageView];
    UIScrollView *sv=[[UIScrollView alloc]initWithFrame:CGRectMake(25, 25, pagina.frame.size.width-50, pagina.frame.size.height-100)];
    sv.tag=posicion+3000;
    [sv addSubview:imageView];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [sv addGestureRecognizer:doubleTap];
    
    sv.clipsToBounds=YES;
    [pagina addSubview:sv];
    [imageView setUserInteractionEnabled:YES];
    for (int i=0; i<tempArray.count; i++) {
        Producto *producto=[tempArray objectAtIndex:i];
        NSLog(@"producto.nombre %@",producto.nombre);
        [self insertarBotonEn:imageView enPosicionX:producto.coordenadaX yPosicionY:producto.coordenadaY Tag:i yPagina:posicion titulo:producto.nombre];
    }
    [sv setUserInteractionEnabled:YES];
    [sv setMinimumZoomScale:1];
    [sv setMaximumZoomScale:3];
    [sv setCanCancelContentTouches:NO];
    sv.clipsToBounds = YES;
    sv.delegate=self;
    [scrollView addSubview:pagina];
}
-(UIView *)viewForZoomingInScrollView:(UIScrollView*)scrollview{
    return (UIImageView *)[scrollView viewWithTag:self.pageCon.currentPage+2000];
}
-(UIImageView*)insertarImagenProyectoEnPagina:(UIView*)view conTipoPiso:(TipoDePiso*)tipoPiso{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/tipoDePiso%@.jpeg",docDir,tipoPiso.idTipoPiso];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    if (!fileExists) {
        //NSLog(@"no existe tipo piso img %@",jpegFilePath);
        NSURL *urlImagen=[NSURL URLWithString:tipoPiso.imagen];
        NSData *data=[NSData dataWithContentsOfURL:urlImagen];
        UIImageView *proyectoImage = [[UIImageView alloc]init];
        proyectoImage.image = [UIImage imageWithData:data];
        NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(proyectoImage.image, 1.0f)];//1.0f = 100% quality
        if (proyectoImage.image) {
            [data2 writeToFile:jpegFilePath atomically:YES];
        }
        proyectoImage.frame = CGRectMake(0, 0, view.frame.size.width-50, view.frame.size.height-100);
        NSLog(@"ancho %f alto %f",proyectoImage.frame.size.width,proyectoImage.frame.size.height);
        return proyectoImage;
    }    
    else {
        //NSLog(@"si existe tipo piso img %@",jpegFilePath);
        UIImageView *proyectoImage = [[UIImageView alloc]init];
        proyectoImage.image = [UIImage imageWithContentsOfFile:jpegFilePath];
        proyectoImage.frame = CGRectMake(0, 0, view.frame.size.width-50, view.frame.size.height-100);
        NSLog(@"ancho %f alto %f",proyectoImage.frame.size.width,proyectoImage.frame.size.height);
        return proyectoImage;
    }
    return nil;
}

-(void)insertarBotonEn:(UIView*)view enPosicionX:(NSString*)posX yPosicionY:(NSString*)posY Tag:(int)tag yPagina:(int)pagina titulo:(NSString*)eltitulo{
    CustomButton *boton = [[CustomButton alloc]init];
    UIImage *imageButton = [UIImage imageNamed:@"pin.png"];
    boton.tag=tag;
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
    boton.frame=CGRectMake(posXint-25, posYint-65,34, 34);
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
    
    UIView *container=[[UIView alloc]init];
    container.frame=CGRectMake(posX+2, posY-58,textSize.width+20, 20);
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

-(void)irAlSiguienteViewController:(CustomButton*)sender{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=@"Loading";
    [self performSelector:@selector(delayedAction:) withObject:sender afterDelay:0.3];
}
-(void)delayedAction:(CustomButton*)sender{
    TipoDePiso *tipoDePiso=[[TipoDePiso alloc]init];
    tipoDePiso = [grupo.arrayTiposDePiso objectAtIndex:sender.secondaryId];
    NSMutableArray *tempArray=tipoDePiso.arrayProductos;
    Producto *producto=[tempArray objectAtIndex:sender.tag];
    TiposDePlantasVC *tpVC=[[TiposDePlantasVC alloc]init];
    tpVC=[self.storyboard instantiateViewControllerWithIdentifier:@"TiposDePlantasVC"];
    tpVC.producto=producto;
    [self.navigationController pushViewController:tpVC animated:YES];
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
        
        [tempScroll setZoomScale:3.0 animated:YES];
        //zoomCheck=NO;
    }
    else{
        [tempScroll setZoomScale:1.0 animated:YES];
        //     zoomCheck=YES;
    }
}

@end