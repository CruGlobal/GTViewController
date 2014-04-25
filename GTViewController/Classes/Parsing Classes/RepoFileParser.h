//
//  RepoFileParser.h
//  Snuffy
//
//  Created by Tom Flynn on 26/10/11.
//  Copyright (c) 2011 CCCA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"
#import "SNPackageMeta.h"

@interface RepoFileParser : NSObject

@property (nonatomic, strong)       TBXML					*xmlRepresentation;
@property (nonatomic, strong)       NSMutableDictionary		*packages;

-(id)initWithURL:(NSURL*)repourl;
-(id)initWithXMLPath:(NSString*)xmlpath;
-(id)initWithXMLString:(NSString*)xmlstring;
-(id)initWithTBXML:(TBXML*)tempXml;

+(NSMutableDictionary*)createSNPackageMetaFromTBXML:(TBXML*)xmlrepresentation;

@end
