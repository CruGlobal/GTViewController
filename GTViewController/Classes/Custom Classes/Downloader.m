//
//  Downloader.m
//  Snuffy
//
//  Created by Michael Harrison on 3/11/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//	adapted from http://jayes-dev.blogspot.com/2010/12/asynchronous-downloadrequest-with.html
//

#import "Downloader.h"

@implementation Downloader

-(void)loadDataFrom: (NSString *)fileUrl withFilename: (NSString *)filename mode:(SNDownloaderToOptions)mode {
//    NSLog(@"loadDataFrom: %@ withFilename: %@ mode: %i", fileUrl, filename, mode);
	
	self.mode = mode;
	
    self.floatTotalData = 100;
    self.floatReceivedData = 0;
	
	if (self.mode == SNDownloadToFile) {
		
		self.localPath        = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"tmp"];
		self.localPath        = [self.localPath  stringByAppendingPathComponent:filename];
		
		[[NSFileManager defaultManager] createFileAtPath:self.localPath contents:nil attributes:nil];
		
	} else {
        
		NSMutableData *tempData = [[NSMutableData alloc] init];
		self.downloadData		= tempData;
		
	}
	
    
	
    NSMutableURLRequest *request    = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fileUrl]];
	
	
	/*
    //this block shall show how to add POST variables to the request
    NSString *encodedParameterPairs	= [NSString stringWithFormat:@"uid=%@", [[UIDevice currentDevice] uniqueIdentifier]];
    NSData *requestData             = [encodedParameterPairs dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody:requestData];
	*/
	
    self.connection	= [NSURLConnection connectionWithRequest:request delegate:self]; //request is send here
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //store how big file is going to be
    self.floatTotalData = [[NSString stringWithFormat:@"%lli",[response expectedContentLength]] floatValue];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
    self.floatReceivedData += [data length];
	
	//add this bit of data to the appropriate destination
	if (self.mode == SNDownloadToFile) {
		
		//add new data to the end of the file
		NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath: self.localPath];
		[fileHandle seekToEndOfFile];
		[fileHandle writeData: data];
		[fileHandle closeFile];
		
	} else {
		
		[self.downloadData appendData:data];
        NSLog(@"GOT A BIT: APPENDING TO MEMORY");
		
	}
   
	
	
	//if delegate did implement the method didReceiveData let him know about the new data
    if ([self.delegate respondsToSelector:@selector(downloaderDidReceiveData:)]) {
        [self.delegate downloaderDidReceiveData:self];
	}
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	//and let the delegate know that the download has finished
	
	if ([self.delegate respondsToSelector:@selector(downloaderDidLoadData:withPath:)]) {
        [self.delegate downloaderDidLoadData:self withPath:self.localPath];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
	
	if (self.mode == SNDownloadToFile) {
		
		NSError			*directoryError	= nil;
		NSFileManager	*fileManager	= [NSFileManager defaultManager];
		
		if (![fileManager removeItemAtPath:self.localPath error:&directoryError]) {
			
			NSLog(@"***Downloader - connection:didFailWithError: Couldn't remove partially downloaded file. Description: %@. Reason: %@. Options: %@. Suggestions: %@.", [directoryError localizedDescription], [directoryError localizedFailureReason], [directoryError localizedRecoveryOptions], [directoryError localizedRecoverySuggestion]);
			
		}
		
	} else {
		
		self.downloadData = nil;
		
	}
	
	
	self.floatTotalData				= 100;
    self.floatReceivedData			= 0;
	
	self.connection				= nil;
	
	//if delegate did implement the method didReceiveData let him know about the new data
    if ([self.delegate respondsToSelector:@selector(downloaderDidFail:withError:)]) {
        [self.delegate downloaderDidFail:self withError:error];
	}
}

-(void)cancel {

	[self.connection cancel];
	
	if (self.mode == SNDownloadToFile) {
		
		NSError			*directoryError	= nil;
		NSFileManager	*fileManager	= [NSFileManager defaultManager];
		
		if (![fileManager removeItemAtPath:self.localPath error:&directoryError]) {
			
			NSLog(@"***Downloader - cancel: Couldn't remove partially downloaded file. Description: %@. Reason: %@. Options: %@. Suggestions: %@.", [directoryError localizedDescription], [directoryError localizedFailureReason], [directoryError localizedRecoveryOptions], [directoryError localizedRecoverySuggestion]);
			
		}
		
	} else {
		
		self.downloadData = nil;
		
	}
	
	
	self.floatTotalData				= 100;
    self.floatReceivedData			= 0;
	
	self.connection				= nil;
}


-(float)getProgress{
	
	//if you want to show a progressbar or something similar call this method in
	
	//the delegate method didReceiveData
    return (self.floatReceivedData / self.floatTotalData) * 1.0f;
}


@end