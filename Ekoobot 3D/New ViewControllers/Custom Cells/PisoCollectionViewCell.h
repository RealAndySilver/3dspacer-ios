//
//  PisoCollectionViewCell.h
//  Ekoobot 3D
//
//  Created by Developer on 9/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PisoCollectionViewCell;

@protocol PisoCollectionViewCellDelegate <NSObject>
-(void)pinButtonWasSelectedWithIndex:(NSUInteger)index inCell:(PisoCollectionViewCell *)cell;
-(void)brujulaButtonTappedInCell:(PisoCollectionViewCell *)cell;
@end

@interface PisoCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *pisoImageView;
@property (assign, nonatomic) CGFloat zoomScale;
@property (assign, nonatomic) BOOL showCompass;
@property (strong, nonatomic) id <PisoCollectionViewCellDelegate> delegate;

-(void)setPinsButtonsFromArray:(NSArray *)pinsArray;
-(void)removeAllPinsFromArray:(NSArray *)pinsArray;
@end
