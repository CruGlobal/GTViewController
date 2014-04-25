//
//  SNDownloaderTableViewController.m
//  Snuffy
//
//  Created by Michael Harrison on 12/11/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//

#import "SNDownloaderTableViewController.h"
#import "SNDownloadCell.h"
#import "GTFileLoader.h"
#import "snuffyViewController.h"

#define DEFAULT_ROW_HEIGHT 45
#define HEADER_HEIGHT 45
#define HEIGHT_OF_TOOLBAR 44

@implementation SNDownloaderTableViewController

-(id)initWithParent:(id <SNDownloaderTableViewControllerParent>)parent localRepo:(SnuffyRepo *)localRepo remoteRepo:(SnuffyRepo *)remoteRepo {
	
    self = [super init];
    
	if (self) {
    
		self.parent							= parent;
		self.editMode						= NO;
		
		[self clearFiler];
		
		self.basePackages					= [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"en", nil] forKeys:[NSArray arrayWithObjects:@"en", nil]], [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"en", nil] forKeys:[NSArray arrayWithObjects:@"en", nil]], nil] forKeys:[NSArray arrayWithObjects:@"kgp", @"satisfied", nil]];
		
		[self updateTableWithLocalRepo:localRepo remoteRepo:remoteRepo];
    
	}
    
	return self;
}

-(void)filterForPackageCode:(NSString *)packageCode {
	
	self.packageFilter	= packageCode;
	
}

-(void)clearFiler {
	
	self.packageFilter	= nil;
	
}

-(BOOL)isBasePackage:(NSString *)packageID language:(NSString *)languageCode {
	
	NSDictionary *basePackage = [self.basePackages objectForKey:packageID];
	
	if (basePackage != nil) {
		
			//if there is a specific language to check within the package then do it
		if (languageCode != nil) {
			
			NSString	*baseLanguage = [basePackage objectForKey:languageCode];
			
			if (baseLanguage != nil) {
				
				return YES;
				
			} else {
				
				return NO;
				
			}
		
			//if it is a request for a package only then return yes
		} else {
			
			return YES;
			
		}
		
		
	} else {
		
		return NO;
		
	}
	
}

-(NSInteger)numberOfBaseLanguagesForPackage:(NSString *)packageID {
	
	NSDictionary *basePackage = [self.basePackages objectForKey:packageID];
	
	if (basePackage == nil) {
		
		return 0;
		
	} else {
		
		return [basePackage count];
		
	}
	
}

-(void)turnEditModeOffIfNothingToDelete {
	
	NSInteger numberOfPackagesWithZeroLanguages = 0;
	
	for (NSString *packageID in [self.remoteRepo packages]) {
		
		SNPackageMeta *package = [[self.remoteRepo packages] objectForKey:packageID];
		
		if ((package.numberOfDownloadedLanguages - [self numberOfBaseLanguagesForPackage:packageID]) > 0) {
			
			//no action
			
		} else {
			
			numberOfPackagesWithZeroLanguages++;
			
		}
		
	}
	
	if (numberOfPackagesWithZeroLanguages == [[self.remoteRepo packages] count]) {
		
		self.editMode = NO;
		
		[self.tableView reloadData];
		
	}
	
}

-(void)viewWillAppear:(BOOL)animated {
	
	self.editMode = NO;
    
    //disable interaction with snuffyviewcontroller
    //[self.parent setActiveViewMasked:YES];
	
	[self.tableView reloadData];
	
}

-(void)viewDidLoad {
	
	if (self.toolbar == nil) {
		
		//TODO:add toolbar
		//create toolbar
		self.toolbar					= [[CustomToolBar alloc] init];
		
		//set settings
		CGRect		frameOfToolbar		= CGRectMake(0, 0, self.view.frame.size.width, HEIGHT_OF_TOOLBAR);
		[self.toolbar setFrame:frameOfToolbar];
		self.toolbar.exclusiveTouch		= YES;
		
		//set toolbar background
		[self.toolbar setBackgroundWith:[UIImage  imageNamed:@"PkgDwnldScrn_Top_Bar"]];
		
		//create toolbar buttons
		UIButton	*doneButton			= [self.toolbar buttonWith:[UIImage imageNamed:@"PkgDwnldScrn_Back_Button"] highlight:nil leftCapWidth:30.0 target:self selector:@selector(askForTableViewToBeDismissed)];
		[self.toolbar setText:@"God Tools" onButton:doneButton];
		
		UIBarButtonItem *space			= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		/*
		UIButton	*editButton			= [self.toolbar buttonWith:[UIImage imageNamed:@"navigationBarBackButton"] highlight:nil leftCapWidth:14.0 target:self selector:@selector(askForTableViewToBeEdited)];
		[self.toolbar setText:@"Edit" onButton:editButton];
		*/
		//add toolbar buttons
		[self.toolbar setItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithCustomView:doneButton], space, nil]];
        
        
		//add toolbar to view
		[self.view addSubview:self.toolbar];
	
	}
	
	//Setup TableView
	CGRect		frameOfTableView	= CGRectMake(0, HEIGHT_OF_TOOLBAR, self.view.frame.size.width, self.view.frame.size.height - HEIGHT_OF_TOOLBAR);
	
	UITableView *tempTableView		= [[UITableView alloc] initWithFrame:frameOfTableView style:UITableViewStylePlain];
	self.tableView					= tempTableView;
	self.tableView.separatorColor	= [UIColor colorWithRed:(228.0/255.0) green:(229.0/255.0) blue:(231.0/255.0) alpha:1.0];
	
	
	self.tableView.delegate			= self;
	self.tableView.dataSource		= self;
	
	[self.view addSubview:self.tableView];
	
	/*
	self.title = @"Snuffy";
	self.navigationBar.backItem.title	= @"Do it!";
	
	UIBarButtonItem            *doneButton	= [[ UIBarButtonItem alloc ] initWithTitle: @"Done"
													style: UIBarButtonItemStyleDone
												   target: self
												   action: @selector(askForTableViewToBeDismissed)];
	
	UIBarButtonItem            *editButton	= [[ UIBarButtonItem alloc ] initWithTitle: @"Edit"
																				style: UIBarButtonItemStyleBordered
																			   target: self
																			   action: @selector(askForTableViewToBeEdited)];
	
	self.navigationItem.leftBarButtonItem	= doneButton;
	self.navigationItem.rightBarButtonItem	= editButton;
	[doneButton release];
	[editButton release];
	 */
	
}

-(void)didReceiveMemoryWarning {
	
	//run through all the remote packages
	for (NSString *packageId in [self.remoteRepo packages]) {
		
		SNPackageMeta *remotePackage	= [[self.remoteRepo packages] objectForKey:packageId];
		
		for (NSString *languageCode in remotePackage.languages) {
			
			SNLanguageMeta *remoteLanguage	= [remotePackage getLanguage:languageCode];
			[remoteLanguage clearIcon];
			
		}
		
	}
	
}

-(void)updateTableWithLocalRepo:(SnuffyRepo *)localRepo remoteRepo:(SnuffyRepo *)remoteRepo {
	
	SnuffyRepo	*oldRemoteRepo	= self.remoteRepo;
	
	self.localRepo	= localRepo;
	self.remoteRepo	= remoteRepo;
	
	//run through all the remote packages
	for (NSString *packageId in [self.remoteRepo packages]) {
		
		SNPackageMeta *localPackage		= [[self.localRepo packages] objectForKey:packageId];
		SNPackageMeta *remotePackage	= [[self.remoteRepo packages] objectForKey:packageId];
		SNPackageMeta *oldRemotePackage	= (oldRemoteRepo == nil ? nil : [[oldRemoteRepo packages] objectForKey:packageId]);
		
		//copy across old state
		if (oldRemotePackage != nil) {
			
			remotePackage.state				= oldRemotePackage.state;
			remotePackage.expanded			= oldRemotePackage.expanded;
			remotePackage.downloadProgress	= oldRemotePackage.downloadProgress;
			
		}
		
		
		NSInteger	downloadedCount = 0;
			
		//run through each language for the remote packages
		for (NSString *languageCode in remotePackage.languages) {
			
			SNLanguageMeta *remoteLanguage	= [remotePackage getLanguage:languageCode];
				
			//copy across old state
			if (oldRemotePackage != nil) {
					
				SNLanguageMeta *oldRemoteLanguage = [oldRemotePackage getLanguage:languageCode];
					
				if (oldRemoteLanguage != nil) {
					
					remoteLanguage.state			= oldRemoteLanguage.state;
					remoteLanguage.expanded			= oldRemoteLanguage.expanded;
					remoteLanguage.downloadProgress	= oldRemoteLanguage.downloadProgress;
					
				}
				
			}
				
				
			//if the package doesn't exist locally then all states will be left as ReadyToDownload
			if (localPackage != nil) {
				
				//if the language is in both the local and remote then set the remote to DownloadCompleted
				if ([localPackage hasLanguage:languageCode]) {
					
					remoteLanguage.state = SNDownloadStateDownloadComplete;
					downloadedCount++;
					
				}
				
			}
				
		}
		
		//record downloaded packages
		remotePackage.numberOfDownloadedLanguages = downloadedCount;
		
		//if all the languages in the package have been downloaded then set the package to DownloadComplete
		if ([[remotePackage languages] count] == downloadedCount) {
			
			remotePackage.state = SNDownloadStateDownloadComplete;
			
		}
			
	}
	
}


#pragma mark Table view data source and delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    
	if (self.packageFilter != nil) {
		
		return 1;
		
	} else {
		
		return [[self.remoteRepo packages] count];
		
	}

}


-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    
	if (self.packageFilter != nil) {
		
		return [[[[self.remoteRepo packages] objectForKey:self.packageFilter] languages] count];
		
	} else {
		
		SNPackageMeta	*packageForSection			= [[self.remoteRepo packages] objectForKey:[[[self.remoteRepo packages] allKeys] objectAtIndex:section]];
		NSInteger		numberOfLanguagesInSection	= [[packageForSection languages] count];
		
		return packageForSection.expanded ? numberOfLanguagesInSection : 0;
		
	}
	
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"cellForRowAtIndexPath:%@", indexPath);
	//grab the package and the language for this cell
	SNPackageMeta	*packageForSection			= [[self.remoteRepo packages] objectForKey:[[[self.remoteRepo packages] allKeys] objectAtIndex:indexPath.section]];
	SNLanguageMeta	*languageForRow				= [packageForSection getLanguage:[[[packageForSection languages] allKeys] objectAtIndex:indexPath.row]]; 
	NSLog(@"p: %@, l: %@", [[[self.remoteRepo packages] allKeys] objectAtIndex:indexPath.section], [[[packageForSection languages] allKeys] objectAtIndex:indexPath.row]);
	//grab the cell
    static NSString *CellIdentifier				= @"Cell";
    SNDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SNDownloadCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier delegate:self indexPath:indexPath];
    }
	
	//TODO: get this code to display the downloaded icon image
	//grab remote icon if it exists
	UIImage *icon = languageForRow.icon;
    
    
	
	//if the remote icon doesn't exist, grab local icon if it exists
	if (icon == nil) {
		
		icon = [UIImage imageWithContentsOfFile:[GTFileLoader pathOfIconFromReposIconAttribute:[languageForRow get:@"icon"]]];
		
	}
	
	//set the values in the cell
	if (self.editMode) {
		
		if (languageForRow.state == SNDownloadStateDownloadComplete && ![self isBasePackage:[packageForSection get:@"id"] language:[languageForRow get:@"language_code"]]) {
			
			[cell setIconImage:icon
						title:[languageForRow get:@"name"]
                     subtitle:@""
						state:SNDownloadStateReadyToDelete
		   downloadPercentage:languageForRow.downloadProgress
					indexPath:indexPath];
			
		} else {
			
			[cell setIconImage:icon
						title:[languageForRow get:@"name"]
					 subtitle:@""
						state:SNDownloadStateDisabled
		   downloadPercentage:languageForRow.downloadProgress
					indexPath:indexPath];
			
		}
		
	} else {
        NSLocale *currentLocale = [NSLocale currentLocale];
		
		[cell setIconImage:icon
					title:[languageForRow get:@"name"]
                 subtitle:[currentLocale displayNameForKey:NSLocaleIdentifier value:[languageForRow get:@"language_code"]]
					state:languageForRow.state
	   downloadPercentage:languageForRow.downloadProgress
				indexPath:indexPath];
		
	}
    
    NSLog(@"LanguageForRow Properties:\n%@", languageForRow.properties);
	
    return cell;
}

/*
-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    //NSLog(@"viewForHeaderInSection:%d", section);
    //grab the package for this section
	SNPackageMeta			*packageForSection		= [[self.remoteRepo packages] objectForKey:[[[self.remoteRepo packages] allKeys] objectAtIndex:section]];
	//grab the best language for this package
	NSString				*bestLanguage			= ([packageForSection hasLanguage:[self.parent language]] ? [self.parent language] : [packageForSection get:@"base_language"]);
	SNLanguageMeta			*bestLanguageForPackage	= [packageForSection getLanguage:bestLanguage];
	
	//grab remote icon if it exists
	UIImage *icon = bestLanguageForPackage.icon;
	
	//if the remote icon doesn't exist, grab local icon if it exists
	if (icon == nil) {
		
		icon = [UIImage imageWithContentsOfFile:[FileLoader pathOfIconFromReposIconAttribute:[bestLanguageForPackage get:@"icon"]]];
		
	}
	
	//create the header view
	SNDownloadHeaderView	*header;
	
	if (self.editMode) {
		
		if ((packageForSection.numberOfDownloadedLanguages - [self numberOfBaseLanguagesForPackage:[packageForSection get:@"id"]]) > 0) {
			
			header					= [[[SNDownloadHeaderView alloc] initWithIconImage:icon
																						 title:[bestLanguageForPackage get:@"name"]
																					  subtitle:@""
																				numberOnButton:(packageForSection.numberOfDownloadedLanguages - [self numberOfBaseLanguagesForPackage:[packageForSection get:@"id"]])
																   state:SNDownloadStateReadyToDelete
																expanded:packageForSection.expanded
													  downloadPercentage:packageForSection.downloadProgress
																 section:section
																delegate:self] autorelease];
			
		} else {
			
			header					= [[[SNDownloadHeaderView alloc] initWithIconImage:icon
																						 title:[bestLanguageForPackage get:@"name"]
																					  subtitle:@""
																				numberOnButton:(packageForSection.numberOfDownloadedLanguages)
																   state:SNDownloadStateDisabled
																expanded:packageForSection.expanded
													  downloadPercentage:packageForSection.downloadProgress
																 section:section
																delegate:self] autorelease];
			
		}
		
	} else {
		
		header					= [[[SNDownloadHeaderView alloc] initWithIconImage:icon
																					 title:[bestLanguageForPackage get:@"name"]
																				  subtitle:@""
																			numberOnButton:([[packageForSection languages] count] - packageForSection.numberOfDownloadedLanguages)
															   state:packageForSection.state
															expanded:packageForSection.expanded
												  downloadPercentage:packageForSection.downloadProgress
															 section:section
															delegate:self] autorelease];
		
	}
    
    return header;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return HEADER_HEIGHT;
}
*/
 //If cell hieghts differ then we can use this
-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return DEFAULT_ROW_HEIGHT;
}


-(void)buttonPushedForSection:(NSInteger)section {
	
	//grab the package and the language for this cell
	SNPackageMeta	*packageForSection			= [[self.remoteRepo packages] objectForKey:[[[self.remoteRepo packages] allKeys] objectAtIndex:section]];
	
	if (self.editMode) {
		
		switch (packageForSection.state) {
				
			case SNDownloadStateReadyToDownload:
				
				if ((packageForSection.numberOfDownloadedLanguages - [self numberOfBaseLanguagesForPackage:[packageForSection get:@"id"]]) > 0) {
					
					[self confirmDeleteForPackage:packageForSection andLanguage:nil];
					
				}
				
				break;
				
			case SNDownloadStateReadyToDelete:
				
				if ((packageForSection.numberOfDownloadedLanguages - [self numberOfBaseLanguagesForPackage:[packageForSection get:@"id"]]) > 0) {
					
					[self confirmDeleteForPackage:packageForSection andLanguage:nil];
					
				}
				
				break;
				
			case SNDownloadStateDownloading:
				
				[self cancelDownloadForPackage:packageForSection andLanguage:nil];
				
				break;
				
			case SNDownloadStateDownloadComplete:
				
				if ((packageForSection.numberOfDownloadedLanguages - [self numberOfBaseLanguagesForPackage:[packageForSection get:@"id"]]) > 0) {
					
					[self confirmDeleteForPackage:packageForSection andLanguage:nil];
					
				}
				
				break;
				
			case SNDownloadStateDownloadingError:
				
				//do nothing
				
				break;
				
			case SNDownloadStateDisabled:
				
				//no action
				
				break;
				
			default:
				
				//no action
				
				break;
		}
		
	} else {
	
		switch (packageForSection.state) {
				
			case SNDownloadStateReadyToDownload:
				
				[self startDownloadForPackage:packageForSection andLanguage:nil];
					
				break;
				
			case SNDownloadStateReadyToDelete:
				
				//do nothing
				
				break;
				
			case SNDownloadStateDownloading:
				
				[self cancelDownloadForPackage:packageForSection andLanguage:nil];
				
				break;
				
			case SNDownloadStateDownloadComplete:
				
				//[self askForSwitchToPackage:packageForSection andLanguage:nil];
				
				break;
				
			case SNDownloadStateDownloadingError:
				
				[self startDownloadForPackage:packageForSection andLanguage:nil];
				
				break;
				
			case SNDownloadStateDisabled:
				
				//no action
				
				break;
				
			default:
				
				//no action
				
				break;
		}
		
	}
	
}

-(void)buttonPushedForIndexPath:(NSIndexPath *)indexPath {
//	NSLog(@"%@", indexPath);
	//grab the package and the language for this cell
	SNPackageMeta	*packageForSection			= [[self.remoteRepo packages] objectForKey:[[[self.remoteRepo packages] allKeys] objectAtIndex:indexPath.section]];
	SNLanguageMeta	*languageForRow				= [packageForSection getLanguage:[[[packageForSection languages] allKeys] objectAtIndex:indexPath.row]];
//	NSLog(@"buttonPushedForIndexPath:%d", languageForRow.state);
	
	if (self.editMode) {
		
		switch (languageForRow.state) {
				
			case SNDownloadStateReadyToDownload:
				
				//do nothing
				
				break;
				
			case SNDownloadStateReadyToDelete:
				
				if (![self isBasePackage:[packageForSection get:@"id"] language:[languageForRow get:@"language_code"]]) {
				
					[self confirmDeleteForPackage:packageForSection andLanguage:languageForRow];
					
				}
				
				break;
				
			case SNDownloadStateDownloading:
				
				[self cancelDownloadForPackage:packageForSection andLanguage:languageForRow];
				
				break;
				
			case SNDownloadStateDownloadComplete:
				
				if (![self isBasePackage:[packageForSection get:@"id"] language:[languageForRow get:@"language_code"]]) {
					
					[self confirmDeleteForPackage:packageForSection andLanguage:languageForRow];
					
				}
				
				break;
				
			case SNDownloadStateDownloadingError:
				
				//do nothing
				
				break;
				
			case SNDownloadStateDisabled:
				
				//no action
				
				break;
				
			default:
				
				//no action
				
				break;
		}
		
	} else {
	
		switch (languageForRow.state) {
				
			case SNDownloadStateReadyToDownload:
				
				[self startDownloadForPackage:packageForSection andLanguage:languageForRow];
				
				break;
				
			case SNDownloadStateReadyToDelete:
				
				//do nothing
				
				break;
				
			case SNDownloadStateDownloading:
				
				[self cancelDownloadForPackage:packageForSection andLanguage:languageForRow];
				
				break;
				
			case SNDownloadStateDownloadComplete:
				
				[self askForSwitchToPackage:packageForSection andLanguage:languageForRow];
				
				break;
				
			case SNDownloadStateDownloadingError:
				
				[self startDownloadForPackage:packageForSection andLanguage:languageForRow];
				
				break;
				
			case SNDownloadStateDisabled:
				
				//no action
				
				break;
				
			default:
				
				//no action
				
				break;
		}
		
	}
	
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	//do action for this cell
	[self buttonPushedForIndexPath:indexPath];
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	
    if (!decelerate) {
		
        [self loadImagesForOnscreenRows];
		
    }
	
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	
    [self loadImagesForOnscreenRows];

}

-(void)loadImagesForOnscreenRows {
	
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in visiblePaths) {
		
		NSString		*packageID			= [[[self.remoteRepo packages] allKeys] objectAtIndex:indexPath.section];
		SNPackageMeta	*packageForSection	= [[self.remoteRepo packages] objectForKey:packageID];
		NSString		*languageCode		= [[[packageForSection languages] allKeys] objectAtIndex:indexPath.row];
		SNLanguageMeta	*languageForRow		= [packageForSection getLanguage:languageCode];
		
		// avoid the icon download if the language already has an icon or it doesn't need to be retrieved
		if ((languageForRow.state == SNDownloadStateReadyToDownload || languageForRow.state == SNDownloadStateDownloadingError || languageForRow.state == SNDownloadStateDownloading) && languageForRow.icon == nil) {
			
			packageForSection.delegate = self;
			[packageForSection startIconDownloadForLanguage:[languageForRow get:@"language_code"]];
		}
	}
	
}

#pragma mark -
#pragma mark SNRepoDataUpdatedDelegate methods

-(void)dataUpdated {
	
	NSLog(@"dataUpdated");
	
	[self.tableView reloadData];
	
}

-(void)dataUpdatedInPackage:(NSString *)packageID {
	
	NSLog(@"dataUpdatedInPackage:%@", packageID);
	
	//create an index set that represents the passed package id
	NSUInteger indexOfPackage = [[[self.remoteRepo packages] allKeys] indexOfObject:packageID];
	NSIndexSet *sections = [NSIndexSet indexSetWithIndex:indexOfPackage];
	
	[self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
	
}

-(void)downloadCompleteInPackage:(NSString *)packageID {
	
	NSLog(@"dataUpdatedInPackage:%@", packageID);
	
	//create an index set that represents the passed package id
	NSUInteger indexOfPackage = [[[self.remoteRepo packages] allKeys] indexOfObject:packageID];
	NSIndexSet *sections = [NSIndexSet indexSetWithIndex:indexOfPackage];
	
	[self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
	
}

-(void)dataUpdatedInLanguage:(NSString *)languageCode forPackage:(NSString *)packageID {
	
	NSLog(@"dataUpdatedInLanguage:%@ forPackage:%@", languageCode, packageID);
	
	//find the index that represents the passed package id
	NSInteger indexOfPackage	= [[[self.remoteRepo packages] allKeys] indexOfObject:packageID];
	//find the row of the passed language code
	NSInteger rowOfLanguage		= [[[[[self.remoteRepo packages] objectForKey:packageID] languages] allKeys] indexOfObject:languageCode];
	//create the indexPath for the passed language and package
	NSIndexPath	*indexPath		= [NSIndexPath indexPathForRow:rowOfLanguage inSection:indexOfPackage];
	//create an array containing the indexPath
	NSArray *indexPaths			= [NSArray arrayWithObject:indexPath];
	
	[self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
	
}

-(void)downloadCompleteInLanguage:(NSString *)languageCode forPackage:(NSString *)packageID {
	
	NSLog(@"downloadCompleteInLanguage:%@ forPackage:%@", languageCode, packageID);
	
	//find the index that represents the passed package id
	NSInteger indexOfPackage	= [[[self.remoteRepo packages] allKeys] indexOfObject:packageID];
	//create the index set that represents the passed package id
	NSIndexSet *sections = [NSIndexSet indexSetWithIndex:indexOfPackage];
	
	SNPackageMeta *package		= [[self.remoteRepo packages] objectForKey:packageID];
	[package incrementNumberOfDownloadedLanguages];
	
	[self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
	
}

-(void)iconDownloadCompleteInLanguage:(NSString *)languageCode forPackage:(NSString *)packageID {
	
	NSLog(@"iconDownloadCompleteInLanguage:%@ forPackage:%@", languageCode, packageID);
	
	//find the index that represents the passed package id
	NSInteger indexOfPackage	= [[[self.remoteRepo packages] allKeys] indexOfObject:packageID];
	//find the row of the passed language code
	NSInteger rowOfLanguage		= [[[[[self.remoteRepo packages] objectForKey:packageID] languages] allKeys] indexOfObject:languageCode];
	//create the indexPath for the passed language and package
	NSIndexPath	*indexPath		= [NSIndexPath indexPathForRow:rowOfLanguage inSection:indexOfPackage];
	//create an array containing the indexPath
	NSArray *indexPaths			= [NSArray arrayWithObject:indexPath];
	
	[self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
	
}

#pragma mark -
#pragma mark Download methods

-(void)startDownloadForPackage:(SNPackageMeta *)package andLanguage:(SNLanguageMeta *)language {
	NSLog(@"startDownloadForPackage:%@ andLanguage:%@", [package get:@"id"], [language get:@"language_code"]);
	if (language == nil) {
		
		package.delegate	= self;
		[package startDownload];
		
	} else {
		
		package.delegate	= self;
		[package startDownloadLanguage:[language get:@"language_code"]];
		
	}
	
}

-(void)cancelDownloadForPackage:(SNPackageMeta *)package andLanguage:(SNLanguageMeta *)language {
	NSLog(@"cancelDownloadForPackage:%@ andLanguage:%@", [package get:@"id"], [language get:@"language_code"]);
	if (language == nil) {
		
		[package cancelDownload];
		
	} else {
		
		package.delegate	= self;
		[package cancelDownloadLanguage:[language get:@"language_code"]];
		
	}
	
}


-(void)askForSwitchToPackage:(SNPackageMeta *)package andLanguage:(SNLanguageMeta *)language {
	NSLog(@"askForSwitchToPackage:%@ andLanguage:%@", [package get:@"id"], [language get:@"language_code"]);
	if ([self.parent respondsToSelector:@selector(switchTo:language:)]) {
		
		[self askForTableViewToBeDismissed];
		[self.parent switchTo:[package get:@"id"] language:[language get:@"language_code"]];
		
	}
	
}

-(void)askForTableViewToBeDismissed {
    //re-enable snuffyviewcontroller interaction
	//[self.parent setActiveViewMasked:NO];
    
	//[self.view removeFromSuperview];
	
	[self.navigationController popViewControllerAnimated:YES];
	
}

-(void)askForTableViewToBeEdited {
	if (self.editMode) {
		self.editMode = NO;
	} else {
		self.editMode = YES;
	}
	
	[self.tableView reloadData];
	
}


#pragma mark -
#pragma mark Delete delegate

-(void)confirmDeleteForPackage:(SNPackageMeta *)package andLanguage:(SNLanguageMeta *)language {
	
	// open a dialog with two custom buttons
	UIActionSheet *actionSheet		= [[UIActionSheet alloc] initWithTitle:@"Do You Want To Delete This Resource?"
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:@"Delete"
													otherButtonTitles:nil];
	actionSheet.actionSheetStyle	= UIActionSheetStyleDefault;
	
	self.deleteActionSheetPackage	= package;
	self.deleteActionSheetLanguage	= language;
	
	[actionSheet showInView:self.view];
}

-(void)confirmCancelForPackage:(SNPackageMeta *)package andLanguage:(SNLanguageMeta *)language {
	
	// open a dialog with two custom buttons
	UIActionSheet *actionSheet		= [[UIActionSheet alloc] initWithTitle:@"Do You Want To Stop This Download?"
															  delegate:self
													 cancelButtonTitle:@"Cancel"
												destructiveButtonTitle:@"Stop"
													 otherButtonTitles:nil];
	
	actionSheet.actionSheetStyle	= UIActionSheetStyleDefault;
	
	self.cancelActionSheetPackage	= package;
	self.cancelActionSheetLanguage	= language;
	
	[actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		
		if ([[actionSheet title] rangeOfString:@"Delete"].location != NSNotFound) {
			
			NSString *packageID		= ( self.deleteActionSheetPackage != nil ? [self.deleteActionSheetPackage get:@"id"] : nil );
			NSString *languageCode	= ( self.deleteActionSheetLanguage != nil ? [self.deleteActionSheetLanguage get:@"language_code"] : nil );
			
			//let the parent know that your about to delete something incase it needs make some changed to deal with that
			if ([self.parent respondsToSelector:@selector(downloaderTableViewController:willDeletePackage:language:)]) {
				
				[self.parent downloaderTableViewController:self willDeletePackage:packageID language:languageCode];
				
			}
		
			if (self.deleteActionSheetLanguage == nil) {
				
				//delete package
				SNPackageMeta *localPackage = [[self.localRepo packages] objectForKey:packageID];
				localPackage.delegate		= self;
				[localPackage deleteFromDisk:[self.basePackages objectForKey:packageID]];
				
				//update packages data
				self.deleteActionSheetPackage.state							= SNDownloadStateReadyToDownload;
				self.deleteActionSheetPackage.downloadProgress				= 0.0;
				
				for (NSString *languageCode in [self.deleteActionSheetPackage languages]) {
					
					if (![self isBasePackage:packageID language:languageCode]) {
						
						SNLanguageMeta	*language	= [self.deleteActionSheetPackage getLanguage:languageCode];
						language.state				= SNDownloadStateReadyToDownload;
						language.downloadProgress	= 0.0;
						
						[self.deleteActionSheetPackage decrementNumberOfDownloadedLanguages];
						
					}
					
				}
				
				//create an index set that represents the passed package id
				NSUInteger indexOfPackage = [[[self.remoteRepo packages] allKeys] indexOfObject:packageID];
				NSIndexSet *sections = [NSIndexSet indexSetWithIndex:indexOfPackage];
				
				[self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
				
			} else {
				
				//delete language
				SNPackageMeta *localPackage = [[self.localRepo packages] objectForKey:[self.deleteActionSheetPackage get:@"id"]];
				localPackage.delegate		= self;
				[localPackage deleteLanguageFromDisk:[self.deleteActionSheetLanguage get:@"language_code"]];
				[localPackage removeLanguage:[self.deleteActionSheetLanguage get:@"language_code"]];
				
				//update language data
				self.deleteActionSheetLanguage.state			= SNDownloadStateReadyToDownload;
				self.deleteActionSheetLanguage.downloadProgress = 0.0;
				[self.deleteActionSheetPackage decrementNumberOfDownloadedLanguages];
				
				//find the index that represents the passed package id
				NSInteger indexOfPackage	= [[[self.remoteRepo packages] allKeys] indexOfObject:packageID];
				//create the index set that represents the passed package id
				NSIndexSet *sections = [NSIndexSet indexSetWithIndex:indexOfPackage];
				
				[self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
				
			}
			
			[self turnEditModeOffIfNothingToDelete];
			
			//let the parent know that we just deleted something incase it needs make some changed to deal with that
			if ([self.parent respondsToSelector:@selector(downloaderTableViewController:didDeletePackage:language:)]) {
				
				[self.parent downloaderTableViewController:self didDeletePackage:[self.deleteActionSheetPackage get:@"id"] language:[self.deleteActionSheetLanguage get:@"language_code"]];
				
			}
			
		} else {
			
			[self cancelDownloadForPackage:self.cancelActionSheetPackage andLanguage:self.cancelActionSheetLanguage];
			
		}
		
		[self.tableView reloadData];
		
	}
	
}


#pragma mark -
#pragma mark Section header delegate

-(void)sectionHeaderView:(SNDownloadHeaderView *)sectionHeaderView sectionOpened:(NSInteger)sectionOpened {
	
	//grab the package for this section
	SNPackageMeta			*packageForSection		= [[self.remoteRepo packages] objectForKey:[[[self.remoteRepo packages] allKeys] objectAtIndex:sectionOpened]];
	//store the fact that this section is open
	packageForSection.expanded = YES;
	sectionHeaderView.expanded = YES;
    
	//Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
    NSInteger countOfRowsToInsert = [[packageForSection languages] count];
    NSMutableArray *indexPathsToInsert = [NSMutableArray array];
	
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
		
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
		
    }
    
    // Apply the updates.
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    
    //fetch the icons for the visible cells
    [self loadImagesForOnscreenRows];
}


-(void)sectionHeaderView:(SNDownloadHeaderView *)sectionHeaderView sectionClosed:(NSInteger)sectionClosed {
	
	//grab the package for this section
	SNPackageMeta			*packageForSection		= [[self.remoteRepo packages] objectForKey:[[[self.remoteRepo packages] allKeys] objectAtIndex:sectionClosed]];
	//store the fact that this section is closed
	packageForSection.expanded = NO;
	sectionHeaderView.expanded = NO;
	
    //Create an array of the index paths of the rows in the section that was closed, then delete those rows from the table view.
    NSInteger countOfRowsToDelete = [[packageForSection languages] count];
	
    if (countOfRowsToDelete > 0) {
		
        NSMutableArray *indexPathsToDelete = [NSMutableArray array];
		
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
			
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:sectionClosed]];
			
        }
		
        [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
		
    }
	
}


#pragma mark -
#pragma mark Table view delegate
/* TODO: change swipe to delete to an edit button
//enable swipe to delete
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//grab the package and the language for this cell
	SNPackageMeta	*packageForSection			= [[self.remoteRepo packages] objectForKey:[[[self.remoteRepo packages] allKeys] objectAtIndex:indexPath.section]];
	SNLanguageMeta	*languageForRow				= [packageForSection getLanguage:[[[packageForSection languages] allKeys] objectAtIndex:indexPath.row]];
	
	if (languageForRow.state == SNDownloadStateDownloadComplete) {
		
		return YES;
		
	} else {
		
		return NO;
		
	}
	
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//the delete button has been hit (which is revealed on swipe)
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
		//grab the package and the language for this cell
		SNPackageMeta	*packageForSection			= [[self.remoteRepo packages] objectForKey:[[[self.remoteRepo packages] allKeys] objectAtIndex:indexPath.section]];
		SNLanguageMeta	*languageForRow				= [packageForSection getLanguage:[[[packageForSection languages] allKeys] objectAtIndex:indexPath.row]];
		
		//ask for the parent to delete it
		[self confirmDeleteForPackage:packageForSection andLanguage:languageForRow];
		
    }
	
}
*/
 

@end
