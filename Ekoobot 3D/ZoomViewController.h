//
//  ZoomViewController.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 10/12/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomViewController : UIViewController<UIScrollViewDelegate>{
    BOOL zoomCheck;
    float maximumZoomScale;
    float minimumZoomScale;
    UIScrollView *scrollViewImagen;
    UIImageView *imageViewZoomImage;
}
@property(nonatomic)NSString *path;
@end
