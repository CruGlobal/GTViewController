//
//  SNDownloaderTableViewController.h
//  Snuffy
//
//  Created by Michael Harrison on 12/11/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNDownloadHeaderView.h"
#import "SNDownloadCell.h"
#import "SnuffyRepo.h"
#import "SNPackageMeta.h"
#import "SNLanguageMeta.h"
#import "CustomToolBar.h"

@protocol SNDownloaderTableViewControllerParent;

@interface SNDownloaderTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SNDownloadHeaderViewDelegate, SNDownloadCellDelegate, UIActionSheetDelegate, SNRepoDataUpdatedDelegate>

@property (nonatomic, strong) NSDictionary	*basePackages;

@property (nonatomic, strong) NSString		*packageFilter;

@property (nonatomic, strong) SnuffyRepo	*localRepo;
@property (nonatomic, strong) SnuffyRepo	*remoteRepo;
@property (nonatomic, weak)	id <SNDownloaderTableViewControllerParent>	parent;
@property (nonatomic, strong) SNPackageMeta	*deleteActionSheetPackage;
@property (nonatomic, strong) SNLanguageMeta*deleteActionSheetLanguage;
@property (nonatomic, strong) SNPackageMeta	*cancelActionSheetPackage;
@property (nonatomic, strong) SNLanguageMeta*cancelActionSheetLanguage;

@property (nonatomic, strong) UITableView	*tableView;
@property (nonatomic, strong) CustomToolBar *toolbar;

@property (nonatomic, assign) BOOL			editMode;

-(id)initWithParent:(id <SNDownloaderTableViewControllerParent>)parent localRepo:(SnuffyRepo *)localRepo remoteRepo:(SnuffyRepo *)remoteRepo;
-(void)filterForPackageCode:(NSString *)packageCode;
-(void)updateTableWithLocalRepo:(SnuffyRepo *)localRepo remoteRepo:(SnuffyRepo *)remoteRepo;
-(BOOL)isBasePackage:(NSString *)packageID language:(NSString *)languageCode;
-(NSInteger)numberOfBaseLanguagesForPackage:(NSString *)packageID;
-(void)turnEditModeOffIfNothingToDelete;
-(void)startDownloadForPackage:(SNPackageMeta *)package andLanguage:(SNLanguageMeta *)language;
-(void)cancelDownloadForPackage:(SNPackageMeta *)package andLanguage:(SNLanguageMeta *)language;
-(void)askForSwitchToPackage:(SNPackageMeta *)package andLanguage:(SNLanguageMeta *)language;
-(void)askForTableViewToBeDismissed;
-(void)askForTableViewToBeEdited;
-(void)confirmDeleteForPackage:(SNPackageMeta *)package andLanguage:(SNLanguageMeta *)language;

-(void)loadImagesForOnscreenRows;

@end




@protocol SNDownloaderTableViewControllerParent <NSObject>

-(NSString *)package;
-(NSString *)language;
@optional
-(void)downloaderTableViewController:(SNDownloaderTableViewController *)downloaderTableViewController willDeletePackage:(NSString *)packageID language:(NSString *)languageCode;
-(void)downloaderTableViewController:(SNDownloaderTableViewController *)downloaderTableViewController didDeletePackage:(NSString *)packageID language:(NSString *)languageCode;
-(void)switchTo:(NSString *)packageID language:(NSString *)language;
-(void)localRepoHasBeenUpdated;
-(void)remoteRepoHasBeenUpdated;

@end
