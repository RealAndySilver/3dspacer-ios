//
//  OpenGLView.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 4/17/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import "OpenGLView.h"
#import "CC3GLMatrix.h"
#import "Espacio3DVC.h"

@implementation OpenGLView
@synthesize leftRotated;
@synthesize _backTexture,_frontTexture,_leftTexture,_rightTexture,_topTexture,_bottomTexture,_context,headingValue,theContext,timer1;
#pragma mark Indices y Vertices
typedef struct {
    float Position[3];
    float Color[4];
    float TexCoord[2]; // New
} Vertex;

#define TEX_COORD_MAX   1
#define CUBE_SIZE   5
#define CAMERA360 90
#define CAMERA180 0
const Vertex Vertices[] = {
    // Front
    {{CUBE_SIZE, -CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, 0}},
    {{CUBE_SIZE, CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-CUBE_SIZE, CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {0, TEX_COORD_MAX}},
    {{-CUBE_SIZE, -CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {0, 0}},
    // Back
    {{-CUBE_SIZE, CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, 0}},
    {{-CUBE_SIZE, -CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{CUBE_SIZE, -CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {0, TEX_COORD_MAX}},
    {{CUBE_SIZE, CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {0, 0}},
    // Right
    {{-CUBE_SIZE, -CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, 0}},
    {{-CUBE_SIZE, CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-CUBE_SIZE, CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {0, TEX_COORD_MAX}},
    {{-CUBE_SIZE, -CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {0, 0}},
    // Left
    {{CUBE_SIZE, CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, 0}},
    {{CUBE_SIZE, -CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{CUBE_SIZE, -CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {0, TEX_COORD_MAX}},
    {{CUBE_SIZE, CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {0, 0}},
    // Top
    {{CUBE_SIZE, CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, 0}},
    {{CUBE_SIZE, CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-CUBE_SIZE, CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {0, TEX_COORD_MAX}},
    {{-CUBE_SIZE, CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {0, 0}},
    // Bottom
    {{-CUBE_SIZE, -CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, 0}},
    {{-CUBE_SIZE, -CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{CUBE_SIZE, -CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {0, TEX_COORD_MAX}},
    {{CUBE_SIZE, -CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {0, 0}}
};

const GLubyte Indices[] = {
    // Front
    0, 0, 0,
    0, 0, 0,
    // Back
    4, 4, 4,
    4, 4, 4,
    // Right
    8, 8, 8,
    8, 8, 8,
    // Left
    12, 12, 12,
    12, 12, 12,
    // Top
    16, 16, 16,
    16, 16, 16,
    // Bottom
    20, 20, 20,
    20, 20, 20
};
//Front
const Vertex VerticesFront[] = {
    {{CUBE_SIZE, -CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, 0}},
    {{CUBE_SIZE, CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-CUBE_SIZE, CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {0, TEX_COORD_MAX}},
    {{-CUBE_SIZE, -CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {0, 0}}
};
const GLubyte IndicesFront[] = {
    1, 0, 2, 3
};
//Back
const Vertex VerticesBack[] = {
    {{-CUBE_SIZE, CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, 0}},
    {{-CUBE_SIZE, -CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{CUBE_SIZE, -CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {0, TEX_COORD_MAX}},
    {{CUBE_SIZE, CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {0, 0}}
};
const GLubyte IndicesBack[] = {
    0, 1, 3, 2
};
//Right
const Vertex VerticesRight[] = {
    {{-CUBE_SIZE, -CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, 0}},
    {{-CUBE_SIZE, CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-CUBE_SIZE, CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {0, TEX_COORD_MAX}},
    {{-CUBE_SIZE, -CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {0, 0}}
};
const GLubyte IndicesRight[] = {
    0, 1, 3, 2
};
//Left
const Vertex VerticesLeft[] = {
    {{CUBE_SIZE, CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, 0}},
    {{CUBE_SIZE, -CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{CUBE_SIZE, -CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {0, TEX_COORD_MAX}},
    {{CUBE_SIZE, CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {0, 0}}
};
const GLubyte IndicesLeft[] = {
    0, 1, 3, 2
};
//Top
const Vertex VerticesTop[] = {
    {{CUBE_SIZE, CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, 0}},
    {{CUBE_SIZE, CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-CUBE_SIZE, CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {0, TEX_COORD_MAX}},
    {{-CUBE_SIZE, CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {0, 0}}
};
const GLubyte IndicesTop[] = {
    0, 1, 3, 2
};
//Bottom
const Vertex VerticesBottom[] = {
    {{-CUBE_SIZE, -CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, 0}},
    {{-CUBE_SIZE, -CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{CUBE_SIZE, -CUBE_SIZE, -CUBE_SIZE}, {1, 1, 1, 1}, {0, TEX_COORD_MAX}},
    {{CUBE_SIZE, -CUBE_SIZE, CUBE_SIZE}, {1, 1, 1, 1}, {0, 0}}
};
const GLubyte IndicesBottom[] = {
    0, 1, 3, 2
};

#pragma mark Setups
+(Class)layerClass{
    return [CAEAGLLayer class];
}
-(void)setupLayer{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
}
-(void)setupContext{
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}
-(void)setupRenderBuffer{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}
-(void)setupDepthBuffer{
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
}
-(void)setupFrameBuffer{
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}
-(GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType{
    // 1
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    // 2
    GLuint shaderHandle = glCreateShader(shaderType);
    // 3
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    // 4
    glCompileShader(shaderHandle);
    // 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    return shaderHandle;
}
-(void)compileShaders{
    // 1
    GLuint vertexShader = [self compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];
    // 2
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    // 3
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    // 4
    glUseProgram(programHandle);
    // 5
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    _projectionUniform = glGetUniformLocation(programHandle, "Projection");
    _modelViewUniform = glGetUniformLocation(programHandle, "Modelview");
    _texCoordSlot = glGetAttribLocation(programHandle, "TexCoordIn");
    glEnableVertexAttribArray(_texCoordSlot);
    _textureUniform = glGetUniformLocation(programHandle, "Texture");
}
-(void)setupVBOs{
    //BufferCube
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    //BufferFront
    glGenBuffers(1, &vertexBufferFront);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferFront);
    glBufferData(GL_ARRAY_BUFFER, sizeof(VerticesFront), VerticesFront, GL_STATIC_DRAW);
    glGenBuffers(1, &indexBufferFront);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferFront);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(IndicesFront), IndicesFront, GL_STATIC_DRAW);
    //BufferBack
    glGenBuffers(1, &vertexBufferBack);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferBack);
    glBufferData(GL_ARRAY_BUFFER, sizeof(VerticesBack), VerticesBack, GL_STATIC_DRAW);
    glGenBuffers(1, &indexBufferBack);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferBack);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(IndicesBack), IndicesBack, GL_STATIC_DRAW);
    //BufferRight
    glGenBuffers(1, &vertexBufferRight);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferRight);
    glBufferData(GL_ARRAY_BUFFER, sizeof(VerticesRight), VerticesRight, GL_STATIC_DRAW);
    glGenBuffers(1, &indexBufferRight);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferRight);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(IndicesRight), IndicesRight, GL_STATIC_DRAW);
    //BufferLeft
    glGenBuffers(1, &vertexBufferLeft);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferLeft);
    glBufferData(GL_ARRAY_BUFFER, sizeof(VerticesLeft), VerticesLeft, GL_STATIC_DRAW);
    glGenBuffers(1, &indexBufferLeft);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferLeft);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(IndicesLeft), IndicesLeft, GL_STATIC_DRAW);
    //BufferTop
    glGenBuffers(1, &vertexBufferTop);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferTop);
    glBufferData(GL_ARRAY_BUFFER, sizeof(VerticesTop), VerticesTop, GL_STATIC_DRAW);
    glGenBuffers(1, &indexBufferTop);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferTop);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(IndicesTop), IndicesTop, GL_STATIC_DRAW);
    //BufferBottom
    glGenBuffers(1, &vertexBufferBottom);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferBottom);
    glBufferData(GL_ARRAY_BUFFER, sizeof(VerticesBottom), VerticesBottom, GL_STATIC_DRAW);
    glGenBuffers(1, &indexBufferBottom);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferBottom);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(IndicesBottom), IndicesBottom, GL_STATIC_DRAW);
}
-(void)render:(CADisplayLink*)displayLink{
    
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    glClearColor(0, 0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    projection = [CC3GLMatrix matrix];
    
    
    
    float h = 4.0f * self.frame.size.height / self.frame.size.width;
    if (nearValue<maxZoomOut) {
        nearValue=maxZoomOut;
    }
    if (nearValue>maxZoomIn) {
        nearValue=maxZoomIn;
    }
    [projection populateFromFrustumLeft:-2 andRight:2 andBottom:-h/2 andTop:h/2 andNear:nearValue andFar:400];
    [projection rotateByX:dxActualCamara];
    [projection rotateByY:-dyActualCamara];
    [projection rotateByZ:dzActualCamara];
    
    if (!isTouchEnabled) {
        if (_hasAccelerometer)
        {
            if(!leftRotated){
                attitude = _motionManager.deviceMotion.attitude;
                
                CGAffineTransform swingTransform = CGAffineTransformIdentity;
                swingTransform = CGAffineTransformRotate(swingTransform, [self radiansToDegrees:DegreesToRadians(attitude.yaw)]);
                if (!compassTouched) {
                    brujula.transform = swingTransform;
                }
                
                xx=[self radiansToDegrees:attitude.roll];
                yy=-[self radiansToDegrees:attitude.pitch];
                zz=[self radiansToDegrees:attitude.yaw];
                [projection rotateByX: [self radiansToDegrees:attitude.roll]];
                [projection rotateByZ: [self radiansToDegrees:attitude.pitch]];
                [projection rotateByY: -[self radiansToDegrees:attitude.yaw]];
                //printf("%s",[@"!left" UTF8String]);
            }
            else{
                attitude = _motionManager.deviceMotion.attitude;
                
                CGAffineTransform swingTransform = CGAffineTransformIdentity;
                swingTransform = CGAffineTransformRotate(swingTransform, [self radiansToDegrees:DegreesToRadians(attitude.yaw-DegreesToRadians(180))]);
                if (!compassTouched) {
                    brujula.transform = swingTransform;
                }
                
                xx=-[self radiansToDegrees:attitude.roll];
                yy=-[self radiansToDegrees:attitude.pitch];
                zz=-[self radiansToDegrees:attitude.yaw];
                [projection rotateByX: -[self radiansToDegrees:attitude.roll]];
                [projection rotateByZ: -[self radiansToDegrees:attitude.pitch]];
                [projection rotateByY: -[self radiansToDegrees:attitude.yaw]-180];
            }
        }
    }
    glUniformMatrix4fv(_projectionUniform, 1, 0, projection.glMatrix);
    modelView = [CC3GLMatrix matrix];
    [modelView populateFromTranslation:CC3VectorMake(0, 0, 0)];
    [modelView scaleBy:CC3VectorMake(20, 20, 20)];
    
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
    // 1
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    // 2
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
    //glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _frontTexture);
    //glUniform1i(_textureUniform, 0);
    // 3 - Back
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferBack);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferBack);
    //glActiveTexture(GL_TEXTURE0); // unneccc in practice
    glBindTexture(GL_TEXTURE_2D, _backTexture);
    //glUniform1i(_textureUniform, 0); // unnecc in practice
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    //glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    //glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
    glDrawElements(GL_TRIANGLE_STRIP, sizeof(IndicesBack)/sizeof(IndicesBack[0]), GL_UNSIGNED_BYTE, 0);
    // 4 - Front
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferFront);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferFront);
    //glActiveTexture(GL_TEXTURE0); // unneccc in practice
    glBindTexture(GL_TEXTURE_2D, _frontTexture);
    //glUniform1i(_textureUniform, 0); // unnecc in practice
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    //glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    //glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
    glDrawElements(GL_TRIANGLE_STRIP, sizeof(IndicesFront)/sizeof(IndicesFront[0]), GL_UNSIGNED_BYTE, 0);
    // 5 - Right
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferRight);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferRight);
    //glActiveTexture(GL_TEXTURE0); // unneccc in practice
    glBindTexture(GL_TEXTURE_2D, _rightTexture);
    //glUniform1i(_textureUniform, 0); // unnecc in practice
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    //glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    //glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
    glDrawElements(GL_TRIANGLE_STRIP, sizeof(IndicesRight)/sizeof(IndicesRight[0]), GL_UNSIGNED_BYTE, 0);
    // 6 - Left
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferLeft);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferLeft);
    //glActiveTexture(GL_TEXTURE0); // unneccc in practice
    glBindTexture(GL_TEXTURE_2D, _leftTexture);
    //glUniform1i(_textureUniform, 0); // unnecc in practice
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    //glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    //glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
    glDrawElements(GL_TRIANGLE_STRIP, sizeof(IndicesLeft)/sizeof(IndicesLeft[0]), GL_UNSIGNED_BYTE, 0);
    // 7 - Top
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferTop);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferTop);
    //glActiveTexture(GL_TEXTURE0); // unneccc in practice
    glBindTexture(GL_TEXTURE_2D, _topTexture);
    //glUniform1i(_textureUniform, 0); // unnecc in practice
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    //glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    //glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
    glDrawElements(GL_TRIANGLE_STRIP, sizeof(IndicesTop)/sizeof(IndicesTop[0]), GL_UNSIGNED_BYTE, 0);
    // 8 - Bottom
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferBottom);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferBottom);
    //glActiveTexture(GL_TEXTURE0); // unneccc in practice
    glBindTexture(GL_TEXTURE_2D, _bottomTexture);
    //glUniform1i(_textureUniform, 0); // unnecc in practice
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    //glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    //glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
    glDrawElements(GL_TRIANGLE_STRIP, sizeof(IndicesBottom)/sizeof(IndicesBottom[0]), GL_UNSIGNED_BYTE, 0);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
}
-(void)setupDisplayLink{
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(GLuint)setupTexture:(NSString *)fileName{
    // 1
    CGImageRef spriteImage = [UIImage imageWithContentsOfFile:fileName].CGImage;
    //CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        //exit(1);
    }
    // 2
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    // 3
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    CGContextRelease(spriteContext);
    // 4
    GLuint texName;
    /*glGenTextures(1, &texName);
     glBindTexture(GL_TEXTURE_2D, texName);
     glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
     glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);*/
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    //glDeleteTextures(1, &texName);
    free(spriteData);
    return texName;
}
-(id)initWithFrame:(CGRect)frame andFaces:(Caras*)face andContext:(id)context{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupDepthBuffer];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self compileShaders];
        [self setupVBOs];
        [self setupDisplayLink];

        _backTexture = [self setupTexture:face.atras];
        _frontTexture = [self setupTexture:face.frente];
        _rightTexture = [self setupTexture:face.derecha];
        _leftTexture = [self setupTexture:face.izquierda];
        _topTexture = [self setupTexture:face.arriba];
        _bottomTexture = [self setupTexture:face.abajo];
        
        Espacio3DVC *nvc=context;
        
        /*brujula=[[UIView alloc]init];
        brujula.frame=CGRectMake(0, 0, (nvc.compassPlaceholder.frame.size.height-10)*0.15, nvc.compassPlaceholder.frame.size.height-10);
        brujula.center=CGPointMake(nvc.compassPlaceholder.frame.size.width/2,nvc.compassPlaceholder.frame.size.height/2);
        brujula.backgroundColor=[UIColor redColor];
        UIView *whiteView=[[UIView alloc]initWithFrame:CGRectMake(0, brujula.frame.size.height/2, brujula.frame.size.width, brujula.frame.size.height/2)];
        whiteView.backgroundColor=[UIColor whiteColor];
        [brujula addSubview:whiteView];
        [brujula.layer setBorderWidth:3];
        [brujula.layer setBorderColor:[UIColor clearColor].CGColor];
        brujula.layer.shouldRasterize = YES;
        brujula.layer.shadowOffset = CGSizeMake(0, -1);
        brujula.layer.shadowOpacity = 1;
        brujula.layer.shadowColor = [UIColor blackColor].CGColor;*/
        brujula=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cursor.png"]];
        brujula.frame=CGRectMake(0, 0, (nvc.compassPlaceholder.frame.size.height-10)*0.35, nvc.compassPlaceholder.frame.size.height-10);
        brujula.center=CGPointMake(nvc.compassPlaceholder.frame.size.width/2,nvc.compassPlaceholder.frame.size.height/2);
        
        int type = [[UIDevice currentDevice] orientation];
        NSLog(@"El type es %i",type);
        if(type ==3){
            leftRotated=NO;
        }
        else if(type==4){
            leftRotated=YES;
        }
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            if(orientation ==3){
                NSLog(@"OrientacionLandscape numero %i",orientation);
                leftRotated=NO;
                dxActualCamara = CAMERA360;
            }
            else if(orientation==4){
                NSLog(@"OrientacionLandscapeElse numero %i",orientation);
                leftRotated=YES;
                dxActualCamara = CAMERA360;
            }
        } else {
            NSLog(@"Orientacion Portrait numero %i",orientation);

        }
        //_motionManager = [[CMMotionManager alloc] init];
        _motionManager = [self motionManager];
        _motionManager.showsDeviceMovementDisplay = YES;
        
        //[_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical];
        _hasAccelerometer = _motionManager.deviceMotionAvailable;
        if (_hasAccelerometer)
        {
            [_motionManager setDeviceMotionUpdateInterval:1/60];
            [_motionManager startDeviceMotionUpdates];
        }
        [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical];
        isTouchEnabled=NO;
        
        UIPinchGestureRecognizer *twoFingerPinch =
        [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerPinch:)] autorelease];
        [self addGestureRecognizer:twoFingerPinch];
        nearValue=2;
        divisor=10;
        t = 0.0;
        Kf = 0.8;
        m = 1.0;
        step = 0.05;
        sign[0] = sign[1] = -1;
        madeTouch = NO;
        
        maxZoomOut=2;
        maxZoomIn=8;
        //Brújula gráfica
        [nvc.compassPlaceholder addSubview:brujula];
        NSLog(@"el view es %@",context);
        zoomFlag =YES;
        compassTouched=NO;
    }
    
    return self;
}
-(void)compassFlag{
    if (compassTouched) {
        NSLog(@"Touched compass");
        compassTouched=NO;
        return;
    }
    else{
        compassTouched=YES;
        return;
    }
}
-(void)cambiarToquePorMotion:(UIButton*)button{
    if (!isTouchEnabled) {
        dyActualCamara += yy;
        dxActualCamara += xx;
        isTouchEnabled=YES;
        return;
    }
    else {
        isTouchEnabled=NO;
        dxActualCamara=CAMERA360;
        dyActualCamara=0;
        dzActualCamara=0;
    }
}
-(void)deleteTextures{
    glDeleteTextures(1, &_backTexture);
    glDeleteTextures(1, &_frontTexture);
    glDeleteTextures(1, &_bottomTexture);
    glDeleteTextures(1, &_topTexture);
    glDeleteTextures(1, &_leftTexture);
    glDeleteTextures(1, &_rightTexture);
}
-(void)dealloquer{
    NSLog(@"dealoquer");
    [self dealloc];
}
-(void)dealloc{
    NSLog(@"Dealloc Display link %@",displayLink);
    _motionManager.showsDeviceMovementDisplay = NO;
    brujula=nil;
    [displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    //[displayLink invalidate];
    displayLink=nil;
    [self deleteTextures];
    [touchesReceiverOpenGLView release];
    touchesReceiverOpenGLView=nil;
    //[_eaglLayer release];
    _eaglLayer=nil;
    //[modelView release];
    modelView = nil;
    //[projection release];
    projection =nil;
    [_context release];
    _context = nil;
    if ([timer1 isValid]) {
        [timer1 invalidate];
        timer1=nil;
        [timer1 release];
    }
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    //[super dealloc];
}
-(float)radiansToDegrees:(float)number{
    return number * 57.295780;
}

#pragma mark -
#pragma mark Toques
/*- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"began");
    UITouch *touch = [touches anyObject];
    startPoint = [touch locationInView:touchesReceiverOpenGLView];
    oldPoint = startPoint;
    startTime = CACurrentMediaTime();
    imageViewTouched = YES;
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;{
    NSLog(@"Moved");

    if (isTouchEnabled) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:touchesReceiverOpenGLView];
        if (!leftRotated) {
            dy = point.y - startPoint.y;
            dx = point.x - startPoint.x;
            dyActualCamara += dy/divisor;
            dxActualCamara += dx/divisor;
            if (dxActualCamara >= 90) {
                dxActualCamara = 90;
            }
            else if (dxActualCamara <= -90) {
                dxActualCamara = -90;
            }
            
        }
        else {
            dy = point.y - startPoint.y;
            dx = point.x - startPoint.x;
            dyActualCamara += -dy/divisor;
            dxActualCamara += -dx/divisor;
            if (dxActualCamara >= 90) {
                dxActualCamara = -90;
            }
            else if (dxActualCamara <= -90) {
                dxActualCamara = 90;
            }
        }
        oldPoint = point;
        startPoint = point;
        CGAffineTransform swingTransform = CGAffineTransformIdentity;
        swingTransform = CGAffineTransformRotate(swingTransform, DegreesToRadians(dyActualCamara));
        if (!compassTouched) {
            brujula.transform = swingTransform;
        }
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"ended");

}*/
//int i=0;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"began");
    UITouch *touch = [touches anyObject];
    startPoint = [touch locationInView:touchesReceiverOpenGLView];
    oldPoint = startPoint;
    startTime = CACurrentMediaTime();
    imageViewTouched = YES;
    //movePoint1 = movePoint0 = startPoint;
    movePoint0.x = movePoint1.x = dxActualCamara;
    movePoint0.y = movePoint1.y = dyActualCamara;
    //if ([timer1 isValid]) {
    if ([timer1 isValid]) {
        [timer1 invalidate];
        timer1=nil;
        [timer1 release];
        NSLog(@"Invalidating timer in touches began");
    }
    //}
    NSLog(@"Began");
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;{
    //NSLog(@"Moved");
    if (isTouchEnabled) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:touchesReceiverOpenGLView];
        movePoint0 = movePoint1;
        
        if (!leftRotated) {
            dy = point.y - startPoint.y;
            dx = point.x - startPoint.x;
            dyActualCamara += dy/divisor;
            dxActualCamara += dx/divisor;
            if (dxActualCamara >= 90) {
                dxActualCamara = 90;
            }
            else if (dxActualCamara <= -90) {
                dxActualCamara = -90;
            }
            
        }
        else {
            dy = point.y - startPoint.y;
            dx = point.x - startPoint.x;
            dyActualCamara += -dy/divisor;
            dxActualCamara += -dx/divisor;
            if (dxActualCamara >= 90) {
                dxActualCamara = -90;
            }
            else if (dxActualCamara <= -90) {
                dxActualCamara = 90;
            }
        }
        
        movePoint1.x = dxActualCamara;
        movePoint1.y = dyActualCamara;
        /*
         * LOG TO SEE THE STATE OF VARIABLES
        NSLog(@"x0 = (%f,%f)",movePoint0.x,movePoint0.y);
        NSLog(@"x1 = (%f,%f)",movePoint1.x,movePoint1.y);
        NSLog(@"actualCamera = (%f,%f)",dxActualCamara,dyActualCamara);
        NSLog(@"delta = (%f,%f)",dx,dy);
         */
        
        oldPoint = point;
        startPoint = point;
        CGAffineTransform swingTransform = CGAffineTransformIdentity;
        swingTransform = CGAffineTransformRotate(swingTransform, DegreesToRadians(dyActualCamara));
        if (!compassTouched) {
            brujula.transform = swingTransform;
        }
    }
NSLog(@"Moved");
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"ended");
    X[0] = movePoint1.x;
    X[1] = movePoint1.y;
    /*
     * LOG TO SEE THE STATE OF VARIABLES
    NSLog(@"x0 = (%f,%f)",movePoint0.x,movePoint0.y);
    NSLog(@"x1 = (%f,%f)",movePoint1.x,movePoint1.y);
     */

    V[0] = 5.0*(movePoint1.x - movePoint0.x);
    V[1] = 5.0*(movePoint1.y - movePoint0.y);
    /*
     * LOG TO SEE THE STATE OF VARIABLES
    NSLog(@"X = (%f,%f)",X[0],X[1]);
    NSLog(@"V = (%f,%f)",V[0],V[1]);
     */
    if ([timer1 isValid]) {
        [timer1 invalidate];
        timer1=nil;
    }
    timer1=[[NSTimer alloc]init];
    timer1=[NSTimer scheduledTimerWithTimeInterval:1/60 target:self selector:@selector(trigger) userInfo:nil repeats:YES];
    NSLog(@"Ended");
}

-(void)trigger{
    //if(V[0]>0 && V[1]>0) {
    BOOL mContinue = NO;
        for(int k=0;k<2;k++) {
            F[k] = 0;
        }
    
    if (X[0] >= 90) {
        V[0] *=-1;
    }
    else if (X[0] <= -90) {
        V[0] *= -1;
    }
    /*
     * LOG TO SEE THE STATE OF VARIABLES
    NSLog(@"V = (%f,%f)",V[0],V[1]);
     */
    
    for(int k=0;k<2;k++) {
        F[k] -= Kf*V[k];
        mContinue = abs(F[k]) <= 0.00001;
    }
    /*Q
     * LOG TO SEE THE STATE OF VARIABLES
    NSLog(@"F = (%f,%f)",F[0],F[1]);
     */
    
    if(!mContinue) {
        for(int k=0;k<2;k++) {
            f[k] = X[k];
            f[k+2] = V[k];
            df[k] = V[k];
            df[k+2] = F[k]/m;
        }
        
        /*
         * LOG TO SEE THE STATE OF VARIABLES
        NSLog(@"f = (%f,%f,%f,%f)",f[0],f[1],f[2],f[3]);
        NSLog(@"df = (%f,%f,%f,%f)",df[0],df[1],df[2],df[3]);
        */
        
        for(int k=0;k<4;k++) {
            f[k] += df[k]*step;
        }
        
        /*
         * LOG TO SEE THE STATE OF VARIABLES
        NSLog(@"f = (%f,%f,%f,%f)",f[0],f[1],f[2],f[3]);
        */
        
        t += step;
        
        for(int k=0;k<2;k++) {
            X[k] = f[k];
            V[k] = f[k+2];
        }
        
        /*
         * LOG TO SEE THE STATE OF VARIABLES
        NSLog(@"X = (%f,%f)",X[0],X[1]);
        NSLog(@"V = (%f,%f)",V[0],V[1]);
         */
        
        /*
        if (X[0] >= 90) {
            X[0] = -90;
        }
        else if (X[0] <= -90) {
            X[0] = 90;
        }
         */
        
        /*
         * LOG TO SEE THE STATE OF VARIABLES
        NSLog(@"X = (%f,%f)",X[0],X[1]);
        NSLog(@"V = (%f,%f)",V[0],V[1]);
         */
        
        dxActualCamara = X[0];
        dyActualCamara = X[1];
        
        /*
         * LOG TO SEE THE STATE OF VARIABLES
        NSLog(@"delta = (%f,%f)",dxActualCamara,dyActualCamara);
         */
        
        startPoint.x = dxActualCamara;
        startPoint.y = dyActualCamara;
        
        CGAffineTransform swingTransform = CGAffineTransformIdentity;
        swingTransform = CGAffineTransformRotate(swingTransform, DegreesToRadians(dyActualCamara));
        if (!compassTouched) {
            brujula.transform = swingTransform;
        }
        NSLog(@"Keep going");
    }
    else {
        if ([timer1 isValid]) {
            [timer1 invalidate];
            timer1=nil;
            [timer1 release];
            NSLog(@"End timer natural");
        }
    }
    //}
}
-(void)twoFingerPinch:(UIPinchGestureRecognizer *)recognizer {
    nearValue += (1)*(logf(recognizer.scale) * 10.0f);
    float newValue=(nearValue-2)/(maxZoomIn-maxZoomOut);
    divisor=10+(27*newValue);
    recognizer.scale=1;
    if (nearValue==maxZoomOut) {
        zoomFlag=YES;
    }
    else if(nearValue==maxZoomIn){
        zoomFlag=NO;
    }
}
-(void)zoom{
    /*if (nearValue<maxZoomIn) {
     zoomTimer=[NSTimer scheduledTimerWithTimeInterval:1/60 target:self selector:@selector(zoomIn) userInfo:nil repeats:YES];
     }
     else {
     zoomTimer=[NSTimer scheduledTimerWithTimeInterval:1/60 target:self selector:@selector(zoomOut) userInfo:nil repeats:YES];
     }*/
    if (zoomFlag){
        [self zoomIn];
        zoomFlag=NO;
        //[NSObject cancelPreviousPerformRequestsWithTarget:self];
        return;
    }
    else {
        [self zoomOut];
        zoomFlag=YES;
        //[NSObject cancelPreviousPerformRequestsWithTarget:self];
        return;
    }
}
-(void)zoomIn{
    if (nearValue<maxZoomIn) {
        nearValue+=0.020;
        [self performSelectorInBackground:@selector(zoomIn) withObject:nil];
    }
    else{
        nearValue=maxZoomIn;
    }
    
    float newValue=(nearValue-2)/(maxZoomIn-maxZoomOut);
    divisor=10+(27*newValue);
}
-(void)zoomOut{
    if (nearValue>maxZoomOut) {
        nearValue-=0.020;
        //[self performSelector:@selector(zoomOut) withObject:nil afterDelay:1/200];
        [self performSelectorInBackground:@selector(zoomOut) withObject:nil];
    }
    else{
        nearValue=maxZoomOut;
        //[zoomTimer invalidate];
    }
    /*while (nearValue>maxZoomOut) {
     nearValue-=0.1;
     }*/
    float newValue=(nearValue-2)/(maxZoomIn-maxZoomOut);
    divisor=10+(27*newValue);
}
-(CMMotionManager *)motionManager{
    CMMotionManager *motionManager = nil;
    id appDelegate = [UIApplication sharedApplication].delegate;
    if ([appDelegate respondsToSelector:@selector(motionManager)]) {
        motionManager = [appDelegate motionManager];
    }
    return motionManager;
}
@end
