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
    
    [spinner startAnimating];
    [self loadScrollViewWithMap];
    // Do any additional setup after loading the view.
}

- (void)viewDidUnload{
    [super viewDidUnload];
    proyecto=nil;
    scrollViewMapa=nil;
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
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/imagenUrbanismo%@.jpeg",docDir,itemUrbanismo.idUrbanismo];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    if (!fileExists) {
        NSLog(@"no existe %@",jpegFilePath);
        NSURL *urlImagenUrbanismo=[NSURL URLWithString:itemUrbanismo.imagenUrbanismo];
        NSData *dataImagenUrbanismo=[NSData dataWithContentsOfURL:urlImagenUrbanismo];
        UIImage *imageUrbanismo=[UIImage imageWithData:dataImagenUrbanismo];
        NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(imageUrbanismo, 1.0f)];//1.0f = 100% quality
        if (imageUrbanismo) {
            [data2 writeToFile:jpegFilePath atomically:YES];
        }
        imageViewUrbanismo=[[UIImageView alloc]initWithImage:[UIImage imageWithData:data2]];
        [imageViewUrbanismo setUserInteractionEnabled:YES];
        UIScrollView *scrollViewUrbanismo=[[UIScrollView alloc]init];
        scrollViewUrbanismo.frame=CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
        scrollViewUrbanismo.contentSize=CGSizeMake(imageViewUrbanismo.frame.size.width, imageViewUrbanismo.frame.size.height);
        [self.view addSubview:scrollViewUrbanismo];
        [scrollViewUrbanismo addSubview:imageViewUrbanismo];
        [scrollViewUrbanismo setMinimumZoomScale:0.3];
        [scrollViewUrbanismo setMaximumZoomScale:5.0];
        [scrollViewUrbanismo setCanCancelContentTouches:NO];
        scrollViewUrbanismo.clipsToBounds = YES;
        [scrollViewUrbanismo setDelegate:self];
        //Crear todos los botones de los items del urbanismo
        for (int i=0; i<arrayGrupos.count; i++) {
            Grupo *grupo=[arrayGrupos objectAtIndex:i];
            [self insertarBotonEn:imageViewUrbanismo enPosicionX:grupo.coordenadaX yPosicionY:grupo.coordenadaY yTag:i titulo:grupo.nombre];
        }
    }
    
    else{
        //NSLog(@"si existe");
        UIImage *imageUrbanismo=[UIImage imageWithContentsOfFile:jpegFilePath];
        imageViewUrbanismo=[[UIImageView alloc]initWithImage:imageUrbanismo];
        [imageViewUrbanismo setUserInteractionEnabled:YES];
        UIScrollView *scrollViewUrbanismo=[[UIScrollView alloc]init];
        scrollViewUrbanismo.frame=CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
        scrollViewUrbanismo.contentSize=CGSizeMake(imageViewUrbanismo.frame.size.width, imageViewUrbanismo.frame.size.height+45);
        [self.view addSubview:scrollViewUrbanismo];
        [scrollViewUrbanismo addSubview:imageViewUrbanismo];
        [scrollViewUrbanismo setMinimumZoomScale:0.3];
        [scrollViewUrbanismo setMaximumZoomScale:5.0];
        [scrollViewUrbanismo setCanCancelContentTouches:NO];
        scrollViewUrbanismo.clipsToBounds = YES;
        [scrollViewUrbanismo setDelegate:self];
        //Crear todos los botones de los items del urbanismo
        for (int i=0; i<arrayGrupos.count; i++) {
            Grupo *grupo=[arrayGrupos objectAtIndex:i];
            [self insertarBotonEn:imageViewUrbanismo enPosicionX:grupo.coordenadaX yPosicionY:grupo.coordenadaY yTag:i titulo:grupo.nombre];
        }
    }
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView*)scrollview{
    return imageViewUrbanismo;
}
-(void)insertarBotonEn:(UIView*)view enPosicionX:(NSString*)posX yPosicionY:(NSString*)posY yTag:(int)tag titulo:(NSString*)eltitulo{
    UIButton *boton = [[UIButton alloc]init];
    UIImage *imageButton = [UIImage imageNamed:@"flechamapa.png"];
    boton.tag=tag;
    [boton setImage:imageButton forState:UIControlStateNormal];
    [boton addTarget:self action:@selector(irAlSiguienteViewController:) forControlEvents:UIControlEventTouchUpInside];
    int posXint=[posX intValue];
    int posYint=[posY intValue];
    boton.frame=CGRectMake(posXint-50, posYint-100,100, 100);
    [self agregarLabelAlLadoDelBotonEnView:view enPosicionX:posXint yPosicionY:posYint conTitulo:eltitulo];
    [view addSubview:boton];
    [view bringSubviewToFront:boton];
}
-(void)agregarLabelAlLadoDelBotonEnView:(UIView*)view enPosicionX:(int)posX yPosicionY:(int)posY conTitulo:(NSString*)titulo{
    //Tamaño del texto
    CGFloat constrainedSize = 1000.0f;
    UIFont * font = [UIFont fontWithName:@"Helvetica" size:22];
    CGSize textSize = [titulo sizeWithFont: font
                         constrainedToSize:CGSizeMake(constrainedSize, CGFLOAT_MAX)
                             lineBreakMode:UILineBreakModeWordWrap];
    
    UIView *container=[[UIView alloc]init];
    container.frame=CGRectMake(posX+16, posY-80,textSize.width+20, 28);
    container.backgroundColor=[UIColor clearColor];
    [view addSubview:container];
    UIView *lowAlphaView=[[UIView alloc]init];
    lowAlphaView.frame=CGRectMake(0, 0, container.frame.size.width, container.frame.size.height);
    lowAlphaView.backgroundColor=[UIColor blackColor];
    lowAlphaView.alpha=0.5;
    [container addSubview:lowAlphaView];
    
    UILabel *label=[[UILabel alloc]init];
    label.font=[UIFont fontWithName:@"Helvetica" size:22];
    label.frame=CGRectMake(10, 2,textSize.width, 24);
    label.text=titulo;
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

@end
