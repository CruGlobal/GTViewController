//
//  SNMetaOptions.h
//  Snuffy
//
//  Created by Tom Flynn on 8/11/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface SNMetaOptions : NSObject

@property(nonatomic, strong) NSString	*package;
@property(nonatomic, strong) NSString	*language;
@property(nonatomic, strong) NSString	*compressed;
@property(nonatomic, strong) NSString	*encoding;
@property(nonatomic, strong) NSString	*revision_number;
@property(nonatomic, strong) NSString	*interpreter_version;

-(id)initWithPackage:(NSString *)packageOrNil language: (NSString *) languageOrNil compressed: (NSString *) compressedOrNil encoding: (NSString *) encodingOrNil revision_number: (NSString *) revision_numberOrNil interpreter_version: (NSString *) interpreter_versionOrNil;
-(NSString *)produceUrl;
-(NSString *)produceFilename;

@end
