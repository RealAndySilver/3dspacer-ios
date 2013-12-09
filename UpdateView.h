//
//  UpdateView.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 8/10/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface UpdateView : UIView
@property(nonatomic,retain)UIView *container;
@property(nonatomic,retain)UIImageView *backgroundImage;
@property(nonatomic,retain)UILabel *titleText;
@property(nonatomic,retain)UILabel *updateText;
@property(nonatomic,retain)UIButton *infoButton;
@property(nonatomic,retain)UIButton *pesoProyecto;



@end
