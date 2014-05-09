//
//  ProyectoCollectionViewCell.h
//  Ekoobot 3D
//
//  Created by Diego Vidal on 8/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProyectoCollectionViewCell;

@protocol ProyectoCollectionViewCellDelegate <NSObject>
-(void)zoomButtonTappedInCell:(ProyectoCollectionViewCell *)cell;
@end

@interface ProyectoCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) id <ProyectoCollectionViewCellDelegate> delegate;
@end
