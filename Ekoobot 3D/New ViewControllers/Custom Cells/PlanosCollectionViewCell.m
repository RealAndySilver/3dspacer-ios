//
//  PlanosCollectionViewCell.m
//  Ekoobot 3D
//
//  Created by Developer on 6/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "PlanosCollectionViewCell.h"
#import "Space.h"
#import "ShadowLabel.h"

@interface PlanosCollectionViewCell() <UIScrollViewDelegate>
@property (strong, nonatomic) UIButton *brujulaButton;
@property (strong, nonatomic) UIScrollView *scrollView;
@end

@implementation PlanosCollectionViewCell

#pragma mark - Setters

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

-(void)removeAllPinsFromArray:(NSArray *)espacios3DArray {
    for (int i = 0; i < 50; i++) {
        if ([self.contentView viewWithTag:i + 1]) {
            [[self.planoImageView viewWithTag:i + 1] removeFromSuperview];
            [[self.planoImageView viewWithTag:i + 50] removeFromSuperview];
            //Remove the pin button and it's label
            /*[UIView animateWithDuration:0.1
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(){
                                 [self.planoImageView viewWithTag:i + 1].alpha = 0.0;
                                 [self.planoImageView viewWithTag:i + 50].alpha = 0.0;
                             } completion:^(BOOL finished){
                                 [[self.planoImageView viewWithTag:i + 1] removeFromSuperview];
                                 [[self.planoImageView viewWithTag:i + 50] removeFromSuperview];
                             }];*/
        }
    }
}

-(void)setEspacios3DButtonsFromArray:(NSArray *)spacesArray {
    
    for (int i = 0; i < [spacesArray count]; i++) {
        if (![self.contentView viewWithTag:i + 1]) {
            Space *space = spacesArray[i];
            
            //Pin Button
            CGRect pinButtonFrame;
            CGFloat fontSize;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                pinButtonFrame = CGRectMake([space.xCoord floatValue], [space.yCoord floatValue] - 30.0, 30.0, 30.0);
                fontSize = 17.0;
            } else {
                fontSize = 15.0;
                CGFloat xCoord = (350*[space.xCoord floatValue])/984.0 + 90.0;
                CGFloat yCoord = (210*[space.yCoord floatValue])/590.0 - 10.0;
                pinButtonFrame = CGRectMake(xCoord, yCoord, 25.0, 25.0);
            }
            UIButton *pinButton = [[UIButton alloc] initWithFrame:pinButtonFrame];
            [pinButton setImage:[UIImage imageNamed:@"pin.png"] forState:UIControlStateNormal];
            [pinButton addTarget:self action:@selector(espacio3DButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            pinButton.tag = i + 1;
            NSLog(@"Agregué un pin en la posición %@", NSStringFromCGRect(pinButton.frame));
            pinButton.alpha = 1.0;
            [self.planoImageView addSubview:pinButton];
            
            //Button Label
            ShadowLabel *nameLabel = [[ShadowLabel alloc] initWithFrame:CGRectMake(pinButton.frame.origin.x + pinButton.frame.size.width, pinButton.frame.origin.y, 200.0, 30.0)];
            nameLabel.text = space.name;
            nameLabel.tag = i + 50;
            nameLabel.textColor = [UIColor whiteColor];
            nameLabel.font = [UIFont boldSystemFontOfSize:fontSize];
            [nameLabel drawTextInRect:nameLabel.frame];

            //nameLabel.layer.shadowColor = [UIColor blackColor].CGColor;
            //nameLabel.layer.shadowOffset = CGSizeMake(1.0, 1.0);
            //nameLabel.layer.shadowOpacity = 1.0;
            //nameLabel.layer.shadowRadius = 1.0;
            nameLabel.alpha = 1.0;
            [self.planoImageView addSubview:nameLabel];
            
            /*[UIView animateWithDuration:0.1
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(){
                                 pinButton.alpha = 1.0;
                                 nameLabel.alpha = 1.0;
                             } completion:^(BOOL finished){}];*/
        }
    }
}

-(id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        //ScrollView
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.minimumZoomScale = 1.0;
        self.scrollView.maximumZoomScale = 2.0;
        self.scrollView.delegate = self;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        [self.contentView addSubview:self.scrollView];
        
        //Imageview
        self.planoImageView = [[UIImageView alloc] init];
        self.planoImageView.backgroundColor = [UIColor blackColor];
        self.planoImageView.clipsToBounds = YES;
        self.planoImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.planoImageView.userInteractionEnabled = YES;
        [self.scrollView addSubview:self.planoImageView];
        
        //Brujula button
        self.brujulaButton = [[UIButton alloc] init];
        [self.brujulaButton setBackgroundImage:[UIImage imageNamed:@"compassOn.png"] forState:UIControlStateNormal];
        [self.brujulaButton addTarget:self action:@selector(brujulaButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.brujulaButton];
        
        //Area total label
        self.areaTotalLabel = [[UILabel alloc] init];
        self.areaTotalLabel.textAlignment = NSTextAlignmentCenter;
        self.areaTotalLabel.textColor = [UIColor whiteColor];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.areaTotalLabel.font = [UIFont boldSystemFontOfSize:20.0];
        } else {
            self.areaTotalLabel.font = [UIFont boldSystemFontOfSize:14.0];
        }
        [self.contentView addSubview:self.areaTotalLabel];
        
        //Create a Double Tap Gesture Recognizer to make zoom
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(makeZoom:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [self.planoImageView addGestureRecognizer:doubleTapGesture];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    NSLog(@"frame del plano image view: %@", NSStringFromCGRect(self.planoImageView.frame));
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //self.scrollView.frame = CGRectMake(20.0, -10.0, contentRect.size.width - 40.0, contentRect.size.height - 60);
        self.scrollView.frame = CGRectMake(0.0, 0.0, contentRect.size.width, contentRect.size.height - 50.0);
        self.planoImageView.frame = CGRectMake(0.0, 0.0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        self.brujulaButton.frame = CGRectMake(self.planoImageView.frame.size.width - 100.0, 10.0, 80.0, 80.0);
        self.areaTotalLabel.frame = CGRectMake(contentRect.size.width/2.0 - 150.0, self.scrollView.frame.origin.y + self.scrollView.frame.size.height, 300.0, 44.0);

    } else {
        //self.scrollView.frame = CGRectMake(contentRect.size.width/2.0 - 175.0, -10.0, 350.0, contentRect.size.height - 60.0);
        self.scrollView.frame = CGRectMake(0.0, 0.0, contentRect.size.width, contentRect.size.height - 30.0);
        self.planoImageView.frame = CGRectMake(0.0, 0.0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        self.brujulaButton.frame = CGRectMake(contentRect.size.width - 80.0, 10.0, 55.0, 55.0);
        self.areaTotalLabel.frame = CGRectMake(10.0, self.planoImageView.frame.origin.y + self.planoImageView.frame.size.height + 3.0, 150.0, 20.0);
    }
}

#pragma mark - Actions 

-(void)espacio3DButtonTapped:(UIButton *)sender {
    NSLog(@"seleccioné un espacio");
    [self.delegate espacio3DButtonWasSelectedWithTag:sender.tag - 1 inCell:self];
}

-(void)brujulaButtonTapped {
    [self.delegate brujulaButtonWasTappedInCell:self];
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
    return self.planoImageView;
}

@end
