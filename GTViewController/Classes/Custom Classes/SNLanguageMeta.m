//
//  SNLanguageMeta.m
//  Snuffy
//
//  Created by Michael Harrison on 2/11/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//

#import "SNLanguageMeta.h"
#import "GTFileLoader.h"

@implementation SNLanguageMeta

- (id)initWithProperties:(NSDictionary *)propertyDictionary {
	
    self = [super initWithProperties:propertyDictionary];
	
    if (self) {
        
		//put init code here
		
    }
	
    return self;
}

-(NSMutableDictionary *)packages {
	return self.children;
}

-(void)addPackage:(NSString *)package {
	[self.children setValue:package forKey:package];
}

-(void)removePackage:(NSString *)packageID {
	[self.children removeObjectForKey:packageID];
}

-(BOOL)hasPackage:(NSString *)packageID {
	
	return ([self.children objectForKey:packageID] != nil);
}

//TODO: add check to see if its failed on the language or its icon
-(void)didFail:(SNPayloadDownloader *)downloader withError: (NSError *)error {
	
	if (downloader.type == SNPayloadDownloaderTypeIcon) {
		
		self.downloaderForIcon			= nil;
		
	} else {
		
		NSLog(@"FAIL");
		self.downloadProgress			= 0.0;
		self.state						= SNDownloadStateDownloadingError;
		self.downloaderForAllChildren	= nil;
		
		//alert delegate to changes
		if ([self.delegate respondsToSelector:@selector(dataUpdatedInLanguage:forPackage:)]) {
			
			[self.delegate dataUpdatedInLanguage:[self get:@"language_code"] forPackage:downloader.packageID];
			
		}
		
	}
	
}

//TODO: add check to see if its updating the language or its icon
-(void)didReceiveData:(SNPayloadDownloader *)downloader {
	
	if (downloader.type == SNPayloadDownloaderTypeLanguage) {
	
		NSLog(@"GOT A BIT");
		self.downloadProgress	= [downloader getProgress];
		
		//alert delegate to changes
		if ([self.delegate respondsToSelector:@selector(dataUpdatedInLanguage:forPackage:)]) {
			
			[self.delegate dataUpdatedInLanguage:[self get:@"language_code"] forPackage:downloader.packageID];
			
		}
		
	}
	
}

//TODO: add check to see if its finshed the language or its icon
-(void)didLoadData:(SNPayloadDownloader *)downloader withPath:(NSString *)path {
	
	if (downloader.type == SNPayloadDownloaderTypeIcon) {
		NSData *tempData = [downloader getData];
		self.icon = [[UIImage alloc] initWithData:tempData];
		
		self.downloaderForIcon = nil;
		
		//alert delegate to changes
		if ([self.delegate respondsToSelector:@selector(iconDownloadCompleteInLanguage:forPackage:)]) {
			
			[self.delegate iconDownloadCompleteInLanguage:[self get:@"language_code"] forPackage:downloader.packageID];
			
		}
		
	} else {
		
		NSLog(@"FINISHED");
		self.downloadProgress	= 1.0;
		self.state	= SNDownloadStateDownloadComplete;
		
		//alert delegate to changes
		if ([self.delegate respondsToSelector:@selector(downloadCompleteInLanguage:forPackage:)]) {
			
			[self.delegate downloadCompleteInLanguage:[self get:@"language_code"] forPackage:downloader.packageID];
			
		}
		
	}
	
}

-(void)clearIcon {
	
	self.icon = nil;
	
}

@end
