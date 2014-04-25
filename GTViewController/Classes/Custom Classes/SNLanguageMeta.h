//
//  SNLanguageMeta.h
//  Snuffy
//
//  Created by Michael Harrison on 2/11/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNMeta.h"

@interface SNLanguageMeta : SNMeta <SNPayloadDownloaderDelegate>

@property	(nonatomic, strong)	SNPayloadDownloader		*downloaderForIcon;
@property (nonatomic, strong) UIImage *icon;

-(NSMutableDictionary *)packages;
-(void)addPackage:				(NSString *)		package;
-(void)removePackage:			(NSString *)		packageID;
-(BOOL)hasPackage:				(NSString *)		packageID;
-(void)clearIcon;

@end
