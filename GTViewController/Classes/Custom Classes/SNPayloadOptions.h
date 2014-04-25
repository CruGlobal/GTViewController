//
//  SNPayloadOptions.h
//  Snuffy
//
//  Created by Michael Harrison on 3/11/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNPayloadOptions : NSObject

@property(nonatomic, strong)	NSString	*package;
@property(nonatomic, strong)	NSString	*language;
@property(nonatomic, strong)	NSString	*segment;
@property(nonatomic, strong)	NSString	*compressed;
@property(nonatomic, strong)	NSString	*encoding;
@property(nonatomic, strong)	NSString	*screen_size;
@property(nonatomic)			int			interpreter_version;

-(id)initWithPackage:(NSString *)packageOrNil language: (NSString *) languageOrNil segment: (NSString *) segmentOrNil compressed: (NSString *) compressedOrNil encoding: (NSString *) encodingOrNil screen_size: (NSString *) screen_sizeOrNil interpreter_version: (int) interpreter_version;
-(NSString *)produceUrl;
-(NSString *)produceFilename;

@end
