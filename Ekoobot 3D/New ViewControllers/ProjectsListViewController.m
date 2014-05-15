//
//  ProjectsListViewController.m
//  Ekoobot 3D
//
//  Created by Developer on 13/05/14.
//  Copyright (c) 2014 Ekoomedia. All rights reserved.
//

#import "ProjectsListViewController.h"

@interface ProjectsListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *projectsTableView;
@property (strong, nonatomic) UITableView *numbersTableView;
@end

@implementation ProjectsListViewController {
    CGRect screenBounds;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    CGRect screen = [UIScreen mainScreen].bounds;
    screenBounds = CGRectMake(0.0, 0.0, screen.size.height, screen.size.width);
    [self setupUI];
}

-(void)setupUI {
    CGRect screenRect = screenBounds;
    self.automaticallyAdjustsScrollViewInsets = NO;
    //Background ImageView
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:screenRect];
    backgroundImageView.image = [UIImage imageNamed:@"CarouselBackground.png"];
    backgroundImageView.clipsToBounds = YES;
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:backgroundImageView];
    
    //Screen title
    UILabel *mainTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0, screenRect.size.height/10.97, screenRect.size.width, screenRect.size.height/15.36)];
    mainTitle.text = @"Listado de Proyectos";
    mainTitle.textColor = [UIColor whiteColor];
    mainTitle.textAlignment = NSTextAlignmentCenter;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        mainTitle.font = [UIFont boldSystemFontOfSize:30.0];
    } else {
        mainTitle.font = [UIFont boldSystemFontOfSize:17.0];
    }
    mainTitle.layer.shadowColor = [UIColor blackColor].CGColor;
    mainTitle.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    mainTitle.layer.shadowOpacity = 0.6;
    mainTitle.layer.shadowRadius = 1.0;
    [self.view addSubview:mainTitle];
    
    //Table view shadow view
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(screenRect.size.width/6.82, screenRect.size.width/6.82, screenRect.size.width - screenRect.size.width/6.82, screenRect.size.height - screenRect.size.height/2.56)];
    shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(4.0, 4.0);
    shadowView.layer.shadowOpacity = 0.6;
    shadowView.layer.shadowRadius = 4.0;
    [self.view addSubview:shadowView];
    
    //Projects Table View
    self.projectsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, shadowView.frame.size.width, shadowView.frame.size.height) style:UITableViewStylePlain];
    self.projectsTableView.delegate = self;
    self.projectsTableView.dataSource = self;
    self.projectsTableView.showsVerticalScrollIndicator = NO;
    self.projectsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.projectsTableView.separatorColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    self.projectsTableView.tag = 2;
    [shadowView addSubview:self.projectsTableView];
    
    //Numbers table view shadow view
    UIView *shadowView2 = [[UIView alloc] initWithFrame:CGRectMake(shadowView.frame.origin.x - 50.0, shadowView.frame.origin.y - 50.0, 50.0, shadowView.frame.size.height + 100.0)];
    shadowView2.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowView2.layer.shadowOffset = CGSizeMake(4.0, 4.0);
    shadowView2.layer.shadowOpacity = 0.6;
    shadowView2.layer.shadowRadius = 4.0;
    [self.view addSubview:shadowView2];
    
    //Up Button
    UIButton *upButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, shadowView2.frame.size.width, shadowView2.frame.size.width)];
    [upButton setTitle:@"▲" forState:UIControlStateNormal];
    upButton.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    [upButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [upButton addTarget:self action:@selector(goUpInProjectList) forControlEvents:UIControlEventTouchUpInside];
    [shadowView2 addSubview:upButton];
    
    //Down button
    UIButton *downButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, shadowView2.frame.size.height - 50.0, shadowView2.frame.size.width, shadowView2.frame.size.width)];
    [downButton setTitle:@"▼" forState:UIControlStateNormal];
    [downButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    downButton.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    [downButton addTarget:self action:@selector(goDownInProjectList) forControlEvents:UIControlEventTouchUpInside];
    [shadowView2 addSubview:downButton];
    
    //Numbers Table view
    self.numbersTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 50.0, shadowView2.frame.size.width, shadowView2.frame.size.height - 100.0) style:UITableViewStylePlain];
    self.numbersTableView.delegate = self;
    self.numbersTableView.dataSource = self;
    self.numbersTableView.showsVerticalScrollIndicator = NO;
    self.numbersTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.numbersTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.numbersTableView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.numbersTableView.tag = 1;
    [shadowView2 addSubview:self.numbersTableView];
    
    [self.view bringSubviewToFront:shadowView];
    
    //Add button
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(screenRect.size.width/2.0 - 24.0- 15.0 - 48.0, screenRect.size.height - 80.0, 48.0, 48.0)];
    [addButton setBackgroundImage:[UIImage imageNamed:@"Add.png"] forState:UIControlStateNormal];
    [self.view addSubview:addButton];
    
    //Download Button
    UIButton *downloadButton = [[UIButton alloc] initWithFrame:CGRectMake(screenRect.size.width/2.0 - 24.0, screenRect.size.height - 80.0, 48.0, 48.0)];
    [downloadButton setBackgroundImage:[UIImage imageNamed:@"Download.png"] forState:UIControlStateNormal];
    [self.view addSubview:downloadButton];
    
    //Delete button
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(screenRect.size.width/2.0 + 24.0 + 15.0, screenRect.size.height - 80.0, 48.0, 48.0)];
    [deleteButton setBackgroundImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
    [self.view addSubview:deleteButton];
    
    //Exit Button
    UIButton *exitButton = [[UIButton alloc] init];
    CGRect buttonFrame;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        buttonFrame = CGRectMake(800.0, 80.0, 100.0, 30.0);
    } else {
        buttonFrame = CGRectMake(450.0, 20.0, 60.0, 30.0);
    }
    exitButton.frame = buttonFrame;
    [exitButton setTitle:@"Salir" forState:UIControlStateNormal];
    [exitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [exitButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exitButton];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
        }
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];
        return cell;
        
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
        }
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.text = @"Proyecto asfsdf er rhtryjtjt aw edfaweferge";
        return cell;
    }
}

#pragma mark - TableViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    /*if (scrollView.tag == 1) {
        CGPoint offset = self.numbersTableView.contentOffset;
        [self.projectsTableView setContentOffset:CGPointMake(0.0, offset.y) animated:NO];
    } else if (scrollView.tag == 2) {
        //CGPoint offset = self.projectsTableView.contentOffset;
        //[self.numbersTableView setContentOffset:CGPointMake(0.0, offset.y - 50.0) animated:NO];
    }*/
}

#pragma mark - Actions

-(void)dismissVC {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)goUpInProjectList {
    if (self.projectsTableView.contentOffset.y > 0) {
        [self.projectsTableView setContentOffset:CGPointMake(0.0, self.projectsTableView.contentOffset.y - 44.0) animated:YES];
        [self.numbersTableView setContentOffset:CGPointMake(0.0, self.numbersTableView.contentOffset.y - 44.0) animated:YES];
    }
}

-(void)goDownInProjectList {
    if (self.projectsTableView.contentOffset.y + 44.0 < self.projectsTableView.frame.size.height) {
        [self.projectsTableView setContentOffset:CGPointMake(0.0, self.projectsTableView.contentOffset.y + 44.0) animated:YES];
        [self.numbersTableView setContentOffset:CGPointMake(0.0, self.numbersTableView.contentOffset.y + 44.0) animated:YES];
    }
    NSLog(@"content offset = %f", self.projectsTableView.contentOffset.y);
    NSLog(@"frame = %f", self.projectsTableView.frame.size.height);
}

@end
