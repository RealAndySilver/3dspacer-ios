//
//  SlideControlViewController.h
//  Ekoobot 3D
//
//  Created by Andres Abril on 14/08/13.
//  Copyright (c) 2013 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    iAmTransitionTypeFade,
    iAmTransitionTypeSlide
}iAmTransitionType;

@interface SlideControlViewController : UIViewController{
    IBOutlet UIButton *playButton;
    IBOutlet UIButton *nextButton;
    IBOutlet UIButton *lastButton;
    
    IBOutlet UIButton *backButton;

    IBOutlet UISegmentedControl *transitionTypeSegmentedControl;
    IBOutlet UIStepper *animationTimeStepper;
    IBOutlet UIStepper *transitionTimeStepper;
    
    IBOutlet UILabel *transitionLabel;
    IBOutlet UILabel *animationLabel;


    int animationTime;
    int transitionTime;

}

@end
