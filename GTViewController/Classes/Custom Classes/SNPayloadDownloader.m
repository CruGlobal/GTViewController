//
//  SNPayloadDownloader.m
//  Snuffy
//
//  Created by Michael Harrison on 3/11/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//

#import "SNPayloadDownloader.h"
#import "GTFileLoader.h"

@implementation SNPayloadDownloader

-(id)initWithPackage:(NSString *)packageID language:(NSString *)languageCode delegate:(id <SNPayloadDownloaderDelegate>)delegate {
	
    self = [super init];
	
    if (self) {
		
        self.packageID		= packageID;
		self.languageCode	= languageCode;
		self.delegate		= delegate;
		
    }
	
    return self;
	
}


//TODO: add mode to this class
-(void)downloadPayloadWithOptions: (SNPayloadOptions *) options type:(SNPayloadDownloaderType)type {
	
	self.type	= type;
	
	Downloader	*tempPackageDownloader	= [[Downloader alloc] init];
	tempPackageDownloader.delegate = self;
	self.packageDownloader	= tempPackageDownloader;
	
	[self.packageDownloader loadDataFrom:[options produceUrl] withFilename:[options produceFilename] mode:(self.type == SNPayloadDownloaderTypeIcon ? SNDownloadToMemory : SNDownloadToFile)];
//    NSLog(@"SNPayloadDownloader: downloadPayload type: Icon? %i", type);
}

-(NSMutableData *)getData {
	
	return self.packageDownloader.downloadData;
	
}

-(void)clearData {
	
	self.packageDownloader.downloadData = nil;
	
}

-(void)cancelDownload {
	[self.packageDownloader cancel];
	self.packageDownloader = nil;
}

-(float)getProgress {
	return [self.packageDownloader getProgress];
}

-(void)downloaderDidReceiveData:(Downloader *)downloader {
	
	//if delegate did implement the method didReceiveData let him know about the new data
    if (self.type != SNPayloadDownloaderTypeIcon && [self.delegate respondsToSelector:@selector(didReceiveData:)]) {
        [self.delegate didReceiveData:self];
	}
}

-(void)downloaderDidLoadData:(Downloader *)downloader withPath:(NSString *)path {
	NSLog(@"didLoadData:withPath:%@", path);
	
	if (self.packageDownloader.mode == SNDownloadToFile) {
	
		//extract zip
		[GTFileLoader unzipPayloadWithPath:path];
		
		//remove zip
		NSFileManager *fileManager	= [NSFileManager defaultManager];
		[fileManager removeItemAtPath:path error:nil];
		
	}
	
	//if delegate did implement the method didLoadData:withPath: let him know about the finished download
    if ([self.delegate respondsToSelector:@selector(didLoadData:withPath:)]) {
        [self.delegate didLoadData:self withPath:path];
	}
}

-(void)downloaderDidFail:(Downloader *)downloader withError:(NSError *)error {
	
	//output error message
	NSLog(@"***SNPayloadDownloader - didFail:withError: Download failed. Description: %@. Reason: %@. Options: %@. Suggestions: %@.", [error localizedDescription], [error localizedFailureReason], [error localizedRecoveryOptions], [error localizedRecoverySuggestion]);
	
	//if delegate did implement the method didFail:withError: let him know about the failure
    if ([self.delegate respondsToSelector:@selector(didFail:withError:)]) {
        [self.delegate didFail:self withError:error];
	}
}


@end
