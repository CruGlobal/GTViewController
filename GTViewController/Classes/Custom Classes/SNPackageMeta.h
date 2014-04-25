//
//  SNPackageMeta.h
//  Snuffy
//
//  Created by Michael Harrison on 2/11/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNMeta.h"
#import "SNLanguageMeta.h"

@interface SNPackageMeta : SNMeta <SNPayloadDownloaderDelegate>

@property	(nonatomic, assign)	NSInteger numberOfDownloadedLanguages;

-(NSMutableDictionary *)languages;
-(void)addLanguage:				(SNLanguageMeta *)	language;
-(void)removeLanguage:			(NSString *)		languageCode;
-(SNLanguageMeta *)getLanguage:	(NSString *)		languageCode;
-(BOOL)hasLanguage:				(NSString *)		languageCode;

-(void)startDownload;
-(void)cancelDownload;
-(void)deleteFromDisk:(NSDictionary *)exceptionLanguages;

-(BOOL)startIconDownloadForLanguage:(NSString *)languageCode;
-(BOOL)startDownloadLanguage:(NSString *)languageCode;
-(BOOL)cancelDownloadLanguage:(NSString *)languageCode;
-(BOOL)deleteLanguageFromDisk:(NSString *)languageCode;

-(void)incrementNumberOfDownloadedLanguages;
-(void)decrementNumberOfDownloadedLanguages;

-(NSString*)toString;

@end