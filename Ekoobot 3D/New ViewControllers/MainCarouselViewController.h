//
//  MainCarouselViewController.h
//  Ekoobot 3D
//
//  Created by Diego Vidal on 8/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainCarouselViewController : UIViewController
@property (strong, nonatomic) NSArray *userProjectsArray;
-(void)downloadProjectFromServer:(UIButton *)downloadButton;
@end
