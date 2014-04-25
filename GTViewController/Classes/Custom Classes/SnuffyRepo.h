//
//  SnuffyRepo.h
//  Snuffy
//
//  Created by Tom Flynn on 26/10/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RepoFileParser.h"
#import "SNMetaOptions.h"
#import "Downloader.h"


@interface SnuffyRepo : NSObject

@property (nonatomic, assign)	NSInteger			local_revision_number;
@property (nonatomic, assign)	NSInteger			server_revision_number;

@property (nonatomic, strong)   NSString			*local_XML;
@property (nonatomic, strong)   NSString			*local_XML_file;
@property (nonatomic, strong)   NSURL				*repo_server_URL;

@property (nonatomic, strong)   RepoFileParser		*repo_parser;

@property (nonatomic, strong)   NSMutableDictionary	*packages;

-(id)initWithPath:(NSString*)path;
-(id)initWithURL:(NSURL*)repofile_url;
-(id)initWithXmlString:(NSString*)xml_string;
-(id)initWithTBXML:(TBXML*)xml_representation;

-(void)writeXmlToFile:(NSString*)path;
-(NSString*)getXmlStringForPackageDictionary:(NSDictionary*)package_dictionary;


@end
