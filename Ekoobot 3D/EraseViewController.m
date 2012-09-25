//
//  EraseViewController.m
//  Ekoobot 3D
//
//  Created by Andrés Abril on 14/09/12.
//  Copyright (c) 2012 Ekoomedia. All rights reserved.
//

#import "EraseViewController.h"

@interface EraseViewController ()

@end

@implementation EraseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.title=@"Admin panel";
	// Do any additional setup after loading the view.
}
-(IBAction)erase:(id)sender{
    [ProjectDownloader eraseAllFiles];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
