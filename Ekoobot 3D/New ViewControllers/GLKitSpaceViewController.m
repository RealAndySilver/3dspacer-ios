//
//  GLKitSpaceViewController.m
//  Ekoobot 3D
//
//  Created by Developer on 5/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "GLKitSpaceViewController.h"
#import "More3DScenesView.h"
#import "CMMotionManager+Shared.h"
#import <CoreLocation/CoreLocation.h>
#import "UIImage+Resize.h"
#import "MBProgressHud.h"
#import "AcabadosView.h"
#import "Finish.h"
#import "Space.h"
#import "FinishImage+AddOns.h"

@interface GLKitSpaceViewController () <More3DScenesViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate, AcabadosViewDelegate>
@property (strong, nonatomic) GLKTextureInfo *cubemapTexture;
@property (strong, nonatomic) GLKSkyboxEffect *skyboxEffect;
@property (strong, nonatomic) UIImageView *brujula;
@property (strong, nonatomic) UIImageView *compassPlaceholder;
@property (strong, nonatomic) UIImageView *compassOn;
@property (strong, nonatomic) UIBarButtonItem *interactionTypeBarButton;
@property (strong, nonatomic) More3DScenesView *more3DScenesView;
@property (strong, nonatomic) AcabadosView *acabadosView;
@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;
@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) NSTimer *inertiaTimer;

@property (strong, nonatomic) NSMutableArray *finishesArray;
@property (strong, nonatomic) NSMutableArray *finishesImagesArray;
@property (strong, nonatomic) NSMutableDictionary *carasIds;
@end

@implementation GLKitSpaceViewController {
    GLfloat x, y, z;
    GLfloat rotXAxis, rotYAxis, rotZAxis;
    BOOL compassIsOff;
    CGRect screenBounds;
    BOOL deviceIsLeftRotated;
    GLfloat rotationFactor;
    CGPoint movementVector;
    NSUInteger acabadoSeleccionado;
    CMMotionManager *motionManager;
    BOOL magnetomerIsActive;
}

#pragma mark - Lazy Instantiation 

-(NSMutableDictionary *)carasIds {
    if (!_carasIds) {
        _carasIds = [[NSMutableDictionary alloc] init];
        for (int i = 0; i < [self.finishesImagesArray count]; i++) {
            FinishImage *finishImage = self.finishesImagesArray[i];
            if ([finishImage.type isEqualToString:@"back"]) {
                [_carasIds setObject:finishImage.identifier forKey:@"back"];
            } else if ([finishImage.type isEqualToString:@"top"]) {
                [_carasIds setObject:finishImage.identifier forKey:@"top"];
            } else if ([finishImage.type isEqualToString:@"down"] || [finishImage.type isEqualToString:@"bottom"]) {
                [_carasIds setObject:finishImage.identifier forKey:@"down"];
            } else if ([finishImage.type isEqualToString:@"left"]) {
                [_carasIds setObject:finishImage.identifier forKey:@"left"];
            } else if ([finishImage.type isEqualToString:@"right"]) {
                [_carasIds setObject:finishImage.identifier forKey:@"right"];
            } else if ([finishImage.type isEqualToString:@"front"]) {
                [_carasIds setObject:finishImage.identifier forKey:@"front"];
            }
        }
    }
    return _carasIds;
}

-(NSMutableArray *)finishesImagesArray {
    
    if (!_finishesImagesArray) {
        Finish *finish = self.finishesArray[0];

        _finishesImagesArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.projectDic[@"finishImages"] count]; i++) {
            FinishImage *finishImage = self.projectDic[@"finishImages"][i];
            if ([finishImage.finish isEqualToString:finish.identifier]) {
                [_finishesImagesArray addObject:finishImage];
            }
        }
    }
    return _finishesImagesArray;
}

-(void)setupFinishesArray {
    Space *space = self.arregloDeEspacios3D[self.espacioSeleccionado];
    NSLog(@"número de acabados en el proyecto: %d", [self.projectDic[@"finishes"] count]);
    self.finishesArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.projectDic[@"finishes"] count]; i++) {
        Finish *finish = self.projectDic[@"finishes"][i];
        if ([finish.space isEqualToString:space.identifier]) {
            [self.finishesArray addObject:finish];
        }
    }
    NSLog(@"*** Acabados encontrados para este espacio '%@' con id %@: %d", space.name, space.identifier, [self.finishesArray count]);
}

-(void)changeFinishesArray {
    [self.finishesArray removeAllObjects];
    
    Space *space = self.arregloDeEspacios3D[self.espacioSeleccionado];
    NSLog(@"número de acabados en el proyecto: %d", [self.projectDic[@"finishes"] count]);
    for (int i = 0; i < [self.projectDic[@"finishes"] count]; i++) {
        Finish *finish = self.projectDic[@"finishes"][i];
        if ([finish.space isEqualToString:space.identifier]) {
            [self.finishesArray addObject:finish];
        }
    }
    self.acabadosView.finishesArray = self.finishesArray;
}

-(void)changeFinishesImagesArray {
    [self.finishesImagesArray removeAllObjects];
    
    //Finish *finish = self.finishesArray[0];
    Finish *finish = self.finishesArray[acabadoSeleccionado];
    FinishImage *finishImage;
    for (int i = 0; i < [self.projectDic[@"finishImages"] count]; i++) {
        finishImage = self.projectDic[@"finishImages"][i];
        if ([finishImage.finish isEqualToString:finish.identifier]) {
            [self.finishesImagesArray addObject:finishImage];
        }
    }
    finishImage = nil;
}

-(void)changeCarasIds {
    FinishImage *finishImage;
    for (int i = 0; i < [self.finishesImagesArray count]; i++) {
        finishImage = self.finishesImagesArray[i];
        if ([finishImage.type isEqualToString:@"back"]) {
            [self.carasIds setObject:finishImage.identifier forKey:@"back"];
        } else if ([finishImage.type isEqualToString:@"top"]) {
            [self.carasIds setObject:finishImage.identifier forKey:@"top"];
        } else if ([finishImage.type isEqualToString:@"down"] || [finishImage.type isEqualToString:@"bottom"]) {
            [self.carasIds setObject:finishImage.identifier forKey:@"down"];
        } else if ([finishImage.type isEqualToString:@"left"]) {
            [self.carasIds setObject:finishImage.identifier forKey:@"left"];
        } else if ([finishImage.type isEqualToString:@"right"]) {
            [self.carasIds setObject:finishImage.identifier forKey:@"right"];
        } else if ([finishImage.type isEqualToString:@"front"]) {
            [self.carasIds setObject:finishImage.identifier forKey:@"front"];
        }
    }
    finishImage = nil;
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setupFinishesArray];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification
                                               object:[UIDevice currentDevice]];
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    NSLog(@"device orientation: %d", deviceOrientation);
    if (deviceOrientation == 3) {
        deviceIsLeftRotated = YES;
    } else {
        deviceIsLeftRotated = NO;
    }
    
    CGRect screen = [UIScreen mainScreen].bounds;
    screenBounds = CGRectMake(0.0, 0.0, screen.size.height, screen.size.width);
    x = 0;
    y = 0;
    z = -0.3272;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        rotationFactor = 0.002;
    } else {
        rotationFactor = 0.004;
    }
    self.view.tag = 1;
    self.navigationItem.title = NSLocalizedString(@"Espacio3D", nil);
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self setupUI];
    [self setupGL];
    [self createGestureRecognizers];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startDeviceMotion];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopDeviceMotion];
    [self.inertiaTimer invalidate];
    self.inertiaTimer = nil;
    
    [self tearDownGL];
}

-(void)tearDownGL {
    NSLog(@"Nileaaaaannnndooooooooo");
    [EAGLContext setCurrentContext:nil];
    
    GLuint name = self.cubemapTexture.name;
    glDeleteTextures(1, &name);
    
    self.skyboxEffect = nil;
    self.cubemapTexture = nil;
    self.acabadosView = nil;
    self.more3DScenesView = nil;
    self.finishesArray = nil;
    self.carasIds = nil;
    self.finishesImagesArray = nil;
}

-(void)setupUI {
    CGRect screenFrame = screenBounds;
    
    //Create a bar button item
    self.interactionTypeBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Toque", nil) style:UIBarButtonItemStylePlain target:self action:@selector(setupInteractionType)];
    self.navigationItem.rightBarButtonItem = self.interactionTypeBarButton;
    
    //Compass Placeholder
    CGRect compassFrame;
    CGRect more3DScenesRect;
    CGRect acabadosViewFrame;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        more3DScenesRect = CGRectMake(0.0, screenFrame.size.height - 30.0, screenFrame.size.width, 190.0);
        compassFrame = CGRectMake(screenFrame.size.width - 100.0, screenFrame.size.height/7.68, 80.0, 80.0);
        acabadosViewFrame = CGRectMake(-180.0, 120.0, 150.0, 400.0);
    } else {
        more3DScenesRect = CGRectMake(screenFrame.size.width - 160.0, screenFrame.size.height - 30.0, 160.0, 190.0);
        compassFrame = CGRectMake(screenFrame.size.width - 70.0, 64.0, 50.0, 50.0);
        acabadosViewFrame = CGRectMake(-180.0, 120.0, 150.0, screenFrame.size.height - 120.0);
    }
    
    self.compassPlaceholder = [[UIImageView alloc] initWithFrame:compassFrame];
    self.compassPlaceholder.image = [UIImage imageNamed:@"brujula.png"];
    self.compassPlaceholder.userInteractionEnabled = YES;
    [self.view addSubview:self.compassPlaceholder];
    
    //Indicador de la brújula
    UIImage *brujulaImage = [UIImage imageNamed:@"cursor.png"];
    self.brujula = [[UIImageView alloc] initWithImage:[brujulaImage flippedImageByAxis:MVImageFlipXAxis]];
    self.brujula.frame = CGRectMake(self.compassPlaceholder.frame.size.width/2.0 - 10.0, 10.0, compassFrame.size.height/4.0, self.compassPlaceholder.frame.size.height - 20.0);
    self.brujula.center = CGPointMake(self.compassPlaceholder.frame.size.width/2.0, self.compassPlaceholder.frame.size.height/2.0);
    [self.compassPlaceholder addSubview:self.brujula];
    
    //Turn on Compass ImageView
    self.compassOn = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"compassOn.png"]];
    self.compassOn.frame = CGRectMake(0.0, 0.0, self.compassPlaceholder.frame.size.width, self.compassPlaceholder.frame.size.height);
    self.compassOn.alpha = 0.0;
    [self.compassPlaceholder addSubview:self.compassOn];
    
    //Add the Inferior view
    self.more3DScenesView = [[More3DScenesView alloc] initWithFrame:more3DScenesRect];
    self.more3DScenesView.delegate = self;
    self.more3DScenesView.espacios3DArray = self.arregloDeEspacios3D;
    
    //Search for the thumbs images to display in the inferior view
    NSMutableArray *thumbsArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.arregloDeEspacios3D count]; i++) {
        Space *space = self.arregloDeEspacios3D[i];
        for (int j = 0; j < [self.projectDic[@"finishes"] count]; j++) {
            Finish *finish = self.projectDic[@"finishes"][j];
            if ([finish.space isEqualToString:space.identifier]) {
                for (int k = 0; k < [self.projectDic[@"finishImages"] count]; k++) {
                    FinishImage *finishImage = self.projectDic[@"finishImages"][k];
                    if ([finishImage.finish isEqualToString:finish.identifier] && [finishImage.type isEqualToString:@"back"]) {
                        [thumbsArray addObject:[finishImage finishImage]];
                        break;
                    }
                }
                break;
            }
        }
    }
    NSLog(@"Thumbs encontrados: %lu", (unsigned long)[thumbsArray count]);
    self.more3DScenesView.thumbsArray = thumbsArray;
    Space *space = self.arregloDeEspacios3D[self.espacioSeleccionado];
    self.more3DScenesView.titleLabel.text = space.name;
    [self.view addSubview:self.more3DScenesView];
    [self.view bringSubviewToFront:self.more3DScenesView];
    
    //Add the 'Acabados' view
    self.acabadosView = [[AcabadosView alloc] initWithFrame:acabadosViewFrame];
    
    //Search for the finishes of this space
    NSMutableArray *finishesArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.projectDic[@"finishes"] count]; i++) {
        Finish *finish = self.projectDic[@"finishes"][i];
        if ([finish.space isEqualToString:space.identifier]) {
            NSLog(@"*** Encontré un acabado para este espacio");
            [finishesArray addObject:finish];
        }
    }
    self.acabadosView.finishesArray = finishesArray;
    self.acabadosView.delegate = self;
    [self.view addSubview:self.acabadosView];
}

-(void)createGestureRecognizers {
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rotateScene:)];
    
    //Add a tap gesture to the CompassPlaceholder
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(compassPlaceholderTapped)];
    [self.compassPlaceholder addGestureRecognizer:tapGesture];
    
    //Add a tap gesture to show the navigation bar and the lower view
    UITapGestureRecognizer *showViewsTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleComplementaryViews)];
    showViewsTapGesture.cancelsTouchesInView = NO;
    showViewsTapGesture.delegate = self;
    [self.view addGestureRecognizer:showViewsTapGesture];
    
    //Pinch Gesture to amke zoom
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomIn:)];
    [self.view addGestureRecognizer:pinchGesture];
}

#pragma mark - OpenGL Stuff

-(void)setupGL {
    magnetomerIsActive = YES;
    //Set GLContext
    self.preferredFramesPerSecond = 60.0;
    GLKView *view = (GLKView *)self.view;
    //view.layer.minificationFilter = kCAFilterNearest;
    //view.layer.magnificationFilter = kCAFilterNearest;
    
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glEnable(GL_DEPTH_TEST);
    
    [self resizeCubeImages];
    /*NSArray *skyboxArray = @[[self pathForJPEGResourceWithName:@"Derecha" ID:@"Spaces_16_2013-01-30 19:40:28"],
                             [self pathForJPEGResourceWithName:@"Izquierda" ID:@"Spaces_14_2013-01-30 19:40:28"],
                             [self pathForJPEGResourceWithName:@"Arriba" ID:@"Spaces_18_2013-01-30 19:40:28"],
                             [self pathForJPEGResourceWithName:@"Abajo" ID:@"Spaces_17_2013-01-30 19:40:28"],
                             [self pathForJPEGResourceWithName:@"Atras" ID:@"Spaces_13_2013-01-30 19:40:28"],
                             [self pathForJPEGResourceWithName:@"Frente" ID:@"Spaces_15_2013-01-30 19:40:28"]];*/
    
    //Espacio3D *espacio3D = self.arregloDeEspacios3D[self.espacioSeleccionado];
    //Caras *caras = espacio3D.arrayCaras[0];
    NSArray *skyboxArray = @[[self pathForPNGResourceWithName:@"FlippedDerecha" ID:self.carasIds[@"right"]],
                             [self pathForPNGResourceWithName:@"FlippedIzquierda" ID:self.carasIds[@"left"]],
                             [self pathForPNGResourceWithName:@"FlippedFrente" ID:self.carasIds[@"front"]],
                             [self pathForPNGResourceWithName:@"FlippedAtras" ID:self.carasIds[@"back"]],
                             [self pathForPNGResourceWithName:@"FlippedArriba" ID:self.carasIds[@"top"]],
                             [self pathForPNGResourceWithName:@"FlippedAbajo" ID:self.carasIds[@"down"]]];
    
    NSError *error;
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft: @NO};
    
    GLuint name = self.cubemapTexture.name;
    glDeleteTextures(1, &name);
    
    self.cubemapTexture = [GLKTextureLoader cubeMapWithContentsOfFiles:skyboxArray options:options error:&error];
    if (self.cubemapTexture) {
        NSLog(@"se pudo cargar la textura, %d, %d", self.cubemapTexture.height, self.cubemapTexture.width);
    }
    
    //Setup the skybox shader
    self.skyboxEffect = [[GLKSkyboxEffect alloc] init];
    self.skyboxEffect.label = @"SkyboxEffect";
    self.skyboxEffect.textureCubeMap.name = self.cubemapTexture.name;
    self.skyboxEffect.textureCubeMap.target = self.cubemapTexture.target;
    self.skyboxEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), screenBounds.size.width/screenBounds.size.height, 1.0, 100.0);
    self.skyboxEffect.transform.modelviewMatrix = GLKMatrix4MakeScale(10.0, 10.0, 10.0);
    self.skyboxEffect.center = GLKVector3Make(0.0, 0.0, 0.0);
    [self.skyboxEffect prepareToDraw];

    /*glEnable(GL_TEXTURE_2D);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);*/
    
}

#pragma mark - GLKViewDelegate

-(void)update {
    if (magnetomerIsActive) {
        if (deviceIsLeftRotated) {
            rotXAxis = motionManager.deviceMotion.attitude.roll;
            rotZAxis = -motionManager.deviceMotion.attitude.yaw - M_PI;
            rotYAxis = -motionManager.deviceMotion.attitude.pitch;
        } else {
            rotXAxis = -motionManager.deviceMotion.attitude.roll;
            rotZAxis = -motionManager.deviceMotion.attitude.yaw;
            rotYAxis = motionManager.deviceMotion.attitude.pitch;
        }
    }
    
    GLKMatrix4 identity = GLKMatrix4Identity;
    GLKMatrix4 modelviewMatrix = GLKMatrix4Translate(identity, x, y, z);
    modelviewMatrix = GLKMatrix4Rotate(modelviewMatrix, rotXAxis, 1.0, 0.0, 0.0);
    modelviewMatrix = GLKMatrix4Rotate(modelviewMatrix, rotYAxis, 0.0, 1.0, 0.0);
    modelviewMatrix = GLKMatrix4Rotate(modelviewMatrix, rotZAxis, 0.0, 0.0, 1.0);
    modelviewMatrix = GLKMatrix4Scale(modelviewMatrix, 10.0, 10.0, 10.0);
    self.skyboxEffect.transform.modelviewMatrix = modelviewMatrix;
    [self.skyboxEffect prepareToDraw];

    [self rotateCompassWithRadians:-rotZAxis];
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self.skyboxEffect draw];
}

#pragma mark - Actions 

-(void)toggleComplementaryViews {
    static BOOL viewsAreVisible = NO;
    if (!viewsAreVisible) {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^(){
                             [self.navigationController setNavigationBarHidden:NO animated:YES];
                             self.more3DScenesView.transform = CGAffineTransformMakeTranslation(0.0, -160.0);
                             self.acabadosView.transform = CGAffineTransformMakeTranslation(178.0, 0.0);
                         } completion:^(BOOL finished){}];
        viewsAreVisible = YES;
    } else {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^(){
                             [self.navigationController setNavigationBarHidden:YES animated:YES];
                             self.more3DScenesView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                             self.acabadosView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                         } completion:^(BOOL finished){}];
        viewsAreVisible = NO;
    }
}

-(void)setupInteractionType {
    static BOOL panningInteractionEnabled = NO;
    if (!panningInteractionEnabled) {
        //Activate panning interaction
        magnetomerIsActive = NO;
        [self.view addGestureRecognizer:self.panGesture];
        rotYAxis = 0;
        [self stopDeviceMotion];
        self.interactionTypeBarButton.title = NSLocalizedString(@"3D", nil);
        panningInteractionEnabled = YES;
    } else {
        magnetomerIsActive = YES;
        [self.view removeGestureRecognizer:self.panGesture];
        [self startDeviceMotion];
        self.interactionTypeBarButton.title = NSLocalizedString(@"Toque", nil);
        panningInteractionEnabled = NO;
    }
}

-(void)compassPlaceholderTapped {
    if (compassIsOff) {
        self.compassOn.alpha = 0.0;
        compassIsOff = NO;
    } else {
        self.compassOn.alpha = 1.0;
        compassIsOff = YES;
    }
}

-(void)rotateScene:(UIPanGestureRecognizer *)recognizer {
    static CGPoint panPrevious;
    static CGPoint point1;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.inertiaTimer invalidate];
        self.inertiaTimer = nil;
        
        panPrevious = [recognizer locationInView:self.view];
        
    } else if (recognizer.state != UIGestureRecognizerStateEnded){
        CGPoint panLocation = [recognizer locationInView:self.view];
        CGPoint panDelta = CGPointMake(panLocation.x - panPrevious.x, panLocation.y - panPrevious.y);
        rotXAxis -= panDelta.y*rotationFactor;
        if (rotXAxis < - 2.90) {
            rotXAxis = -2.90;
        } else if (rotXAxis > 0) {
            rotXAxis = 0;
        }
        rotZAxis -= panDelta.x*rotationFactor;
        NSLog(@"rot x: %f, rot y: %f, rot z: %f", rotXAxis, rotYAxis, rotZAxis);
        [self rotateCompassWithRadians:-rotZAxis];
        point1 = panPrevious;
        panPrevious = panLocation;
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint point2 = [recognizer locationInView:self.view];
        NSLog(@"Point 1: %@", NSStringFromCGPoint(point1));
        NSLog(@"Point 2: %@", NSStringFromCGPoint(point2));
        movementVector = CGPointMake(point2.x - point1.x, point2.y - point1.y);
        NSLog(@"Vector: %@", NSStringFromCGPoint(movementVector));
        [self stopSceneRotationWithInertia];
    }
}

-(void)stopSceneRotationWithInertia {
    self.inertiaTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(calculateSceneRotationValues) userInfo:nil repeats:YES];
}

-(void)calculateSceneRotationValues {
    NSLog(@"calculando valores de rotacion %@", NSStringFromCGPoint(movementVector));
    rotXAxis -= movementVector.y*rotationFactor;
    rotZAxis -= movementVector.x*rotationFactor;
    
    movementVector.x = movementVector.x/1.2;
    movementVector.y = movementVector.y/1.2;
    
    if (fabs(movementVector.x) < 0.1 && fabs(movementVector.y) < 0.1) {
        [self.inertiaTimer invalidate];
        self.inertiaTimer = nil;
    }
    
    [self rotateCompassWithRadians:-rotZAxis];
}

-(void)zoomIn:(UIPinchGestureRecognizer *)pinchGesture {
    /*const GLfloat factorEscalamiento = 0.02;
    static GLfloat currentScale = 0;
    static GLfloat lastScale = 0;
    
    currentScale += pinchGesture.scale - lastScale;
    lastScale = pinchGesture.scale;
    
    if (currentScale > 1) z += currentScale * factorEscalamiento;
    else if (currentScale < 1) z -= currentScale * factorEscalamiento;
    if (z <= -0.3272) z = -0.3272;
    pinchGesture.scale = 1.0;
    NSLog(@"z:%f", z);*/
}

#pragma mark - Custom Methods

-(void)resizeCubeImages {
    NSLog(@"entré a resize cube images");
    UIImage *theImage;
    NSLog(@"*** Número de imágenes para el acabado seleccionado: %d", [self.finishesImagesArray count]);
    FinishImage *finishImage;
    for (int i = 0; i < [self.finishesImagesArray count]; i++) {
        finishImage = self.finishesImagesArray[i];
        
        if ([finishImage.type isEqualToString:@"back"]) {
            theImage = [finishImage finishImage];
            //theImage = [UIImage imageWithImage:theImage scaledToSize:CGSizeMake(512.0, 512.0)];
            [self saveImage:theImage withName:@"FlippedAtras" identifier:finishImage.identifier format:@"png"];
        
        } else if ([finishImage.type isEqualToString:@"left"]) {
            theImage = [finishImage finishImage];
            //theImage = [UIImage imageWithImage:theImage scaledToSize:CGSizeMake(512.0, 512.0)];
            theImage = [theImage rotateImage:theImage onDegrees:90.0];
            theImage = [theImage flippedImageByAxis:MVImageFlipYAxis];
            [self saveImage:theImage withName:@"FlippedIzquierda" identifier:finishImage.identifier format:@"png"];
        
        } else if ([finishImage.type isEqualToString:@"front"]) {
            theImage = [finishImage finishImage];
            //theImage = [UIImage imageWithImage:theImage scaledToSize:CGSizeMake(512.0, 512.0)];
            theImage = [theImage flippedImageByAxis:MVImageFlipYAxis];
            [self saveImage:theImage withName:@"FlippedFrente" identifier:finishImage.identifier format:@"png"];

        } else if ([finishImage.type isEqualToString:@"right"]) {
            theImage = [finishImage finishImage];
            //theImage = [UIImage imageWithImage:theImage scaledToSize:CGSizeMake(512.0, 512.0)];
            theImage = [theImage rotateImage:theImage onDegrees:90.0];
            theImage = [theImage flippedImageByAxis:MVImageFlipXAxisAndYAxis];
            [self saveImage:theImage withName:@"FlippedDerecha" identifier:finishImage.identifier format:@"png"];

        } else if ([finishImage.type isEqualToString:@"top"]) {
            theImage = [finishImage finishImage];
            //theImage = [UIImage imageWithImage:theImage scaledToSize:CGSizeMake(512.0, 512.0)];
            theImage = [theImage flippedImageByAxis:MVImageFlipXAxisAndYAxis];
            [self saveImage:theImage withName:@"FlippedArriba" identifier:finishImage.identifier format:@"png"];
        
        } else if ([finishImage.type isEqualToString:@"down"] || [finishImage.type isEqualToString:@"bottom"]) {
            theImage = [finishImage finishImage];
            //theImage = [UIImage imageWithImage:theImage scaledToSize:CGSizeMake(512.0, 512.0)];
            theImage = [theImage flippedImageByAxis:MVImageFlipYAxis];
            [self saveImage:theImage withName:@"FlippedAbajo" identifier:finishImage.identifier format:@"png"];
        }
    }
    finishImage = nil;
    
    /*Espacio3D *espacio3D = self.arregloDeEspacios3D[self.espacioSeleccionado];
    Caras *caras = espacio3D.arrayCaras[0];
    
    UIImage *image = [UIImage imageWithContentsOfFile:[self pathForJPEGResourceWithName:@"Frente" ID:caras.idFrente]];
    UIImage *resizeImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(512.0, 512.0)];
    resizeImage = [resizeImage flippedImageByAxis:MVImageFlipYAxis];
    [self saveImage:resizeImage withName:@"FlippedFrente" identifier:caras.idFrente format:@"png"];
    
    image = [UIImage imageWithContentsOfFile:[self pathForJPEGResourceWithName:@"Izquierda" ID:caras.idIzquierda]];
    resizeImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(512.0, 512.0)];
    resizeImage = [resizeImage rotateImage:resizeImage onDegrees:90.0];
    resizeImage = [resizeImage flippedImageByAxis:MVImageFlipYAxis];
    [self saveImage:resizeImage withName:@"FlippedIzquierda" identifier:caras.idIzquierda format:@"png"];
    
    image = [UIImage imageWithContentsOfFile:[self pathForJPEGResourceWithName:@"Derecha" ID:caras.idDerecha]];
    resizeImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(512.0, 512.0)];
    resizeImage = [resizeImage rotateImage:resizeImage onDegrees:90.0];
    resizeImage = [resizeImage flippedImageByAxis:MVImageFlipXAxisAndYAxis];
    [self saveImage:resizeImage withName:@"FlippedDerecha" identifier:caras.idDerecha format:@"png"];
    
    image = [UIImage imageWithContentsOfFile:[self pathForJPEGResourceWithName:@"Arriba" ID:caras.idArriba]];
    resizeImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(512.0, 512.0)];
    resizeImage = [resizeImage flippedImageByAxis:MVImageFlipXAxisAndYAxis];
    [self saveImage:resizeImage withName:@"FlippedArriba" identifier:caras.idArriba format:@"png"];

    image = [UIImage imageWithContentsOfFile:[self pathForJPEGResourceWithName:@"Abajo" ID:caras.idAbajo]];
    resizeImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(512.0, 512.0)];
    resizeImage = [resizeImage flippedImageByAxis:MVImageFlipYAxis];
    [self saveImage:resizeImage withName:@"FlippedAbajo" identifier:caras.idAbajo format:@"png"];
    
    image = [UIImage imageWithContentsOfFile:[self pathForJPEGResourceWithName:@"Atras" ID:caras.idAtras]];
    resizeImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(512.0, 512.0)];
    [self saveImage:resizeImage withName:@"FlippedAtras" identifier:caras.idAtras format:@"png"];*/
}

-(void)startDeviceMotion {
    CMAttitudeReferenceFrame attitude;
    motionManager = [CMMotionManager sharedMotionManager];
    
    if (motionManager.magnetometerAvailable) {
        NSLog(@"*** El magnetómetro está disponible ***");
        attitude = CMAttitudeReferenceFrameXMagneticNorthZVertical;
    } else {
        NSLog(@"*** El magnetómetro no está disponible ***");
        attitude = CMAttitudeReferenceFrameXArbitraryZVertical;
        [self.compassPlaceholder removeFromSuperview];
    }
    
    if (motionManager.deviceMotionAvailable) {
        NSLog(@"** Entré a calcular valores del sensor ***");
        motionManager.deviceMotionUpdateInterval = 1.0/60.0;
        [motionManager startDeviceMotionUpdatesUsingReferenceFrame:attitude];
        /*[motionManager startDeviceMotionUpdatesUsingReferenceFrame:attitude toQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error){
            if (deviceIsLeftRotated) {
                
                rotXAxis = motion.attitude.roll;
                rotZAxis = -motion.attitude.yaw - M_PI;
                rotYAxis = -motion.attitude.pitch;
            } else {
                rotXAxis = -motion.attitude.roll;
                rotZAxis = -motion.attitude.yaw;
                rotYAxis = motion.attitude.pitch;
            }
            [self updateViewWithRotX:rotXAxis rotY:rotYAxis rotZ:rotZAxis];;
            //NSLog(@"Attitude X:%f, Y:%f, Z:%f", rotXAxis, rotYAxis, rotZAxis);
            [self rotateCompassWithRadians:-rotZAxis];
        }];*/
    } else {
        NSLog(@"*** el sensor no está disponible ***");
    }
}

/*-(void)updateViewWithRotX:(float)rotX rotY:(float)rotY rotZ:(float)rotZ {
    GLKMatrix4 identity = GLKMatrix4Identity;
    GLKMatrix4 modelviewMatrix = GLKMatrix4Translate(identity, x, y, z);
    
    modelviewMatrix = GLKMatrix4Rotate(modelviewMatrix, rotXAxis, 1.0, 0.0, 0.0);
    modelviewMatrix = GLKMatrix4Rotate(modelviewMatrix, rotYAxis, 0.0, 1.0, 0.0);
    modelviewMatrix = GLKMatrix4Rotate(modelviewMatrix, rotZAxis, 0.0, 0.0, 1.0);
    modelviewMatrix = GLKMatrix4Scale(modelviewMatrix, 10.0, 10.0, 10.0);
    self.skyboxEffect.transform.modelviewMatrix = modelviewMatrix;
}*/

-(void)stopDeviceMotion {
    [[CMMotionManager sharedMotionManager] stopDeviceMotionUpdates];
}

-(void)rotateCompassWithRadians:(CGFloat)radians {
    self.brujula.transform = CGAffineTransformRotate(CGAffineTransformIdentity, radians);
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    NSLog(@"tag de la vista tocada: %d", touch.view.tag);
    if (touch.view.tag == 1) {
        return YES;
    } else {
        return NO;
    }
}

-(void)showLoadingOpacityView {
    acabadoSeleccionado = 0;
    self.opacityView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.0;
    [self.navigationController.view addSubview:self.opacityView];
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.opacityView.alpha = 0.75;
                     } completion:^(BOOL finished){
                         [self changeFinishesArray];
                         [self changeFinishesImagesArray];
                         [self changeCarasIds];
                         [self changeCubeImages];
                     }];
}

-(void)showLoadingOpacityViewWhileFinishIsChanged {
    self.opacityView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.0;
    [self.navigationController.view addSubview:self.opacityView];
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.opacityView.alpha = 0.75;
                     } completion:^(BOOL finished){
                         [self changeFinishesImagesArray];
                         [self changeCarasIds];
                         [self changeCubeImages];
                     }];
}

-(void)changeCubeImages {
    GLuint name = self.cubemapTexture.name;
    glDeleteTextures(1, &name);
    
    [self resizeCubeImages];
    
    NSArray *skyboxArray = @[[self pathForPNGResourceWithName:@"FlippedDerecha" ID:self.carasIds[@"right"]],
                             [self pathForPNGResourceWithName:@"FlippedIzquierda" ID:self.carasIds[@"left"]],
                             [self pathForPNGResourceWithName:@"FlippedFrente" ID:self.carasIds[@"front"]],
                             [self pathForPNGResourceWithName:@"FlippedAtras" ID:self.carasIds[@"back"]],
                             [self pathForPNGResourceWithName:@"FlippedArriba" ID:self.carasIds[@"top"]],
                             [self pathForPNGResourceWithName:@"FlippedAbajo" ID:self.carasIds[@"down"]]];
    
    self.cubemapTexture = [GLKTextureLoader cubeMapWithContentsOfFiles:skyboxArray options:nil error:NULL];
    self.skyboxEffect.textureCubeMap.name = self.cubemapTexture.name;
    self.skyboxEffect.textureCubeMap.target = self.cubemapTexture.target;
    //self.skyboxEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), screenBounds.size.width/screenBounds.size.height, 1.0, 100.0);
    //self.skyboxEffect.transform.modelviewMatrix = GLKMatrix4MakeScale(10.0, 10.0, 10.0);
    //[self.skyboxEffect prepareToDraw];
    
    [self removeOpacityView];
}

-(void)removeOpacityView {
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.opacityView.alpha = 0.0;
                     } completion:^(BOOL finished){
                         [self.opacityView removeFromSuperview];
                         self.opacityView = nil;
                     }];
}

#pragma mark - AcabadosViewDelegate

-(void)AcabadoWasSelectedAtIndex:(NSUInteger)index {
    NSLog(@"Seleccioné el acabado en la posicion %d", index);
    if (acabadoSeleccionado != index) {
        acabadoSeleccionado = index;
        [self showLoadingOpacityViewWhileFinishIsChanged];
    }
    [self toggleComplementaryViews];
}

#pragma mark - More3DScenesViewDelegate

-(void)sceneWasSelectedAtIndex:(NSUInteger)index inView:(More3DScenesView *)more3DScenesView {
    NSLog(@"Escena seleccionada: %d", index);
    if (self.espacioSeleccionado != index) {
        self.espacioSeleccionado = index;
        Space *space = self.arregloDeEspacios3D[self.espacioSeleccionado];
        self.more3DScenesView.titleLabel.text = space.name;
        [self showLoadingOpacityView];
    }
    [self toggleComplementaryViews];
}

#pragma mark - Image Saving and stuff

-(void)saveImage:(UIImage *)image withName:(NSString *)name identifier:(NSString *)identifier format:(NSString *)format{
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/cara%@%@.%@", docDir, name, identifier, format];
    NSLog(@"Entré a guardar la imagen");
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:jpegFilePath];
    if (!fileExist) {
        NSLog(@"La imagen no existía en documents directory, así que la guardaré");
        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
        [imageData writeToFile:jpegFilePath atomically:YES];
    } else {
        NSLog(@"La imagen ya existía, así que no la guardé en documents directory");
    }
}

-(NSString*)pathForJPEGResourceWithName:(NSString*)name ID:(NSString*)ID{
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/cara%@%@.jpeg",docDir,name,ID];
    return jpegFilePath;
}

-(NSString*)pathForPNGResourceWithName:(NSString*)name ID:(NSString*)ID{
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/cara%@%@.png",docDir,name,ID];
    return jpegFilePath;
}

#pragma mark - Device Orientation Notification

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationLandscapeLeft:
            deviceIsLeftRotated = YES;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            deviceIsLeftRotated = NO;
            break;
            
        default:
            break;
    };
}

@end
