//
//  SNMeta.h
//  Snuffy
//
//  Created by Michael Harrison on 17/11/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNDownloadButton.h"
#import "SNPayloadDownloader.h"

@class		SNPackageMeta;
@class		SNLanguageMeta;
@protocol	SNRepoDataUpdatedDelegate;

@interface SNMeta : NSObject

@property	(nonatomic, assign)	BOOL					expanded;
@property	(nonatomic, assign)	float					downloadProgress;
@property	(nonatomic, assign)	SNDownloadStateOptions	state;

@property	(nonatomic, strong)	NSMutableDictionary		*properties;
@property	(nonatomic, strong)	NSMutableDictionary		*children;

@property	(nonatomic, strong)	SNPayloadDownloader		*downloaderForMe;
@property	(nonatomic, strong)	SNPayloadDownloader		*downloaderForAllChildren;

@property	(nonatomic, weak)	id <SNRepoDataUpdatedDelegate>	delegate;


-(id)initWithProperties:		(NSDictionary *)	propertyDictionary;
-(id)get:						(NSString *)		propertyName;
-(void)set:						(NSString *)		propertyName	withValue:	(id)	value;

-(void)startDownloadAll:(id)delegate;
-(void)cancelDownloadAll;

@end


@protocol SNRepoDataUpdatedDelegate <NSObject>

@optional
-(void)dataUpdated;
-(void)dataUpdatedInPackage:(NSString *)packageID;
-(void)dataUpdatedInLanguage:(NSString *)languageCode forPackage:(NSString *)packageID;
-(void)downloadCompleteInLanguage:(NSString *)languageCode forPackage:(NSString *)packageID;
-(void)downloadCompleteInPackage:(NSString *)packageID;
-(void)iconDownloadCompleteInLanguage:(NSString *)languageCode forPackage:(NSString *)packageID;

@end