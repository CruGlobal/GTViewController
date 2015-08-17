//
//  GTExampleTableViewController.m
//  GTViewController
//
//  Created by Michael Harrison on 5/1/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTExampleTableViewController.h"

#import "GTViewController.h"
#import "GTFileLoaderExample.h"
#import "GTShareViewController.h"
#import "GTPageMenuViewController.h"
#import "GTAboutViewController.h"

NSString *const GTExampleTableViewControllerCellReuseIdentifier			= @"org.cru.godtools.gtviewcontroller.example.gtexampletableviewcontroller.cell.reuseIdentifier";
NSString *const GTExampleTableViewControllerResourcesKeyResourceName	= @"org.cru.godtools.gtviewcontroller.example.gtexampletableviewcontroller.resources.keys.resourceName";
NSString *const GTExampleTableViewControllerResourcesKeyConfigFile	= @"org.cru.godtools.gtviewcontroller.example.gtexampletableviewcontroller.resources.keys.configFile";

@interface GTExampleTableViewController () <GTViewControllerMenuDelegate, GTAboutViewControllerDelegate>

@property (nonatomic, strong) NSArray *resources;
@property (nonatomic, strong) GTViewController *godtoolsViewController;

@end

@implementation GTExampleTableViewController

- (void)awakeFromNib {
	
	[super awakeFromNib];
	
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:GTExampleTableViewControllerCellReuseIdentifier];
	
	self.resources = @[
					   @{
						   GTExampleTableViewControllerResourcesKeyResourceName	: @"The Four Spiritual Laws",
						   GTExampleTableViewControllerResourcesKeyConfigFile	: @"en.xml"
						 }
					   ];
	
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (GTViewController *)godtoolsViewController {
	
	if (!_godtoolsViewController) {
		
		NSString *configFile	= self.resources[0][GTExampleTableViewControllerResourcesKeyConfigFile];
		GTFileLoader *fileLoader = [GTFileLoaderExample fileLoader];
		fileLoader.language		= @"en";
		GTShareViewController *shareViewController = [GTShareViewController shareController];
		GTPageMenuViewController *pageMenuViewController = [[GTPageMenuViewController alloc] initWithFileLoader:fileLoader];
		GTAboutViewController *aboutViewController = [[GTAboutViewController alloc] initWithDelegate:self fileLoader:fileLoader];
		
		[self willChangeValueForKey:@"godtoolsViewController"];
		_godtoolsViewController	= [[GTViewController alloc] initWithConfigFile:configFile
																	fileLoader:fileLoader
														   shareViewController:shareViewController
														pageMenuViewController:pageMenuViewController
														   aboutViewController:aboutViewController
																	  delegate:self];
		[self didChangeValueForKey:@"godtoolsViewController"];
		
	}
	
	return _godtoolsViewController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.resources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GTExampleTableViewControllerCellReuseIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text	= self.resources[indexPath.row][GTExampleTableViewControllerResourcesKeyResourceName];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSString *configFile	= self.resources[0][GTExampleTableViewControllerResourcesKeyConfigFile];
	
	[self.godtoolsViewController loadResourceWithConfigFilename:configFile];
	
	[self.navigationController pushViewController:self.godtoolsViewController animated:YES];
	
}

#pragma mark - GTAboutViewControllerDelegate

- (UIView *)viewOfPageViewController {
	
	return _godtoolsViewController.view;
}

@end
