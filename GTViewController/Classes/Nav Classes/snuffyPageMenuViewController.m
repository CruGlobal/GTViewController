//
//  snuffyPageMenuViewController.m
//  godtools-translation-viewer
//
//  Created by Michael Harrison on 3/11/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "snuffyPageMenuViewController.h"

#import "GTFileLoader.h"

NSString * const GTTPageMenuViewControllerSwitchPage	= @"com.godtoolsapp.sunffyPageMenuViewController.key.pageNumber";
NSString * const GTTPageMenuViewControllerPageNumber	= @"com.godtoolsapp.sunffyPageMenuViewController.notification.switchPage";

extern NSInteger  const kPageArray_File;
extern NSInteger  const kPageArray_Thumb;
extern NSInteger  const kPageArray_Desc;

@interface snuffyPageMenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

- (IBAction)cancel:(id)sender;

@end

@implementation snuffyPageMenuViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	if (self) {
		
		[self addObserver:self forKeyPath:@"pageArray" options:NSKeyValueObservingOptionNew context:nil];
		
	}
	
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	
	if ([keyPath isEqualToString:@"pageArray"]) {
		
		[self.tableView reloadData];
		
	}
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSInteger numOfRows;
	
	numOfRows = [[self.pageArray objectAtIndex:kPageArray_Desc] count];
	
    return numOfRows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

	cell.selectionStyle			= UITableViewCellSelectionStyleGray;
	cell.textLabel.textColor	= [UIColor blackColor];
	cell.textLabel.font			= ( [self.language isEqualToString:@"am-ET"] ? [UIFont fontWithName:@"NotoSansEthiopic" size:14.0] : [UIFont fontWithName:@"Helvetica-Bold" size:14.0] );
	cell.imageView.image		= [[GTFileLoader fileLoaderWithPackage:self.package language:self.language] imageWithFilename:self.pageArray[kPageArray_Thumb][indexPath.row]];
	cell.textLabel.text			= self.pageArray[kPageArray_Desc][indexPath.row]; //grab display text
	
	//set alternating background color
	if ((indexPath.row % 2) == 0) {
		
		cell.contentView.backgroundColor	= [UIColor colorWithRed:(244.0/255.0) green:(244.0/255.0) blue:(244.0/255.0) alpha:1.0];
		
	} else {
		
		cell.contentView.backgroundColor	= [UIColor colorWithRed:(250.0/255.0) green:(250.0/255.0) blue:(250.0/255.0) alpha:1.0];
		
	}
	   
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//clear menu
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:GTTPageMenuViewControllerSwitchPage object:self userInfo:@{GTTPageMenuViewControllerPageNumber: @(indexPath.row)}];
	
	[self dismissViewControllerAnimated:YES completion:nil];
	
}

- (IBAction)cancel:(id)sender {
	
	[self dismissViewControllerAnimated:YES completion:nil];
	
}

@end
