//
//  PlantaUrbanaGeneralVC.m
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 4/19/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "PlantaUrbanaVC.h"

@interface PlantaUrbanaVC ()

@end

@implementation PlantaUrbanaVC

@synthesize proyecto;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"Planta Urbana";
    maximumZoomScale=5.0;
    
    [spinner startAnimating];
    [self loadScrollViewWithMap];
    
    zoomCheck=YES;
    // Do any additional setup after loading the view.
}

- (void)viewDidUnload{
    [super viewDidUnload];
    proyecto=nil;
    scrollViewUrbanismo=nil;
    imageViewUrbanismo=nil;
    spinner=nil;
    // Release any retained subviews of the main view.
}
-(void)didReceiveMemoryWarning{
    NSLog(@"PlantaUrbana Warning %@",proyecto.arrayItemsUrbanismo);
    //[self crearObjetos];
}
-(void)viewWillDisappear:(BOOL)animated{
    spinner.alpha=0.0;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [spinner stopAnimating];
    [self.view sendSubviewToBack:spinner];
}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || 
    (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)loadScrollViewWithMap{
    NSMutableArray *tempArray=proyecto.arrayItemsUrbanismo;
    ItemUrbanismo *itemUrbanismo=[tempArray objectAtIndex:0];
    NSMutableArray *arrayGrupos=itemUrbanismo.arrayGrupos;
    scrollViewUrbanismo=[[UIScrollView alloc]init];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [scrollViewUrbanismo addGestureRecognizer:doubleTap];
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
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
            imageViewUrbanismo.frame=CGRectMake(0, 0, (imageUrbanismo.size.width*2), (imageUrbanismo.size.height*2));
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
            imageViewUrbanismo.frame=CGRectMake(0, 0, (imageUrbanismo.size.width*2), (imageUrbanismo.size.height*2));
            NSLog(@"width %.0f height %.0f",imageViewUrbanismo.frame.size.width,imageViewUrbanismo.frame.size.height);
        }
    }
    
    //Crear todos los botones de los items del urbanismo
    [imageViewUrbanismo setUserInteractionEnabled:YES];
    
    //imageViewUrbanismo.center=CGPointMake(self.view.frame.size.height/2, self.view.frame.size.width/2);
    scrollViewUrbanismo.frame=CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width-50);
    scrollViewUrbanismo.contentSize=CGSizeMake(imageViewUrbanismo.frame.size.width, imageViewUrbanismo.frame.size.height);
    //[self layoutScrollView];
    [self.view addSubview:scrollViewUrbanismo];
    [scrollViewUrbanismo addSubview:imageViewUrbanismo];
    for (int i=0; i<arrayGrupos.count; i++) {
        Grupo *grupo=[arrayGrupos objectAtIndex:i];
        [self insertarBotonEn:imageViewUrbanismo enPosicionX:grupo.coordenadaX yPosicionY:grupo.coordenadaY yTag:i titulo:grupo.nombre];
    }
    [scrollViewUrbanismo setMinimumZoomScale:0.3];
    [scrollViewUrbanismo setMaximumZoomScale:maximumZoomScale];
    [scrollViewUrbanismo setCanCancelContentTouches:NO];
    scrollViewUrbanismo.clipsToBounds = YES;
    [scrollViewUrbanismo scrollRectToVisible:CGRectMake(imageViewUrbanismo.frame.size.width/2, scrollViewUrbanismo.frame.size.height/2, scrollViewUrbanismo.frame.size.width/2, imageViewUrbanismo.frame.size.height/2) animated:YES];
    
    [scrollViewUrbanismo setDelegate:self];
}

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


-(void)irAlSiguienteViewController:(UIButton*)sender{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=@"Loading";
    [self performSelector:@selector(delayedAction:) withObject:sender afterDelay:0.3];
        
    //NSLog(@"hecho por acá");
}
-(void)delayedAction:(UIButton*)sender{
    ItemUrbanismo *itemUrbanismo=[proyecto.arrayItemsUrbanismo objectAtIndex:0];
    Grupo *grupo=[itemUrbanismo.arrayGrupos objectAtIndex:sender.tag];
    NSString *string =grupo.idGrupo;

    if ([string rangeOfString:@"urbanizationspaces"].location != NSNotFound) {
        NSLog(@"voy pa espacios...");
        Espacio3DVC *e3DVC=[[Espacio3DVC alloc]init];
        e3DVC=[self.storyboard instantiateViewControllerWithIdentifier:@"Espacio3DVC"];
        TipoDePiso *tipoDePiso=[grupo.arrayTiposDePiso objectAtIndex:0];
        Producto *producto=[tipoDePiso.arrayProductos objectAtIndex:0];
        Planta *planta=[producto.arrayPlantas objectAtIndex:0];
        e3DVC.espacio3D=[planta.arrayEspacios3D objectAtIndex:0];
        [self.navigationController pushViewController:e3DVC animated:YES];
    }
    else {
        if (grupo.existe==1) {
            TipoDePiso *tipoDePiso=[grupo.arrayTiposDePiso objectAtIndex:0];
            if (tipoDePiso.existe) {
                TiposDePisosVC *tpVC=[[TiposDePisosVC alloc]init];
                tpVC=[self.storyboard instantiateViewControllerWithIdentifier:@"TiposDePisosVC"];
                tpVC.grupo=grupo;
                [self.navigationController pushViewController:tpVC animated:YES];
            }
            else{
                Producto *producto=[tipoDePiso.arrayProductos objectAtIndex:0];
                TiposDePlantasVC *tpVC=[[TiposDePlantasVC alloc]init];
                tpVC=[self.storyboard instantiateViewControllerWithIdentifier:@"TiposDePlantasVC"];
                tpVC.producto=producto;
                [self.navigationController pushViewController:tpVC animated:YES];
            }
            
        }
        else{
            TipoDePiso *tipoDePiso=[grupo.arrayTiposDePiso objectAtIndex:0];
            Producto *producto=[tipoDePiso.arrayProductos objectAtIndex:0];
            TiposDePlantasVC *tpVC=[[TiposDePlantasVC alloc]init];
            tpVC=[self.storyboard instantiateViewControllerWithIdentifier:@"TiposDePlantasVC"];
            tpVC.producto=producto;
            [self.navigationController pushViewController:tpVC animated:YES];
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
        CGFloat newZoomscal=3.0;
        
        newZoomscal=MIN(newZoomscal, maximumZoomScale);
        
        CGSize scrollViewSize=scrollViewUrbanismo.bounds.size;
        
        CGFloat w=scrollViewSize.width/newZoomscal;
        CGFloat h=scrollViewSize.height /newZoomscal;
        CGFloat x= Pointview.x-(w/2.0);
        CGFloat y = Pointview.y-(h/2.0);
        
        CGRect rectTozoom=CGRectMake(x, y, w, h);
        [scrollViewUrbanismo zoomToRect:rectTozoom animated:YES];
        
        [scrollViewUrbanismo setZoomScale:3.0 animated:YES];
        zoomCheck=NO;
    }
    else{
        [scrollViewUrbanismo setZoomScale:1.0 animated:YES];
        zoomCheck=YES;
    }
}

@end
