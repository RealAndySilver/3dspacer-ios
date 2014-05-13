//
//  PisoCollectionViewCell.m
//  Ekoobot 3D
//
//  Created by Developer on 9/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "PisoCollectionViewCell.h"
#import "Producto.h"

@interface PisoCollectionViewCell() <UIScrollViewDelegate>
@property (strong, nonatomic) UIButton *brujulaButton;
@property (strong, nonatomic) UIScrollView *scrollView;
@end

@implementation PisoCollectionViewCell

-(void)removeAllPinsFromArray:(NSArray *)pinsArray {
    for (int i = 0; i < 10; i++) {
        if ([self.contentView viewWithTag:i + 1]) {
            //Remove the pin button and it's label
            [[self.pisoImageView viewWithTag:i + 1] removeFromSuperview];
            [[self.pisoImageView viewWithTag:i + 10] removeFromSuperview];
        }
    }
}

-(void)setPinsButtonsFromArray:(NSArray *)pinsArray {
    for (int i = 0; i < [pinsArray count]; i++) {
        if (![self.contentView viewWithTag:i + 1]) {
            Producto *product = pinsArray[i];
            
            //Pin Button
            UIButton *pinButton = [[UIButton alloc] initWithFrame:CGRectMake([product.coordenadaX floatValue], [product.coordenadaY floatValue] - 30.0, 30.0, 30.0)];
            pinButton.tag = i + 1;
            [pinButton setImage:[UIImage imageNamed:@"pin.png"] forState:UIControlStateNormal];
            [pinButton addTarget:self action:@selector(pinButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.pisoImageView addSubview:pinButton];
            
            //Button Label
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(pinButton.frame.origin.x + pinButton.frame.size.width, pinButton.frame.origin.y, 100.0, 30.0)];
            nameLabel.text = product.nombre;
            nameLabel.tag = i + 10;
            nameLabel.textColor = [UIColor darkGrayColor];
            nameLabel.font = [UIFont boldSystemFontOfSize:14.0];
            [self.pisoImageView addSubview:nameLabel];
        }
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //ScrollView
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.minimumZoomScale = 1.0;
        self.scrollView.maximumZoomScale = 2.0;
        self.scrollView.delegate = self;
        self.scrollView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.scrollView];
        
        //Piso ImageView
        self.pisoImageView = [[UIImageView alloc] init];
        self.pisoImageView.clipsToBounds = YES;
        self.pisoImageView.userInteractionEnabled = YES;
        self.pisoImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.scrollView addSubview:self.pisoImageView];
        
        //Brujula button
        self.brujulaButton = [[UIButton alloc] init];
        [self.brujulaButton setBackgroundImage:[UIImage imageNamed:@"compassOn.png"] forState:UIControlStateNormal];
        [self.brujulaButton addTarget:self action:@selector(brujulaButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.pisoImageView addSubview:self.brujulaButton];
        
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
    self.scrollView.frame = CGRectMake(10.0, 10.0, contentRect.size.width - 20.0, contentRect.size.height - 20.0);
    self.pisoImageView.frame = CGRectMake(0.0, 0.0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.brujulaButton.frame = CGRectMake(self.pisoImageView.frame.size.width - 100.0, 10.0, 80.0, 80.0);
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
