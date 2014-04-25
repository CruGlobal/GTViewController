//
//  SNMeta.m
//  Snuffy
//
//  Created by Michael Harrison on 17/11/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//

#import "SNMeta.h"
#import "SNPayloadOptions.h"
#import "GTFileLoader.h"

@implementation SNMeta

- (id)initWithProperties:(NSDictionary *)propertyDictionary {
	
    self = [super init];
	
    if (self) {
		
		self.properties			= [[NSMutableDictionary alloc] init];
		
		self.children			= [[NSMutableDictionary alloc] init];
        
		[self.properties setValuesForKeysWithDictionary:propertyDictionary];
		
    }
	
    return self;
}

-(id)get:(NSString *)propertyName {
	return [self.properties objectForKey:propertyName];
}

-(void)set:(NSString *)propertyName withValue:(id)value {
	[self.properties setValue:value forKey:propertyName];
}

-(void)startDownloadAll:(id)delegate {
	
	SNPayloadOptions	*requestOptions		= [[SNPayloadOptions alloc] initWithPackage:[self get:@"id"]
																		 language:@"all"
																		  segment:@"all"
																	   compressed:@"yes"
																		 encoding:@"xml"
																	  screen_size:([GTFileLoader isRetina] ? @"retina" : @"standard")
															  interpreter_version:INTERPRETER_VERSION];
	
	SNPayloadDownloader	*downloadRequest	= [[SNPayloadDownloader alloc] initWithPackage:[self get:@"id"] language:nil delegate:delegate];
	
	[downloadRequest downloadPayloadWithOptions:requestOptions type:SNPayloadDownloaderTypePackage];
	self.downloaderForAllChildren	= downloadRequest;
	
	
	
}

-(void)cancelDownloadAll {
	
	[self.downloaderForAllChildren cancelDownload];
	self.downloaderForAllChildren	= nil;
	
}

- (void)dealloc {
    
	
	[self.properties removeAllObjects];
	
	[self.children removeAllObjects];
	
	
}

@end
