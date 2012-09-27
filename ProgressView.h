//
//  ProgressView.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 4/07/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressView : UIView{
    UIActivityIndicatorView *spinner;
    //UILabel *loading;
    UIProgressView *progressBar;
    NSThread *progressThread;
    NSThread *stopThread;
}
@property(strong,nonatomic,retain)UILabel *loading;

-(void)setViewAlphaToOne;
-(void)setViewAlphaToCero;
@end
