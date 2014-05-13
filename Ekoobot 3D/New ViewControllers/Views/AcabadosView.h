//
//  AcabadosView.h
//  Ekoobot 3D
//
//  Created by Developer on 13/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AcabadosViewDelegate <NSObject>
-(void)AcabadoWasSelectedAtIndex:(NSUInteger)index;
@end

@interface AcabadosView : UIView
@property (strong, nonatomic) id <AcabadosViewDelegate> delegate;
@end
