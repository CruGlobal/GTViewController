//
//  SNPayloadOptions.m
//  Snuffy
//
//  Created by Michael Harrison on 3/11/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//

#import "SNPayloadOptions.h"

@implementation SNPayloadOptions

-(id)initWithPackage:(NSString *)packageOrNil language: (NSString *) languageOrNil segment: (NSString *) segmentOrNil compressed: (NSString *) compressedOrNil encoding: (NSString *) encodingOrNil screen_size: (NSString *) screen_sizeOrNil interpreter_version: (int) interpreter_version {

	self = [super init];
	
    if (self) {
        
		if (packageOrNil != nil) {
			self.package				= packageOrNil;
		}
		if (languageOrNil != nil) {
			self.language				= languageOrNil;
		}
		if (segmentOrNil != nil) {
			self.segment				= segmentOrNil;
		}
		if (compressedOrNil != nil) {
			self.compressed				= compressedOrNil;
		}
		if (encodingOrNil != nil) {
			self.encoding				= encodingOrNil;
		}
		if (screen_sizeOrNil != nil) {
			self.screen_size			= screen_sizeOrNil;
		}
		self.interpreter_version		= interpreter_version;
    }
	
    return self;
	
}

-(NSString *)produceUrl {
	
	NSString	*url;
	NSString	*protocol	= @"http://";
	NSString	*host		= @"127.0.0.1";
	//host                    = @"Harriet.local";
	//host                    = @"Air-Jordan.local";
    host                    = @"godtoolsapp.com";
	NSString	*port		= @":80";//8888";
	NSString	*phpPath	= @"/SnuffyRepo/payload.php";
	NSString	*options	= @"?";
	
	if (self.package != nil) {
		options	= [options stringByAppendingFormat:@"package=%@&", self.package];
	}
	if (self.language != nil) {
		options	= [options stringByAppendingFormat:@"language=%@&", self.language];
	}
	if (self.segment != nil) {
		options	= [options stringByAppendingFormat:@"segment=%@&", self.segment];
	}
	if (self.compressed != nil) {
		options	= [options stringByAppendingFormat:@"compressed=%@&", self.compressed];
	}
	if (self.encoding != nil) {
		options	= [options stringByAppendingFormat:@"encoding=%@&", self.encoding];
	}
	if (self.screen_size != nil) {
		options	= [options stringByAppendingFormat:@"screen_size=%@&", self.screen_size];
	}
	options	= [options stringByAppendingFormat:@"interpreter_version=%d&", self.interpreter_version];
	
	options	= [options stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"&"]];
	
	url						= [NSString stringWithFormat:@"%@%@%@%@", protocol, host, port, phpPath];
	
	if ([options length] > 1) {
		url = [url stringByAppendingString:options];
	} else {
		url = nil;
	}
	
	return url;
}

-(NSString *)produceFilename {
	
	NSString	*filename	= @"";
	
	if (self.package != nil) {
		filename	= [filename stringByAppendingFormat:@"%@_", self.package];
	}
	if (self.language != nil) {
		filename	= [filename stringByAppendingFormat:@"%@_", self.language];
	}
	if (self.segment != nil) {
		filename	= [filename stringByAppendingFormat:@"%@_", self.segment];
	}
	if (self.compressed != nil) {
		filename	= [filename stringByAppendingFormat:@"%@_", self.compressed];
	}
	if (self.encoding != nil) {
		filename	= [filename stringByAppendingFormat:@"%@_", self.encoding];
	}
	if (self.screen_size != nil) {
		filename	= [filename stringByAppendingFormat:@"%@_", self.screen_size];
	}
	filename	= [filename stringByAppendingFormat:@"%d_", self.interpreter_version];
	
	filename		= [filename stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
	
	if ([filename length] > 0) {
		filename = [filename stringByAppendingString:@".zip"];
	} else {
		filename = nil;
	}
	
	return filename;
}


@end
