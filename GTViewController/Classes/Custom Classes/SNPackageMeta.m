//
//  SNPackageMeta.m
//  Snuffy
//
//  Created by Michael Harrison on 2/11/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//

#import "SNPackageMeta.h"
#import "GTFileLoader.h"


@implementation SNPackageMeta

- (id)initWithProperties:(NSDictionary *)propertyDictionary {
	
    self = [super initWithProperties:propertyDictionary];
	
    if (self) {
		
		//put init code here
		self.numberOfDownloadedLanguages = 0;
		
    }
	
    return self;
}

-(NSMutableDictionary *)languages {
	
	return self.children;
	
}

-(void)addLanguage:(SNLanguageMeta *)language {
	
	[self.children setValue:language forKey:[language get:@"language_code"]];
	
}

-(void)removeLanguage:(NSString *)languageCode {
	
	[self.children removeObjectForKey:languageCode];
	
}

-(SNLanguageMeta *)getLanguage:(NSString *)languageCode {
	
	return [self.children objectForKey:languageCode];
	
}

-(BOOL)hasLanguage:(NSString *)languageCode {
	
	return ([self.children objectForKey:languageCode] != nil);
	
}

-(void)incrementNumberOfDownloadedLanguages {
	
	self.numberOfDownloadedLanguages++;
	
	if (self.numberOfDownloadedLanguages >= [[self languages] count]) {
		
		self.state = SNDownloadStateDownloadComplete;
		self.numberOfDownloadedLanguages = [[self languages] count];
		
	}
	
}

-(void)decrementNumberOfDownloadedLanguages {
	
	if (self.numberOfDownloadedLanguages > 0) {
		self.numberOfDownloadedLanguages--;
	}
	
	if (self.numberOfDownloadedLanguages < [[self languages] count]) {
		
		self.state = SNDownloadStateReadyToDownload;
		
	}
	
}

-(void)startDownload {
	NSLog(@"startDownload - %@", [self get:@"id"]);
	self.state	= SNDownloadStateDownloading;
	
	//alert delegate to changes
	if ([self.delegate respondsToSelector:@selector(dataUpdatedInPackage:)]) {
		[self.delegate dataUpdatedInPackage:[self get:@"id"]];
	}
	
	[super startDownloadAll:self];
	
}

-(void)cancelDownload {
	NSLog(@"cancelDownload - %@", [self get:@"id"]);
	self.state	= SNDownloadStateReadyToDownload;
	
	//alert delegate to changes
	if ([self.delegate respondsToSelector:@selector(dataUpdatedInPackage:)]) {
		[self.delegate dataUpdatedInPackage:[self get:@"id"]];
	}
	
	[super cancelDownloadAll];
	
}

-(void)deleteFromDisk:(NSDictionary *)exceptionLanguages {
	
	NSLog(@"deleteFromDisk - %@", [self get:@"id"]);
	
	if (exceptionLanguages == nil) {
		exceptionLanguages = @{};
	}
	
	//go through each language in the package deleting them
	for (NSString *languageCode in self.children) {
		
		//if the language doesn't exist in the exception list then delete it
		if ([exceptionLanguages objectForKey:languageCode] == nil) {
			
			[self deleteLanguageFromDisk:languageCode];
			
		}
		
	}
	
	//assumes that whoever called it will delete this object and update the list
	
	
}

-(BOOL)startIconDownloadForLanguage:(NSString *)languageCode {
	
	NSLog(@"startIconDownloadForLanguage:%@", languageCode);
	SNLanguageMeta *language		= [self getLanguage:languageCode];
	
	if (language != nil) {
		
		SNPayloadOptions	*requestOptions		= [[SNPayloadOptions alloc] initWithPackage:[self get:@"id"]
																			 language:languageCode
																			  segment:@"icon"
																		   compressed:@"no"
																			 encoding:@"xml"
																		  screen_size:([GTFileLoader isRetina] ? @"retina" : @"standard")
																  interpreter_version:INTERPRETER_VERSION];
		
		SNPayloadDownloader	*downloadRequest	= [[SNPayloadDownloader alloc] initWithPackage:[self get:@"id"] language:languageCode delegate:language];
		
		language.delegate = self.delegate;
		[downloadRequest downloadPayloadWithOptions:requestOptions type:SNPayloadDownloaderTypeIcon];
		language.downloaderForIcon	= downloadRequest;
		
		
		
		return YES;
		
	} else {
		
		return NO;
		
	}
	
}

-(BOOL)startDownloadLanguage:(NSString *)languageCode {
	NSLog(@"startDownloadLanguage:%@", languageCode);
	SNLanguageMeta *language		= [self getLanguage:languageCode];
	
	if (language != nil) {
		
		language.state				= SNDownloadStateDownloading;
		
		//alert delegate to changes
		if ([self.delegate respondsToSelector:@selector(dataUpdatedInLanguage:forPackage:)]) {
			[self.delegate dataUpdatedInLanguage:languageCode forPackage:[self get:@"id"]];
		}
		
		SNPayloadOptions	*requestOptions		= [[SNPayloadOptions alloc] initWithPackage:[self get:@"id"]
																			 language:languageCode
																			  segment:@"all"
																		   compressed:@"yes"
																			 encoding:@"xml"
																		  screen_size:([GTFileLoader isRetina] ? @"retina" : @"standard")
																  interpreter_version:INTERPRETER_VERSION];
		
		SNPayloadDownloader	*downloadRequest	= [[SNPayloadDownloader alloc] initWithPackage:[self get:@"id"] language:languageCode delegate:language];
		
		language.delegate = self.delegate;
		[downloadRequest downloadPayloadWithOptions:requestOptions type:SNPayloadDownloaderTypeLanguage];
		language.downloaderForMe	= downloadRequest;
		
		
		
		return YES;
		
	} else {
		
		return NO;
		
	}
	
}

-(BOOL)cancelDownloadLanguage:(NSString *)languageCode {
	NSLog(@"cancelDownloadLanguage:%@", languageCode);
	SNLanguageMeta *language		= [self getLanguage:languageCode];
	
	if (language != nil) {
		
		language.state				= SNDownloadStateReadyToDownload;
		
		//alert delegate to changes
		if ([self.delegate respondsToSelector:@selector(dataUpdatedInLanguage:forPackage:)]) {
			[self.delegate dataUpdatedInLanguage:languageCode forPackage:[self get:@"id"]];
		}
		
		language.delegate = self.delegate;
		[language.downloaderForMe cancelDownload];
		language.downloaderForMe	= nil;
		
		return YES;
		
	} else {
		
		return NO;
		
	}
	
}

-(BOOL)deleteLanguageFromDisk:(NSString *)languageCode {
	NSLog(@"deleteLanguageFromDisk:%@", languageCode);
	if ([self hasLanguage:languageCode]) {
		
		[GTFileLoader removeLanguage:languageCode forPackage:[self get:@"id"]];
		
		[self decrementNumberOfDownloadedLanguages];
		
		//assumes that whoever called it will remove the language and update the list
		//[self removeLanguage:languageCode];
		
		return YES;
		
	} else {
		
		return NO;
		
	}
	
}

-(void)didFail:(SNPayloadDownloader *)downloader withError: (NSError *)error {
	NSLog(@"SNPackageMeta - didFail - %@", [self get:@"id"]);
	self.downloadProgress			= 0.0;
	self.state						= SNDownloadStateDownloadingError;
	self.downloaderForAllChildren	= nil;
	
	//alert delegate to changes
	if ([self.delegate respondsToSelector:@selector(dataUpdatedInPackage:)]) {
		[self.delegate dataUpdatedInPackage:[self get:@"id"]];
	}
	
}

-(void)didReceiveData:(SNPayloadDownloader *)downloader {
	NSLog(@"SNPackageMeta - didReceiveData - %@", [self get:@"id"]);
	self.downloadProgress	= [downloader getProgress];
	
	//alert delegate to changes
	if ([self.delegate respondsToSelector:@selector(dataUpdatedInPackage:)]) {
		[self.delegate dataUpdatedInPackage:[self get:@"id"]];
	}
	
}


-(void)didLoadData:(SNPayloadDownloader *)downloader withPath:(NSString *)path {
	NSLog(@"SNPackageMeta - didLoadData:withPath:%@ - %@", path, [self get:@"id"]);
	
	//update state of package
	self.downloadProgress				= 1.0;
	self.numberOfDownloadedLanguages	= [[self languages] count];
	self.state							= SNDownloadStateDownloadComplete;
	
	//update state of all its languages
	for (NSString *languageCode in [self languages]) {
		
		SNLanguageMeta *language = [self getLanguage:languageCode];
		
		language.downloadProgress		= 1.0;
		language.state					= SNDownloadStateDownloadComplete;
	}
    
	
	//alert delegate to changes
	if ([self.delegate respondsToSelector:@selector(downloadCompleteInPackage:)]) {
		[self.delegate downloadCompleteInPackage:[self get:@"id"]];
	}
	
}

-(NSString*)toString {
    NSString *returnstring = [self get:@"id"];
    
    for (NSString *language_code in [[self languages] allKeys]) {
        returnstring = [NSString stringWithFormat:@"%@, %@", returnstring, language_code];
    }
    
    return returnstring;
}


@end
