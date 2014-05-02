//
//  GTExampleTableViewController.m
//  GTViewController
//
//  Created by Michael Harrison on 5/1/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTExampleTableViewController.h"

#import "GTViewController.h"

NSString *const GTExampleTableViewControllerCellReuseIdentifier			= @"org.cru.godtools.gtviewcontroller.example.gtexampletableviewcontroller.cell.reuseIdentifier";
NSString *const GTExampleTableViewControllerResourcesKeyResourceName	= @"org.cru.godtools.gtviewcontroller.example.gtexampletableviewcontroller.resources.keys.resourceName";
NSString *const GTExampleTableViewControllerResourcesKeyLanguageCode	= @"org.cru.godtools.gtviewcontroller.example.gtexampletableviewcontroller.resources.keys.languageCode";
NSString *const GTExampleTableViewControllerResourcesKeyPackageCode		= @"org.cru.godtools.gtviewcontroller.example.gtexampletableviewcontroller.resources.keys.packageCode";
NSString *const GTExampleTableViewControllerResourcesKeyVersionNumber	= @"org.cru.godtools.gtviewcontroller.example.gtexampletableviewcontroller.resources.keys.versionNumber";

@interface GTExampleTableViewController () <GTViewControllerMenuDelegate>

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
						   GTExampleTableViewControllerResourcesKeyLanguageCode	: @"en",
						   GTExampleTableViewControllerResourcesKeyPackageCode	: @"fourlaws",
						   GTExampleTableViewControllerResourcesKeyVersionNumber: @1
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
		
		NSString *package	= self.resources[0][GTExampleTableViewControllerResourcesKeyPackageCode];
		NSString *language	= self.resources[0][GTExampleTableViewControllerResourcesKeyLanguageCode];
		NSNumber *version	= self.resources[0][GTExampleTableViewControllerResourcesKeyVersionNumber];
		
		[self willChangeValueForKey:@"godtoolsViewController"];
		_godtoolsViewController	= [[GTViewController alloc] initWithPackageCode:package languageCode:language versionNumber:version delegate:self];
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
	
	NSString *package	= self.resources[indexPath.row][GTExampleTableViewControllerResourcesKeyPackageCode];
	NSString *language	= self.resources[indexPath.row][GTExampleTableViewControllerResourcesKeyLanguageCode];
	NSNumber *version	= self.resources[indexPath.row][GTExampleTableViewControllerResourcesKeyVersionNumber];
	
	[self.godtoolsViewController loadResourceWithPackageCode:package
												languageCode:language
											   versionNumber:version];
	
	[self.navigationController pushViewController:self.godtoolsViewController animated:YES];
	
}

@end
