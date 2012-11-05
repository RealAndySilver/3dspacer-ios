//
//  OpenGLView.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 4/17/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CC3GLMatrix.h"
#import <CoreMotion/CoreMotion.h>
#import "Caras.h"


@interface OpenGLView : UIView{
    
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    
    CC3GLMatrix *modelView;
    CC3GLMatrix *projection;
    
    GLuint _colorRenderBuffer;
    GLuint _positionSlot;
    GLuint _colorSlot;
    GLuint _projectionUniform;
    GLuint _modelViewUniform;
    GLuint _depthRenderBuffer;
    
    GLuint _backTexture;
    GLuint _frontTexture;
    GLuint _leftTexture;
    GLuint _rightTexture;
    GLuint _topTexture;
    GLuint _bottomTexture;
    
    GLuint _texCoordSlot;
    GLuint _textureUniform;
    
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    
    GLuint vertexBufferFront;
    GLuint indexBufferFront;
    
    GLuint vertexBufferBack;
    GLuint indexBufferBack;
    
    GLuint vertexBufferLeft;
    GLuint indexBufferLeft;
    
    GLuint vertexBufferRight;
    GLuint indexBufferRight;
    
    GLuint vertexBufferTop;
    GLuint indexBufferTop;
    
    GLuint vertexBufferBottom;
    GLuint indexBufferBottom;
    
    
    OpenGLView *touchesReceiverOpenGLView;
    CGPoint startPoint;
    
    CGFloat dx;
    CGFloat dy;
    CGFloat dxActualCamara;
    CGFloat dyActualCamara;
    CGFloat dzActualCamara;
    
    UIInterfaceOrientation _orientation;
	CMMotionManager *_motionManager;
	BOOL _hasAccelerometer;
    BOOL isTouchEnabled;
    
    CGFloat nearValue;

    CGFloat xx;
    CGFloat yy;
    CGFloat zz;
    
    CGFloat divisor;
    int maxZoomOut;
    int maxZoomIn;
    
    CMAttitude *attitude;
    float headingValue;
    
    CADisplayLink* displayLink;
    
    UIImageView *brujula;
    
    NSTimer *zoomTimer;
    
    BOOL zoomFlag;
    
    
    CFTimeInterval startTime;
    CGPoint oldPoint;
    BOOL imageViewTouched;
    
}
@property(nonatomic)BOOL leftRotated;
@property(nonatomic)GLuint _backTexture;
@property(nonatomic)GLuint _frontTexture;
@property(nonatomic)GLuint _leftTexture;
@property(nonatomic)GLuint _rightTexture;
@property(nonatomic)GLuint _topTexture;
@property(nonatomic)GLuint _bottomTexture;
@property(nonatomic, retain)EAGLContext* _context;
@property(nonatomic)float headingValue;
@property(nonatomic,retain)id theContext;
- (id)initWithFrame:(CGRect)frame andFaces:(Caras*)face andContext:(id)context;
- (GLuint)setupTexture:(NSString *)fileName;
-(void)deleteTextures;
-(void)cambiarToquePorMotion:(UIButton*)button;
-(void)zoom;
@end
