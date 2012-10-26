//
//  SecondViewController.m
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 4/17/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "ListadoDeProyectosVC.h"

@interface ListadoDeProyectosVC ()
@end

@implementation ListadoDeProyectosVC

@synthesize pageCon;
@synthesize usuarioActual,usuarioCopia;

#pragma mark -
#pragma mark Ciclo de Vida

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Se cargan y muestran todos los proyectos
    arrayDeTitulos = [[NSMutableArray alloc]init];
    [self mostrarObjetos];
    //El titulo del view
    Proyecto *proyecto=[usuarioActual.arrayProyectos objectAtIndex:0];
    self.navigationItem.title=proyecto.nombre;
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabelWithTag:) name:@"updates" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabelWithTag:) name:@"updates" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertViewAppear) name:@"alert" object:nil];

    UIBarButtonItem *logout = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                               style:UIBarButtonItemStylePlain 
                                                              target:self 
                                                              action:@selector(customLogoutAlert)];   
    self.navigationItem.rightBarButtonItem = logout;
    [self.navigationItem setHidesBackButton:YES animated:YES];
    NavController *navController = (NavController *)self.navigationController;
    [navController setOrientationType:0];
    
}
-(void)didReceiveMemoryWarning{
    NSLog(@"Listado Warning %@",usuarioActual.arrayProyectos);
    //[self crearObjetos];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    scrollView=nil;
    usuarioActual=nil;
    progressView=nil;
    pageCon=nil;
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden=NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    progressView=[[ProgressView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:progressView];
    [self.view bringSubviewToFront:progressView];
}
-(void)viewWillDisappear:(BOOL)animated{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || 
    (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView1{
    CGRect frame=[[UIScreen mainScreen] applicationFrame];
    float roundedValue = round(scrollView.contentOffset.x / frame.size.height);
    if (roundedValue>=0 && roundedValue<=arrayDeTitulos.count-1) {
        self.pageCon.currentPage=roundedValue;
        NSString *key=[NSString stringWithFormat:@"%f",roundedValue];
        self.navigationItem.title=[arrayDeTitulos objectAtIndex:[key intValue]];
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

- (void)mostrarObjetos{
    //NSLog(@"Proyectos Cargados: %i",usuarioActual.proyectos.count);
    
    [self crearScrollViewConPaginas:usuarioActual.arrayProyectos.count];
    
    //En este ciclo se crean los proyectos encontrados para este usuario
    for (int i= 0; i<usuarioActual.arrayProyectos.count; i++) {
        Proyecto *proyecto=[[Proyecto alloc]init];
        proyecto = [usuarioActual.arrayProyectos objectAtIndex:i];
        //[ProjectDownloader downloadProject:proyecto];
        [self paginaCreadaConObjeto:proyecto enPosicion:i];
    }
    
}

- (void)crearScrollViewConPaginas:(int)numeroDePaginas
{
    //Se crea el scrollview
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.height,frame.size.width)];
    if (numeroDePaginas==1) {
        scrollView.contentSize=CGSizeMake(frame.size.height*numeroDePaginas+1, frame.size.width);
    }
    else{
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

- (void)paginaCreadaConObjeto:(Proyecto*)proyecto enPosicion:(int)posicion{
    
        CGRect frame=[[UIScreen mainScreen] applicationFrame];
        UIScrollView *scrollPage=[[UIScrollView alloc]init];
        scrollPage.frame=CGRectMake(0, 0, frame.size.height, frame.size.width);
        scrollPage.contentSize=CGSizeMake(frame.size.height, frame.size.width*(proyecto.arrayAdjuntos.count+1));
        scrollPage.userInteractionEnabled=YES;
        scrollPage.pagingEnabled=YES;
        scrollPage.showsVerticalScrollIndicator=YES;
        scrollPage.delegate=self;
        
        for (int i=0; i<proyecto.arrayAdjuntos.count; i++) {
            Adjunto *adjunto=[proyecto.arrayAdjuntos objectAtIndex:i];
            if ([adjunto.tipo isEqualToString:@"image"]) {
                NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *jpegFilePath = [NSString stringWithFormat:@"%@/render%@%@",docDir,proyecto.idProyecto,[IAmCoder encodeURL:adjunto.imagen]];
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
                NSLog(@"file path %@",jpegFilePath);
                if (!fileExists) {
                    //NSLog(@"no existe proj img %@",jpegFilePath);
                    NSURL *urlImagen=[NSURL URLWithString:adjunto.imagen];
                    NSData *data=[NSData dataWithContentsOfURL:urlImagen];
                    UIImageView *renderImage = [[UIImageView alloc]init];
                    renderImage.image = [UIImage imageWithData:data];
                    NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(renderImage.image, 1.0f)];//1.0f = 100% quality
                    if (renderImage.image) {
                        [data2 writeToFile:jpegFilePath atomically:YES];
                    }
                    renderImage.frame=CGRectMake(0, frame.size.width*(i+1)-40, frame.size.height, frame.size.width);
                    renderImage.backgroundColor=[UIColor clearColor];
                    [scrollPage addSubview:renderImage];
                }
                else {
                    //NSLog(@"si existe proj img %@",jpegFilePath);
                    UIImageView *renderImage = [[UIImageView alloc]init];
                    renderImage.image = [UIImage imageWithContentsOfFile:jpegFilePath];
                    renderImage.frame=CGRectMake(0, frame.size.width*(i+1)-40, frame.size.height, frame.size.width);
                    renderImage.backgroundColor=[UIColor clearColor];
                    [scrollPage addSubview:renderImage];
                }
                
            }
            else if ([adjunto.tipo isEqualToString:@"video"]){
                UIView *pg3=[[UIView alloc]init];
                pg3.frame=CGRectMake(0, frame.size.width*(i+1), frame.size.height, frame.size.width);
                pg3.backgroundColor=[UIColor viewFlipsideBackgroundColor];
                
                CustomButton *player = [[CustomButton alloc]init];
                player.frame = CGRectMake(0, 0, 512, 288);
                player.center=CGPointMake(pg3.frame.size.width/2, pg3.frame.size.height/2);
                player.backgroundColor=[UIColor whiteColor];
                [player setTitle:@"" forState:UIControlStateNormal];
                player.adjunto=adjunto;
                player.extraContent=proyecto;
                [player addTarget:self action:@selector(callVideo:) forControlEvents:UIControlEventTouchUpInside];
                [pg3 addSubview:player];
                
                UIImageView *playButton=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"play-video.png"]];
                playButton.frame=CGRectMake(0, 0, 80, 56);
                playButton.center=CGPointMake(pg3.frame.size.width/2, pg3.frame.size.height/2);
                [pg3 addSubview:playButton];
                
                [scrollPage addSubview:pg3];
                
            }
        }

        UIView *pagina=[[UIView alloc]init];
        pagina.frame=CGRectMake(frame.size.height*posicion, 0, frame.size.height, frame.size.width);
        [pagina addSubview:scrollPage];
        [self insertarImagenProyectoEnPagina:scrollPage conProyecto:proyecto];
        [self insertarImagenBotonProyectoEnPagina:pagina conProyecto:proyecto yPosicion:(int)posicion];
        [self insertarLogoProyectoEnPagina:pagina conProyecto:proyecto];
        [self insertarLabelProyectoEnPagina:pagina conProyecto:proyecto];
        [self mostrarLabelDeActualizacionConTag:posicion+2000 enView:pagina yProyecto:proyecto];
        [self insertarActualizadorEnPagina:pagina yTag:posicion];
        [scrollView addSubview:pagina];
        
        SendInfoButton *sendInfoButton=[[SendInfoButton alloc]init];
        sendInfoButton.nombreProyecto=proyecto.nombre;
        sendInfoButton.proyectoID=proyecto.idProyecto;
        UIImage *imageButton = [UIImage imageNamed:@"recomendar.png"];
        [sendInfoButton setImage:imageButton forState:UIControlStateNormal];
        sendInfoButton.frame=CGRectMake(pagina.frame.size.width-140, 50, 100, 100);
        [sendInfoButton addTarget:self action:@selector(sendInfo:) forControlEvents:UIControlEventTouchUpInside];
        [pagina addSubview:sendInfoButton];
}
-(void)callVideo:(CustomButton*)sender{
    VideoViewController *vVC=[[VideoViewController alloc]init];
    vVC=[self.storyboard instantiateViewControllerWithIdentifier:@"Video"];
    [vVC setModalPresentationStyle:UIModalPresentationFullScreen];
    [vVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    vVC.adjunto=sender.adjunto;
    vVC.proyecto=sender.extraContent;
    [self presentModalViewController:vVC animated:YES];
}
-(void)actualizarOdescargar:(UIButton*)button{
    NSString *key=[NSString stringWithFormat:@"%i",button.tag-1000];
    [progressView setViewAlphaToOne];
    //[ProjectDownloader downloadProject:[usuarioActual.arrayProyectos objectAtIndex:[key intValue]] yTag:button.tag+1000];
    [ProjectDownloader downloadProject:[usuarioCopia.arrayProyectos objectAtIndex:[key intValue]] yTag:button.tag+1000 sender:progressView usuario:usuarioActual];
    [progressView setViewAlphaToCero];
}
-(void)insertarActualizadorEnPagina:(UIView*)view yTag:(int)tag{
    UIButton *boton = [[UIButton alloc]init];
    UIImage *imageButton = [UIImage imageNamed:@"downloadBtn"];
    [boton setImage:imageButton forState:UIControlStateNormal];
    [boton setTitle:@"" forState:UIControlStateNormal];
    boton.tag=tag+1000;
    [boton addTarget:self action:@selector(actualizarOdescargar:) forControlEvents:UIControlEventTouchUpInside];
    boton.frame=CGRectMake(25, 25,100, 100);
    
    [view addSubview:boton];
    [view bringSubviewToFront:boton];
}
- (void)insertarImagenProyectoEnPagina:(UIView*)view conProyecto:(Proyecto*)proyecto{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/cover%@%@.jpeg",docDir,proyecto.idProyecto,[IAmCoder encodeURL:proyecto.imagen]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    UIImageView *proyectoImage = [[UIImageView alloc]init];
    proyectoImage.layer.cornerRadius=10.0f;
    proyectoImage.layer.masksToBounds=YES;
    if (!fileExists) {
        //NSLog(@"no existe proj img %@",jpegFilePath);
        NSURL *urlImagen=[NSURL URLWithString:proyecto.imagen];
        NSData *data=[NSData dataWithContentsOfURL:urlImagen];
        proyectoImage.image = [UIImage imageWithData:data];
        NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(proyectoImage.image, 1.0f)];//1.0f = 100% quality
        if (proyectoImage.image) {
            [data2 writeToFile:jpegFilePath atomically:YES];
        }
        proyectoImage.frame = CGRectMake(25, 25, view.frame.size.width-50, view.frame.size.height-100);
        //NSLog(@"imagen width %.1f height %.1f",proyectoImage.frame.size.width,proyectoImage.frame.size.height);
        [view addSubview:proyectoImage];
    }
    else {
        //NSLog(@"si existe proj img %@",jpegFilePath);
        proyectoImage.image = [UIImage imageWithContentsOfFile:jpegFilePath];
        proyectoImage.frame = CGRectMake(25, 25, view.frame.size.width-50, view.frame.size.height-100);
        //NSLog(@"imagen width %.1f height %.1f",proyectoImage.frame.size.width,proyectoImage.frame.size.height);
        [view addSubview:proyectoImage];
    }
}

- (void)insertarImagenBotonProyectoEnPagina:(UIView*)view conProyecto:(Proyecto*)proyecto yPosicion:(int)posicion{
    UIButton *boton = [[UIButton alloc]init];
    UIImage *imageButton = [UIImage imageNamed:@"botonEntrar.png"];
    [boton setImage:imageButton forState:UIControlStateNormal];
    boton.tag=posicion+3000;
    NSLog(@"Boton taggggg %i",boton.tag);
    boton.alpha=0;
    [boton addTarget:self action:@selector(irAlSiguienteViewController:) forControlEvents:UIControlEventTouchUpInside];
    boton.frame=CGRectMake(830, 510,170, 170);
    [view addSubview:boton];
    [view bringSubviewToFront:boton];
}

- (void)insertarLogoProyectoEnPagina:(UIView*)view conProyecto:(Proyecto*)proyecto{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/logo%@%@",docDir,proyecto.idProyecto,[IAmCoder encodeURL:proyecto.logo]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    NSLog(@"file path %@",jpegFilePath);
    if (!fileExists) {
        //NSLog(@"no existe proj img %@",jpegFilePath);
        NSURL *urlImagen=[NSURL URLWithString:proyecto.logo];
        NSData *data=[NSData dataWithContentsOfURL:urlImagen];
        UIImageView *proyectoLogo = [[UIImageView alloc]init];
        proyectoLogo.image = [UIImage imageWithData:data];
        NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(proyectoLogo.image, 1.0f)];//1.0f = 100% quality
        if (proyectoLogo.image) {
            [data2 writeToFile:jpegFilePath atomically:YES];
        }
        proyectoLogo.frame = CGRectMake(60, 90, 150, 150);
        [view addSubview:proyectoLogo];
    }
    else {
        //NSLog(@"si existe proj img %@",jpegFilePath);
        UIImageView *proyectoImage = [[UIImageView alloc]init];
        proyectoImage.image = [UIImage imageWithContentsOfFile:jpegFilePath];
        proyectoImage.frame = CGRectMake(60, 90, 150, 150);
        [view addSubview:proyectoImage];
    }
}

- (void)insertarLabelProyectoEnPagina:(UIView*)view conProyecto:(Proyecto*)proyecto{
    [arrayDeTitulos addObject:proyecto.nombre];
    UIView *container=[[UIView alloc]initWithFrame:CGRectMake(50, 57, 265, 35)];
    container.backgroundColor=[UIColor colorWithWhite:0.2 alpha:1];
    container.alpha=0.8;
    container.layer.cornerRadius = 10.0;
    container.layer.shadowColor = [[UIColor colorWithWhite:0.1 alpha:1] CGColor];
    container.layer.shadowOffset = CGSizeMake(5.0f,5.0f);
    container.layer.shadowRadius = 5;
    container.layer.shadowOpacity = 1.0;
    UILabel *tituloProyecto = [[UILabel alloc]initWithFrame:CGRectMake(100, 47, 200, 50)];
    tituloProyecto.text = proyecto.nombre;
    tituloProyecto.backgroundColor=[UIColor clearColor];
    tituloProyecto.textColor=[UIColor whiteColor];
    tituloProyecto.adjustsFontSizeToFitWidth = YES;
    [tituloProyecto setFont:[UIFont fontWithName:@"Helvetica" size:26]];
    
    [view addSubview:container];
    [view addSubview:tituloProyecto];

    [view bringSubviewToFront:container];
    [view bringSubviewToFront:tituloProyecto];
}

-(void)mostrarLabelDeActualizacionConTag:(int)tag enView:(UIView*)view yProyecto:(Proyecto*)proyecto{
    UpdateView *updateBox=[[UpdateView alloc]initWithFrame:CGRectMake(43, 585, 274, 67)];
    updateBox.tag=tag+250;
    [view addSubview:updateBox];
    NSLog(@"update tag----> %i %@",updateBox.tag,updateBox);
    FileSaver *file=[[FileSaver alloc]init];
    NSString *composedTag=[NSString stringWithFormat:@"%i%@",tag,proyecto.idProyecto];
    if ([file getUpdateFileWithString:composedTag]) {
        updateBox.updateText.text=[NSString stringWithFormat:@"Actualizado el: %@",[file getUpdateFileWithString:composedTag]];
        if (![proyecto.actualizado isEqualToString:[file getUpdateFileWithString:composedTag]]) {
            updateBox.titleText.text=@"Hay una neva versión";
            updateBox.titleText.textColor=[UIColor redColor];
            updateBox.titleText.tag=tag+1100;
            updateBox.container.alpha=1;
            updateBox.updateText.textColor=[UIColor orangeColor];
        }
        else{
            updateBox.titleText.backgroundColor=[UIColor clearColor];
            updateBox.titleText.text=@"Tienes la última versión";
            updateBox.titleText.textColor=[UIColor greenColor];
            updateBox.titleText.tag=tag+1100;
            updateBox.updateText.textColor=[UIColor whiteColor];
            updateBox.container.alpha=0;
            UIButton *lebuttons = (UIButton *)[view viewWithTag:tag+1000];
            NSLog(@"Button punto tag %i",lebuttons.tag);
            lebuttons.alpha=1;
        }
    }
    else{
        updateBox.container.alpha=0;
    }
    [view bringSubviewToFront:updateBox];
}
-(void)updateLabelWithTag:(NSNotification*)notification{
    NSDictionary *dictionary=notification.object;
    NSNumber *number=[dictionary objectForKey:@"tag"];
    NSString *ID=[dictionary objectForKey:@"id"];
    
    FileSaver *file=[[FileSaver alloc]init];
    NSString *composedTag=[NSString stringWithFormat:@"%@%@",number,ID];
    
    [file getUpdateFileWithString:composedTag];
    if ([file getUpdateFileWithString:composedTag]) {
        UpdateView *updateBox = (UpdateView *)[scrollView viewWithTag:[number intValue]+250];
        NSLog(@"number li tag----> %i %@",updateBox.tag,updateBox.updateText);
        updateBox.updateText.text=[NSString stringWithFormat:@"Actualizado el: %@",[file getUpdateFileWithString:composedTag]];
        updateBox.container.alpha=0;
        updateBox.titleText.textColor=[UIColor whiteColor];
        UIButton *button = (UIButton *)[scrollView viewWithTag:[number intValue]+1000];
        button.alpha=1;
        //NSLog(@"Updated %@ %@",number,[file getUpdateFile:[number intValue]]);
        
        [self irAlSiguienteViewController:button];
        updateBox.titleText.text=[NSString stringWithFormat:@"Tienes la última versión"];
        updateBox.titleText.textColor=[UIColor greenColor];
    }
}
#pragma mark -
#pragma mark Eventos para ir a otros viewcontrollers

- (void)irAlSiguienteViewController:(UIButton*)sender{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=@"Loading";
    [self performSelector:@selector(delayedAction:) withObject:sender afterDelay:0.3];    
}
-(void)delayedAction:(UIButton*)sender{
    NSString *keyProyecto = [NSString stringWithFormat:@"%i",sender.tag-3000];
    Proyecto *proyecto = [usuarioActual.arrayProyectos objectAtIndex:[keyProyecto intValue]];
    ItemUrbanismo *itemUrbanismo = [proyecto.arrayItemsUrbanismo objectAtIndex:0];
    if (itemUrbanismo.existe==1) {
        [self irAPlantaUrbanaVCConProyecto:proyecto];
    }
    else{
        Grupo *grupo=[itemUrbanismo.arrayGrupos objectAtIndex:0];
        if (grupo.existe==1) {
            TipoDePiso *tipoDePiso=[grupo.arrayTiposDePiso objectAtIndex:0];
            if (tipoDePiso.existe==1) {
                [self irATiposDePisosVCConGrupo:grupo];
            }
            else{
                Producto *producto=[tipoDePiso.arrayProductos objectAtIndex:0];
                [self irATiposDePlantasVCConProducto:producto];
            }
        }
        else{
            TipoDePiso *tipoDePiso=[grupo.arrayTiposDePiso objectAtIndex:0];
                Producto *producto=[tipoDePiso.arrayProductos objectAtIndex:0];
                [self irATiposDePlantasVCConProducto:producto];
        }
    }
}
- (void)irAPlantaUrbanaVCConProyecto:(id)proyecto{
    PlantaUrbanaVC *pgVC = [[PlantaUrbanaVC alloc]init];
    pgVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PlantaUrbanaVC"];
    pgVC.proyecto = proyecto;
    [self.navigationController pushViewController:pgVC animated:YES];
}
- (void)irATiposDePisosVCConGrupo:(id)grupo{
    TiposDePisosVC *peVC = [[TiposDePisosVC alloc]init];
    peVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TiposDePisosVC"];
    peVC.grupo=grupo;
    //peVC.usuarioActual = usuarioActual;
    [self.navigationController pushViewController:peVC animated:YES];
}
- (void)irATiposDePlantasVCConProducto:(id)producto{
    TiposDePlantasVC *tdpVC = [[TiposDePlantasVC alloc]init];
    tdpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TiposDePlantasVC"];
    tdpVC.producto=producto;
    [self.navigationController pushViewController:tdpVC animated:YES];
}

-(void)alertViewAppear{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Error al descargar el proyecto. Por favor intente de nuevo." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}
-(void)sendInfo:(SendInfoButton*)sender{
    SendInfoViewController *siVC=[[SendInfoViewController alloc]init];
    siVC=[self.storyboard instantiateViewControllerWithIdentifier:@"SendInfo"];
    siVC.nombreProyecto=sender.nombreProyecto;
    siVC.proyectoID=sender.proyectoID;
    siVC.usuario=usuarioActual.usuario;
    siVC.currentUser=usuarioActual;
    siVC.contrasena=usuarioActual.contrasena;
    [self.navigationController pushViewController:siVC animated:YES];
}

@end