//
//  LoadingView.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 12/07/12.
//  Copyright (c) 2012 iAmStudio SAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView{
    UIActivityIndicatorView *spinner;
    UILabel *loading;
    UIProgressView *progressBar;
    NSThread *progressThread;
    NSThread *stopThread;
}
-(void)setViewAlphaToOne:(NSString*)string;
-(void)setViewAlphaToCero;
@end