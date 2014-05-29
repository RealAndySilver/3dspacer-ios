//
//  TermsAndConditionsViewController.h
//  Ekoobot 3D
//
//  Created by Diego Vidal on 23/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TermsAndConditionsDelegate <NSObject>
-(void)userDidAcceptTerms;
@end

@interface TermsAndConditionsViewController : UIViewController
@property (strong, nonatomic) NSString *termsString;
@property (assign, nonatomic) BOOL controllerWasPresentedFromDownloadButton;
@property (strong, nonatomic) id <TermsAndConditionsDelegate> delegate;
@end
