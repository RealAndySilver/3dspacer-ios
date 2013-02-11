//
//  BrujulaView.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 11/12/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface BrujulaView : UIView{
    UIImageView *compassPlaceholder;
    UIImageView *compassOverlay;

}
@property(nonatomic,retain)UIImageView *cursor;
@property(nonatomic)BOOL isOn;
-(void)changeState;

@end
