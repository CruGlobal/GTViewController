//
//  GTExampleViewController.m
//  GTViewController
//
//  Created by Michael Harrison on 5/1/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTExampleViewController.h"

#import "GTViewController.h"

@interface GTExampleViewController () <GTViewControllerMenuDelegate>

@property (nonatomic, strong) GTViewController *godtoolsViewController;

@end

@implementation GTExampleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
	[self pushViewController:self.godtoolsViewController animated:NO];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (GTViewController *)godtoolsViewController {
	
	if (!_godtoolsViewController) {
		
		[self willChangeValueForKey:@"godtoolsViewController"];
		_godtoolsViewController	= [[GTViewController alloc] initWithPackageCode:@"fourlaws" languageCode:@"en" versionNumber:@1 delegate:self];
		[self didChangeValueForKey:@"godtoolsViewController"];
		
	}
	
	return _godtoolsViewController;
}


@end
