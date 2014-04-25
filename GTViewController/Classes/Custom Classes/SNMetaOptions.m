//
//  SNMetaOptions.m
//  Snuffy
//
//  Created by Tom Flynn on 8/11/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//

#import "SNMetaOptions.h"

@implementation SNMetaOptions

-(id)initWithPackage:(NSString *)packageOrNil language: (NSString *) languageOrNil compressed: (NSString *) compressedOrNil encoding: (NSString *) encodingOrNil revision_number: (NSString *) revision_numberOrNil interpreter_version: (NSString *) interpreter_versionOrNil {
    
	self = [super init];
	
    if (self) {
        
		if (packageOrNil != nil) {
			self.package				= packageOrNil;
		}
		if (languageOrNil != nil) {
			self.language				= languageOrNil;
		}
		if (compressedOrNil != nil) {
			self.compressed				= compressedOrNil;
		}
		if (encodingOrNil != nil) {
			self.encoding				= encodingOrNil;
		}
		if (revision_numberOrNil != nil) {
			self.revision_number		= revision_numberOrNil;
		}
		if (interpreter_versionOrNil != nil) {
			self.interpreter_version	= interpreter_versionOrNil;
		}
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
	NSString	*phpPath	= @"/SnuffyRepo/meta.php";
	NSString	*options	= @"?";
	
	if (self.package != nil) {
		options	= [options stringByAppendingFormat:@"package=%@&", self.package];
	}
	if (self.language != nil) {
		options	= [options stringByAppendingFormat:@"language=%@&", self.language];
	}
	if (self.compressed != nil) {
		options	= [options stringByAppendingFormat:@"compressed=%@&", self.compressed];
	}
	if (self.encoding != nil) {
		options	= [options stringByAppendingFormat:@"encoding=%@&", self.encoding];
	}
	if (self.revision_number != nil) {
		options	= [options stringByAppendingFormat:@"revision_number=%@&", self.revision_number];
	}
	if (self.interpreter_version != nil) {
		options	= [options stringByAppendingFormat:@"interpreter_version=%@&", self.interpreter_version];
	}
	
	options	= [options stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"&"]];
	
	url						= [NSString stringWithFormat:@"%@%@%@%@", protocol, host, port, phpPath];
	
	if ([options length] > 1) {
		url = [url stringByAppendingString:options];
	}
	
    NSLog(@"SNMetaOptions: produceURL\n%@", url);
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
	if (self.compressed != nil) {
		filename	= [filename stringByAppendingFormat:@"%@_", self.compressed];
	}
	if (self.encoding != nil) {
		filename	= [filename stringByAppendingFormat:@"%@_", self.encoding];
	}
	if (self.revision_number != nil) {
		filename	= [filename stringByAppendingFormat:@"%@_", self.revision_number];
	}
	if (self.interpreter_version != nil) {
		filename	= [filename stringByAppendingFormat:@"%@_", self.interpreter_version];
	}
	
	filename		= [filename stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
	
	if ([filename length] > 0) {
		filename = [filename stringByAppendingString:@".zip"];
	} else {
		filename = nil;
	}
	
	return filename;
}


@end
