//
//  More3DScenesView.h
//  Ekoobot 3D
//
//  Created by Developer on 5/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>
@class More3DScenesView;

@protocol More3DScenesViewDelegate <NSObject>
-(void)sceneWasSelectedAtIndex:(NSUInteger)index inView:(More3DScenesView *)more3DScenesView;
@end

@interface More3DScenesView : UIView 
@property (strong, nonatomic) UILabel *titleLabel;
@property (assign, nonatomic) NSUInteger numberOfScenes;
@property (strong, nonatomic) NSArray *espacios3DArray;
@property (strong, nonatomic) NSArray *thumbsArray;
//@property (strong, nonatomic) NSDictionary *projectDic;
@property (strong, nonatomic) id <More3DScenesViewDelegate> delegate;
@end
