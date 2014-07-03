//
//  BrujulaView.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 11/12/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@class BrujulaView;

@protocol BrujulaViewDelegate <NSObject>
-(void)brujulaViewWasTapped:(BrujulaView *)brujulaView;
@end

@interface BrujulaView : UIView{
    UIImageView *compassPlaceholder;
    UIImageView *compassOverlay;
}
@property(nonatomic,retain)UIImageView *cursor;
@property(nonatomic)BOOL isOn;
@property (strong, nonatomic) id <BrujulaViewDelegate> delegate;
-(void)changeState;

@end
