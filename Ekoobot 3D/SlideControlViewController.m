//
//  SlideControlViewController.m
//  Ekoobot 3D
//
//  Created by Andres Abril on 14/08/13.
//  Copyright (c) 2013 Ekoomedia. All rights reserved.
//

#import "SlideControlViewController.h"

@interface SlideControlViewController ()

@end

@implementation SlideControlViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    transitionTime=transitionTimeStepper.value;
    animationTime=animationTimeStepper.value;
    transitionLabel.text=[NSString stringWithFormat:@"%i segundos",transitionTime];
    animationLabel.text=[NSString stringWithFormat:@"%i segundos",animationTime];
    self.view.backgroundColor=[UIColor blackColor];
    [self performSelector:@selector(playButtonPressed:) withObject:playButton afterDelay:0.5];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
-(IBAction)transitionStepperPressed:(UIStepper*)stepper{
    transitionTime=stepper.value;
    transitionLabel.text=[NSString stringWithFormat:@"%i segundos",transitionTime];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setTransition" object:stepper];
}
-(IBAction)animationStepperPressed:(UIStepper*)stepper{
    animationTime=stepper.value;
    animationLabel.text=[NSString stringWithFormat:@"%i segundos",animationTime];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setAnimation" object:stepper];
}
-(IBAction)segmentedControlChanged:(UISegmentedControl*)segmentedControl{
    if (segmentedControl.selectedSegmentIndex==iAmTransitionTypeFade) {
    }
    else{
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"transitionType" object:segmentedControl];
}
-(IBAction)playButtonPressed:(UIButton*)button{
    if ([button.titleLabel.text isEqualToString:@"Play"]) {
        [button setTitle:@"Stop" forState:UIControlStateNormal];
        [lastButton setUserInteractionEnabled:NO];
        [nextButton setUserInteractionEnabled:NO];
        lastButton.alpha=0.5;
        nextButton.alpha=0.5;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"play" object:nil];
    }
    else{
        [button setTitle:@"Play" forState:UIControlStateNormal];
        [lastButton setUserInteractionEnabled:YES];
        [nextButton setUserInteractionEnabled:YES];
        lastButton.alpha=1;
        nextButton.alpha=1;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"stop" object:nil];
    }
}
-(IBAction)nextButtonPressed:(UIButton*)button{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"next" object:nil];
}
-(IBAction)previousButtonPressed:(UIButton*)button{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"previous" object:nil];
}
-(IBAction)back:(UIButton*)button{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"back" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
