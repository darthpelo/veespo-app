//
//  VERSSViewController.m
//  Veespo
//
//  Created by Alessio Roberto on 24/09/13.
//  Copyright (c) 2013 Veespo Ltd. All rights reserved.
//

#import "VERSSViewController.h"
#import "VERSSParser.h"
#import "RassegnaCell.h"
#import "WebViewController.h"

@interface VERSSViewController ()

@end

@implementation VERSSViewController 

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.navigationController.navigationBar.frame), 64)];
//    backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:1 alpha:.2];
//    backgroundView.opaque = NO;
//    [self.navigationController.view insertSubview:backgroundView belowSubview:self.navigationController.navigationBar];
    
    _dataSource = [[NSMutableArray alloc] init];
    CGRect appBounds = [UIScreen mainScreen].bounds;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    UILabel *newsTitleLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 300, 25)];
    newsTitleLbl.font = [UIFont fontWithName:UIFontTextStyleHeadline size:20];
    newsTitleLbl.textColor = [UIColor whiteColor];
    newsTitleLbl.textAlignment = NSTextAlignmentCenter;
    newsTitleLbl.text = @"Engadget";
    [headerView addSubview:newsTitleLbl];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -64, 320, appBounds.size.height + 64) style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setShowsVerticalScrollIndicator:YES];
    _tableView.tableHeaderView = headerView;
    [_tableView reloadData];
    
    [self.view addSubview:_tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_dataSource.count == 0) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.delegate = self;
        [HUD show:YES];
        
        rssParser = [[VERSSParser alloc] init];
        __weak VERSSViewController *wSelf = self;
        rssParser.parseResult = ^(NSMutableArray *results){
            NSLog(@"%d", results.count);
            [wSelf reloadTableView:results];
        };
        [rssParser parseXMLFileAtURL:@"http://feeds.feedburner.com/engadget"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadTableView:(NSMutableArray *)data
{
    _dataSource = data;
    NSLog(@"%d", _dataSource.count);
    [_tableView reloadData];
    [HUD hide:YES afterDelay:1];
}

#pragma mark - TableView mths

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_dataSource count];
}

// Customize the height of table view cells.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"MyIdentifier";
	
	RassegnaCell *cell = (RassegnaCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[RassegnaCell alloc] initWithFrame:CGRectZero];
	}
	
	// Set up the cell
	int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
    cell.events.text = [[_dataSource objectAtIndex: storyIndex] objectForKey: @"date"];
    cell.data.text = [[_dataSource objectAtIndex:storyIndex] objectForKey:@"title"];
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic
    
    int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
    
    NSString * storyLink = [[_dataSource objectAtIndex: storyIndex] objectForKey: @"link"];
    
    // clean up the link - get rid of spaces, returns, and tabs...
    storyLink = [storyLink stringByReplacingOccurrencesOfString:@" " withString:@""];
    storyLink = [storyLink stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    storyLink = [storyLink stringByReplacingOccurrencesOfString:@"	" withString:@""];
    
    //NSLog(@"link: %@", storyLink);
    
    WebViewController *wvc = [[WebViewController alloc] init];
    [wvc setUrl:[NSURL URLWithString:storyLink]];
    [self.navigationController pushViewController:wvc animated:YES];
    // open in Safari
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:storyLink]];
}


@end
