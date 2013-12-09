//
//  CustomButton.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 6/07/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Proyecto.h"

@interface CustomButton : UIButton{
}
@property(nonatomic)int secondaryId;
@property(nonatomic)id adjunto;
@property(nonatomic)id extraContent;
@property(nonatomic)float gradosExtra;
@property(nonatomic)NSString *path;
@property(nonatomic)UIImageView *imageView;


@end
