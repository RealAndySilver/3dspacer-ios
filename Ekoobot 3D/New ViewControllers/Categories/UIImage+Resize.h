//
//  UIImage+Resize.h
//  Ekoobot 3D
//
//  Created by Developer on 6/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MVImageFlipXAxis = 0,
    MVImageFlipYAxis,
    MVImageFlipXAxisAndYAxis
}MVImageFlip;

@interface UIImage (Resize)
+(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
- (UIImage *)flippedImageByAxis:(MVImageFlip)axis;
- (UIImage *)rotateImage:(UIImage *)image onDegrees:(float)degrees;
@end
