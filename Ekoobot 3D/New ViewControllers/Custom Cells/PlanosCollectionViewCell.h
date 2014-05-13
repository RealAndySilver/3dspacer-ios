//
//  PlanosCollectionViewCell.h
//  Ekoobot 3D
//
//  Created by Developer on 6/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PlanosCollectionViewCell;

@protocol PlanoCollectionViewCellDelegate <NSObject>
-(void)espacio3DButtonWasSelectedWithTag:(NSUInteger)tag inCell:(PlanosCollectionViewCell *)cell;
-(void)brujulaButtonWasTappedInCell:(PlanosCollectionViewCell *)cell;
@end

@interface PlanosCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *planoImageView;
@property (strong, nonatomic) UILabel *areaTotalLabel;
@property (strong, nonatomic) id <PlanoCollectionViewCellDelegate> delegate;

-(void)setEspacios3DButtonsFromArray:(NSArray *)espacios3DArray;
-(void)removeAllPinsFromArray:(NSArray *)espacios3DArray;
@end
