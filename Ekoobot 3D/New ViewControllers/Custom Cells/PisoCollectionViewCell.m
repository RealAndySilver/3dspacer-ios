//
//  PisoCollectionViewCell.m
//  Ekoobot 3D
//
//  Created by Developer on 9/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "PisoCollectionViewCell.h"
#import "Product.h"
#import "ShadowLabel.h"

@interface PisoCollectionViewCell() <UIScrollViewDelegate>
@property (strong, nonatomic) UIButton *brujulaButton;
@property (strong, nonatomic) UIScrollView *scrollView;
@end

@implementation PisoCollectionViewCell

-(void)setZoomScale:(CGFloat)zoomScale {
    _zoomScale = zoomScale;
    self.scrollView.zoomScale = zoomScale;
}

-(void)setShowCompass:(BOOL)showCompass {
    _showCompass = showCompass;
    if (showCompass) {
        self.brujulaButton.hidden = NO;
    } else {
        self.brujulaButton.hidden = YES;
    }
}

-(void)removeAllPinsFromArray:(NSArray *)pinsArray {
    for (int i = 0; i < 20; i++) {
        if ([self.contentView viewWithTag:i + 1]) {
            [[self.pisoImageView viewWithTag:i + 1] removeFromSuperview];
            [[self.pisoImageView viewWithTag:i + 20] removeFromSuperview];
            
            //Remove the pin button and it's label
            /*[UIView animateWithDuration:0.2
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(){
                                 [self.pisoImageView viewWithTag:i + 1].alpha = 0.0;
                                 [self.pisoImageView viewWithTag:i + 20].alpha = 0.0;
                             } completion:^(BOOL finished){
                                 [[self.pisoImageView viewWithTag:i + 1] removeFromSuperview];
                                 [[self.pisoImageView viewWithTag:i + 20] removeFromSuperview];
                             }];*/
        }
    }
}

-(void)setPinsButtonsFromArray:(NSArray *)pinsArray {
    for (int i = 0; i < [pinsArray count]; i++) {
        if (![self.contentView viewWithTag:i + 1]) {
            Product *product = pinsArray[i];
            
            //Pin Button
            CGFloat fontSize;
            CGRect pinButtonFrame;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                fontSize = 17.0;
                pinButtonFrame = CGRectMake([product.xCoord floatValue], [product.yCoord floatValue] - 30.0, 30.0, 30.0);
            } else {
                fontSize = 15.0;
                pinButtonFrame = CGRectMake((398*[product.xCoord floatValue])/1004.0 + 90.0, (230.0*[product.yCoord floatValue])/580.0 - 30.0, 25.0, 25.0);
            }
            UIButton *pinButton = [[UIButton alloc] initWithFrame:pinButtonFrame];
            pinButton.tag = i + 1;
            [pinButton setImage:[UIImage imageNamed:@"pin.png"] forState:UIControlStateNormal];
            [pinButton addTarget:self action:@selector(pinButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            pinButton.alpha = 1.0;
            [self.pisoImageView addSubview:pinButton];
            
            //Button Label
            ShadowLabel *nameLabel = [[ShadowLabel alloc] initWithFrame:CGRectMake(pinButton.frame.origin.x + pinButton.frame.size.width, pinButton.frame.origin.y, 200.0, 30.0)];
            nameLabel.text = product.name;
            nameLabel.tag = i + 20;
            nameLabel.textColor = [UIColor whiteColor];
            nameLabel.font = [UIFont boldSystemFontOfSize:fontSize];
            [nameLabel drawTextInRect:nameLabel.frame];
            //nameLabel.layer.shadowColor = [UIColor blackColor].CGColor;
            //nameLabel.layer.shadowOffset = CGSizeMake(1.0, 1.0);
            //nameLabel.layer.shadowOpacity = 1.0;
            //nameLabel.layer.shadowRadius = 1.0;
            nameLabel.alpha = 1.0;
            [self.pisoImageView addSubview:nameLabel];
            
            /*[UIView animateWithDuration:0.2
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(){
                                 pinButton.alpha = 1.0;
                                 nameLabel.alpha = 1.0;
                             } completion:^(BOOL finished){}];*/
        }
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
        
        //ScrollView
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.minimumZoomScale = 1.0;
        self.scrollView.maximumZoomScale = 2.0;
        self.scrollView.delegate = self;
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self.contentView addSubview:self.scrollView];
        
        //Piso ImageView
        self.pisoImageView = [[UIImageView alloc] init];
        self.pisoImageView.backgroundColor = [UIColor blackColor];
        self.pisoImageView.clipsToBounds = YES;
        self.pisoImageView.userInteractionEnabled = YES;
        self.pisoImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:self.pisoImageView];
        
        //Brujula button
        self.brujulaButton = [[UIButton alloc] init];
        [self.brujulaButton setBackgroundImage:[UIImage imageNamed:@"compassOn.png"] forState:UIControlStateNormal];
        [self.brujulaButton addTarget:self action:@selector(brujulaButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.brujulaButton];
        
        //Zoom gesture
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(makeZoom:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [self.pisoImageView addGestureRecognizer:doubleTapGesture];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.scrollView.frame = CGRectMake(0.0, 0.0, contentRect.size.width, contentRect.size.height - 40.0);
        self.brujulaButton.frame = CGRectMake(contentRect.size.width - 85.0, 0.0, 70.0, 70.0);

    } else {
        self.scrollView.frame = CGRectMake(0.0, 0.0, contentRect.size.width, contentRect.size.height - 20.0);
        self.brujulaButton.frame = CGRectMake(contentRect.size.width - 85.0, 10.0, 55.0, 55.0);
    }
    self.pisoImageView.frame = CGRectMake(0.0, 0.0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    NSLog(@"frame piso: %@", NSStringFromCGRect(self.pisoImageView.frame));
}

#pragma mark - Actions 

-(void)brujulaButtonTapped {
    [self.delegate brujulaButtonTappedInCell:self];
}

-(void)pinButtonTapped:(UIButton *)sender {
    NSLog(@"*** Toqué el botóooooonn");
    [self.delegate pinButtonWasSelectedWithIndex:sender.tag inCell:self];
}

-(void)makeZoom:(UITapGestureRecognizer *)recognizer {
    NSLog(@"hice double tap");
    if(self.scrollView.zoomScale>=1.0 && self.scrollView.zoomScale<=1.5){
        CGPoint Pointview=[recognizer locationInView:self.scrollView];
        CGFloat newZoomscal=3.0;
        
        newZoomscal=MIN(newZoomscal, 5.0);
        
        CGSize scrollViewSize=self.scrollView.bounds.size;
        
        CGFloat w=scrollViewSize.width/newZoomscal;
        CGFloat h=scrollViewSize.height/newZoomscal;
        CGFloat x= Pointview.x-(w/2.0);
        CGFloat y = Pointview.y-(h/2.0);
        
        CGRect rectTozoom=CGRectMake(x, y, w, h);
        [self.scrollView zoomToRect:rectTozoom animated:YES];
        
        [self.scrollView setZoomScale:2.0 animated:YES];
    }
    else{
        [self.scrollView setZoomScale:1.0 animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.pisoImageView;
}


@end
