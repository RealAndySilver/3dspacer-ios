//
//  Espacio3DVC.m
//  Ekoobot 3D
//
//  Created by Andres David Carreño on 6/21/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "Espacio3DVC.h"

@interface Espacio3DVC ()

@end

@implementation Espacio3DVC
@synthesize espacio3D,arregloEspacial,lowerView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    loading=[[LoadingView alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.height, self.view.frame.size.width)];
    [self.navigationController.view addSubview:loading];
    //[loading setViewAlphaToOne:@""];
    //NSLog(@"El Array Epacial %@",arregloEspacial);
    NavController *navController = (NavController *)self.navigationController;
    [navController setInterfaceOrientation:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    view3D=nil;
    espacio3D=nil;
    lowerView=nil;
}

- (void)viewDidDisappear:(BOOL)animated{
    view3D=nil;
    espacio3D=nil;
    lowerView=nil;
    loading=nil;
    arrayCaras=nil;
    arregloEspacial=nil;
    tituloEspacio=nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}
-(void)didReceiveMemoryWarning{
    NSLog(@"Cara Warning %@, %@",espacio3D.nombre,arregloEspacial);
}
-(void)start{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    lowerView=[[UIView alloc]init];
    lowerView.tag=100;
    lowerView.alpha=0;
    flag=NO;
    glFrame=CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height+50);
    //[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(threadParaViewInferior) userInfo:nil repeats:NO];
    [self performSelector:@selector(threadParaViewInferior) withObject:nil afterDelay:0.0];
    //[self viewInferior];
    pastTag=-1;
    threeD=YES;
    self.navigationItem.title=@"Espacio 3D";
    Caras *face=[espacio3D.arrayCaras objectAtIndex:0];
    [self checkIfDownloadedWithFace:face];
    face.atras=[self pathForResourceWithName:@"Atras" andFace:face ID:face.idAtras];
    face.frente=[self pathForResourceWithName:@"Frente" andFace:face ID:face.idFrente];
    face.abajo=[self pathForResourceWithName:@"Abajo" andFace:face ID:face.idAbajo];
    face.izquierda=[self pathForResourceWithName:@"Izquierda" andFace:face ID:face.idIzquierda];
    face.derecha=[self pathForResourceWithName:@"Derecha" andFace:face ID:face.idDerecha];
    face.arriba=[self pathForResourceWithName:@"Arriba" andFace:face ID:face.idArriba];
    view3D=[[OpenGLView alloc]initWithFrame:glFrame andFaces:face andContext:self];
    [self.view addSubview:view3D];
    [self.view bringSubviewToFront:lowerView];
    rightButton = [[UIBarButtonItem alloc] initWithTitle:@"touch " style:UIBarButtonItemStylePlain target:self action:@selector(navButtonAction:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    //[loading setViewAlphaToCero];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleView:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [view3D addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleView2:)];
    [doubleTap setNumberOfTapsRequired:2];
    [doubleTap setNumberOfTouchesRequired:1];
    //[view3D addGestureRecognizer:doubleTap];
    
    //[singleTap requireGestureRecognizerToFail:doubleTap];
}
- (void)viewWillAppear:(BOOL)animated{
    [self start];
}
-(void)navButtonAction:(UIButton*)sender{
    if (threeD) {
        rightButton.title=@"3D ";
        [view3D cambiarToquePorMotion:sender];
        threeD=NO;
        return;
    }
    else{
        rightButton.title=@"touch ";
        [view3D cambiarToquePorMotion:sender];
        threeD=YES;
        return;
    }
}
-(void)checkIfDownloadedWithFace:(Caras*)cara{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSMutableArray *array=[[NSMutableArray alloc]initWithObjects:cara.arriba,cara.abajo,cara.izquierda,cara.derecha,cara.frente,cara.atras, nil];
    NSMutableArray *idarray=[[NSMutableArray alloc]initWithObjects:cara.idArriba,cara.idAbajo,cara.idIzquierda,cara.idDerecha,cara.idFrente,cara.idAtras, nil];
    NSMutableArray *stringArray=[[NSMutableArray alloc]initWithObjects:@"Arriba",@"Abajo",@"Izquierda",@"Derecha",@"Frente",@"Atras", nil];
    for (int i=0; i<array.count; i++) {
        NSString *jpegFilePath = [NSString stringWithFormat:@"%@/cara%@%@.jpeg",docDir,[stringArray objectAtIndex:i],[idarray objectAtIndex:i]];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
        if (!fileExists) {
            NSString *jpegFilePath2 = [NSString stringWithFormat:@"%@/cara%@%@.jpeg",docDir,[stringArray objectAtIndex:i],[idarray objectAtIndex:i]];
            NSURL *urlImagen=[NSURL URLWithString:[array objectAtIndex:i]];
            NSData *data=[NSData dataWithContentsOfURL:urlImagen];
            UIImageView *proyectoImage = [[UIImageView alloc]init];
            proyectoImage.image = [UIImage imageWithData:data];
            NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(proyectoImage.image, 1.0f)];
            if (proyectoImage.image) {
                [data2 writeToFile:jpegFilePath2 atomically:YES];
                //NSLog(@"jpegFilePath2 %@",jpegFilePath2);
            }
        }
        
    }
}
-(NSString*)pathForResourceWithName:(NSString*)name andFace:(Caras*)cara ID:(NSString*)ID{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/cara%@%@.jpeg",docDir,name,ID];
    return jpegFilePath;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    NSLog(@"Autorotate 2");
    return NO;
}
-(BOOL)shouldAutorotate{
    NSLog(@"Autorotate 1");
    return NO;
}
-(NSUInteger)supportedInterfaceOrientations{
    NSLog(@"mmmm");
    return 3;
}

-(void)threadParaViewInferior{
    [self performSelectorInBackground:@selector(viewInferior) withObject:nil];
}
-(void)viewInferior{
    lowerView.frame=CGRectMake(0, 610, self.view.frame.size.width, 140);
    lowerView.backgroundColor=[UIColor clearColor];
    [lowerView setUserInteractionEnabled:YES];
    UIView *alphaView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, lowerView.frame.size.width, lowerView.frame.size.height)];
    alphaView.backgroundColor=[UIColor blackColor];
    alphaView.alpha=0.3;
    alphaView.tag=200;
    [lowerView addSubview:alphaView];
    [lowerView sendSubviewToBack:alphaView];
    
    tituloEspacio=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 25)];
    tituloEspacio.center=CGPointMake(lowerView.frame.size.width/2, 15);
    tituloEspacio.backgroundColor=[UIColor clearColor];
    tituloEspacio.textAlignment=UITextAlignmentCenter;
    tituloEspacio.textColor=[UIColor whiteColor];
    tituloEspacio.text=espacio3D.nombre;
    tituloEspacio.tag=201;
    [lowerView addSubview:tituloEspacio];
    
    UIButton *boton = [[UIButton alloc]init];
    UIImage *imageButton = [UIImage imageNamed:@"boton.png"];
    [boton setImage:imageButton forState:UIControlStateNormal];
    boton.backgroundColor=[UIColor clearColor];
    [boton addTarget:self action:@selector(toggleView:) forControlEvents:UIControlEventTouchUpInside];
    boton.frame=CGRectMake(10, 5,20, 30);
    boton.tag=205;
    //[lowerView addSubview:boton];
    [self.view addSubview:lowerView];
    [self insertarListaDeThumbsEnView:arregloEspacial];
    [self animateViewFadeIn:lowerView];
}
-(void)toggleView:(UIButton*)button{
    CGRect posInicial=CGRectMake(0, 610, self.view.frame.size.width, 140);
    CGRect posFinal=CGRectMake(0, 720, self.view.frame.size.width, 150);
    float time=0.2;
    if (flag) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:time];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        lowerView.frame=posInicial;
        [[self navigationController] setNavigationBarHidden:NO animated:NO];
        [UIView commitAnimations];
        flag=NO;
        return;
    }
    else {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:time];
        lowerView.frame=posFinal;
        [UIView commitAnimations];
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
        flag=YES;
        return;
    }
}
-(void)toggleView2:(UIButton*)button{
    NSLog(@"double tap");
    [view3D zoom];
}
-(void)insertarListaDeThumbsEnView:(NSMutableArray*)array{
    int tamano=90;
    int margen=10;
    int diferencia=3;
    int posicion=35;
    
    for (int i=1; i<arregloEspacial.count+1; i++) {
        Espacio3D *espacio=[array objectAtIndex:i-1];
        Caras *caras=[espacio.arrayCaras objectAtIndex:0];
        UIView *back=[[UIView alloc]initWithFrame:CGRectMake(((tamano+margen)*(i-1)+15), posicion,tamano, tamano)];
        back.tag=i;
        if (espacio3D.nombre==espacio.nombre) {
            back.backgroundColor=[UIColor whiteColor];
            initialTag=back.tag;
            borderFlag=YES;
        }
        else{
            back.backgroundColor=[UIColor grayColor];
        }
        UIButton *boton = [[UIButton alloc]init];
        UIImage *imageButton =[UIImage imageWithContentsOfFile:[self pathForResourceWithName:@"Izquierda" andFace:caras ID:caras.idIzquierda]];
        //NSLog(@"Resource %@ array espacio %@",[self pathForResourceWithName:@"Izquierda" andFace:caras space:espacio],array);
        [boton setImage:imageButton forState:UIControlStateNormal];
        [boton setImage:imageButton forState:UIControlStateHighlighted];
        [boton setTitle:espacio.nombre forState:UIControlStateNormal];
        boton.tag=i;
        [boton addTarget:self action:@selector(spaceSelected:) forControlEvents:UIControlEventTouchUpInside];
        boton.frame=CGRectMake(diferencia/2, diferencia/2,tamano-diferencia, tamano-diferencia);
        [back addSubview:boton];
        
        UILabel *spaceName=[[UILabel alloc]initWithFrame:CGRectMake(0, 70, back.frame.size.width, 20)];
        spaceName.backgroundColor=[UIColor blackColor];
        spaceName.text=espacio.nombre;
        spaceName.textColor=[UIColor whiteColor];
        spaceName.textAlignment=UITextAlignmentCenter;
        spaceName.font=[UIFont fontWithName:@"Helvetica" size:10];
        //[back addSubview:spaceName];
        
        [lowerView addSubview:back];
    }
}
-(void)animateViewFadeIn:(UIView*)view{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    view.alpha=1;
    [UIView commitAnimations];
}
-(void)animateViewFadeOutScale{
    /*[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    view3D.frame=CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0);
    view3D.alpha=0.1;
    [UIView commitAnimations];*/
}
-(void)animateViewFadeInScale{
    /*[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    view3D.frame=glFrame;
    view3D.alpha=1;
    [UIView commitAnimations];*/
}
-(void)spaceSelected:(UIButton*)sender{
    //NSLog(@"tag touched %i",sender.tag);
    [self.view setUserInteractionEnabled:NO];
    UIView *getView = (UIView*)[lowerView viewWithTag:sender.tag];
    UIView *getPastView = (UIView*)[lowerView viewWithTag:pastTag];
    if (getView!=getPastView) {
        getPastView.backgroundColor=[UIColor grayColor];
    }
    if (borderFlag) {
        UIView *getPastView = (UIView*)[lowerView viewWithTag:initialTag];
        getPastView.backgroundColor=[UIColor grayColor];
        borderFlag=NO;
    }
    getView.backgroundColor=[UIColor whiteColor];
    
    [self performSelectorInBackground:@selector(animateViewFadeOutScale) withObject:nil];
    [lowerView setUserInteractionEnabled:NO];
    //Espacio3D *espacio=[arregloEspacial objectAtIndex:sender.tag-1];
    espacio3D=[arregloEspacial objectAtIndex:sender.tag-1];
    tituloEspacio.text=espacio3D.nombre;
    [loading setViewAlphaToOne:espacio3D.nombre];
    Caras *caras=[espacio3D.arrayCaras objectAtIndex:0];
    [self start3DViewWithFaces:caras andFrame:glFrame space:espacio3D];
    [loading setViewAlphaToCero];
    [lowerView setUserInteractionEnabled:YES];
    [self animateViewFadeInScale];
    pastTag=sender.tag;
    [self.view setUserInteractionEnabled:YES];
    
}
-(void)bthreadTest:(UIButton*)button{
    NSLog(@"Sender tag: %i",button.tag);
}
-(void)start3DViewWithFaces:(Caras*)faces andFrame:(CGRect)frame space:(Espacio3D*)space{
    [view3D deleteTextures];
    [self checkIfDownloadedWithFace:faces];
    faces.atras=[self pathForResourceWithName:@"Atras" andFace:faces ID:faces.idAtras];
    faces.frente=[self pathForResourceWithName:@"Frente" andFace:faces ID:faces.idFrente];
    faces.abajo=[self pathForResourceWithName:@"Abajo" andFace:faces ID:faces.idAbajo];
    faces.izquierda=[self pathForResourceWithName:@"Izquierda" andFace:faces ID:faces.idIzquierda];
    faces.derecha=[self pathForResourceWithName:@"Derecha" andFace:faces ID:faces.idDerecha];
    faces.arriba=[self pathForResourceWithName:@"Arriba" andFace:faces ID:faces.idArriba];
    view3D._topTexture=[view3D setupTexture:faces.arriba];
    view3D._bottomTexture=[view3D setupTexture:faces.abajo];
    view3D._frontTexture=[view3D setupTexture:faces.frente];
    view3D._backTexture=[view3D setupTexture:faces.atras];
    view3D._leftTexture=[view3D setupTexture:faces.izquierda];
    view3D._rightTexture=[view3D setupTexture:faces.derecha];
}
-(void)cleaner{
    view3D._context=nil;
}

@end
