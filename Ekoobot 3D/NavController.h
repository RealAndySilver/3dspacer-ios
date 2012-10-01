//
//  NavController.h
//  Ekoobot 3D
//
//  Created by Andrés Abril on 25/09/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavController : UINavigationController
@property(nonatomic)BOOL orient;
@property(nonatomic)int orientationType;
-(void)setInterfaceOrientation:(BOOL)orientation;
@end
